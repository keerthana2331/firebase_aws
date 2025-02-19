import 'dart:convert';
import 'dart:io';
import 'package:authenticationapp/aw3service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageUploadProvider with ChangeNotifier {
  final AWSS3Service _s3Service = AWSS3Service();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  bool _isUploading = false;
  String? _uploadedImageUrl;
  List<String> _imageUrls = [];
  bool _isFetching = false;
  String? _error;

  // Getters
  File? get image => _image;
  bool get isUploading => _isUploading;
  String? get uploadedImageUrl => _uploadedImageUrl;
  List<String> get imageUrls => _imageUrls;
  bool get isFetching => _isFetching;
  String? get error => _error;
  bool get isLoading => _isUploading || _isFetching;

  // Get the current user's ID safely
  String? get userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("⚠️ User is not logged in!");
      return null;
    }
    return user.uid;
  }

  // Getter for user image URLs
  List<String> get userImageUrls => _imageUrls;

  /// Pick image from camera/gallery
  Future<void> pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      PermissionStatus status = await Permission.photos.request();
      if (!status.isGranted) {
        _error = "Gallery access denied";
        notifyListeners();
        return;
      }
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        _error = "No image selected";
        notifyListeners();
        return;
      }

      _image = File(pickedFile.path);
      notifyListeners();
    } catch (e) {
      _error = "Error picking image: $e";
      notifyListeners();
    }
  }

  /// Upload image to AWS S3 & store in Firestore
  Future<bool> uploadImageToS3({required String noteId, required String userEmail}) async {
    if (_image == null || userId == null) {
      _error = "No image selected or user not logged in";
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      print("🛠 Uploading image for user: $userId, note: $noteId");
      final result = await _s3Service.uploadFile(_image!, noteId);

      if (result != null) {
        _uploadedImageUrl = result;
        _imageUrls.insert(0, result);

        // Save to Firestore under the user's UID
        await FirebaseFirestore.instance.collection('images').add({
          'userId': userId,
          'noteId': noteId,
          'imageUrl': result,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print("✅ Image uploaded successfully: $_uploadedImageUrl");
      } else {
        _error = "Upload failed";
        print("⚠️ Upload failed");
      }

      _isUploading = false;
      notifyListeners();
      return _uploadedImageUrl != null;
    } catch (e) {
      _error = "Error uploading image: $e";
      print("❌ Error uploading image: $e");
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch images for the logged-in user & specific note
  Future<void> fetchImagesFromFirestore(String noteId, String userEmail) async {
    if (_isFetching || userId == null) return;

    try {
      _isFetching = true;
      _error = null;
      notifyListeners();

      // Load images from local storage first
      await _loadImagesFromLocal(noteId);

      if (_imageUrls.isNotEmpty) {
        print("📁 Loaded ${_imageUrls.length} images from local storage.");
        _isFetching = false;
        notifyListeners();
        return;
      }

      print("🌍 No local images found, fetching from Firestore...");

      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('images')
          .where('userId', isEqualTo: userId)
          .where('noteId', isEqualTo: noteId)
          .orderBy('timestamp', descending: true)
          .get();

      _imageUrls = snapshot.docs
          .map((doc) => doc.data()['imageUrl'] as String?)
          .where((url) => url != null && url.isNotEmpty)
          .cast<String>()
          .toList();

      print("✅ Fetched ${_imageUrls.length} images successfully");
      await _saveImagesToLocal(noteId, _imageUrls);
    } catch (e) {
      _error = "Error fetching images: $e";
      print("❌ Error fetching images: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  /// Load images from local storage
  Future<void> _loadImagesFromLocal(String noteId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? imagesJson = prefs.getString('images_${userId}_$noteId');

    if (imagesJson != null) {
      _imageUrls = List<String>.from(jsonDecode(imagesJson));
    }
  }

  /// Save images locally
  Future<void> _saveImagesToLocal(String noteId, List<String> imageUrls) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('images_${userId}_$noteId', jsonEncode(imageUrls));
  }

  /// Delete image
  Future<void> deleteImage(String imageUrl, String noteId, String userEmail) async {
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('images')
          .where('userId', isEqualTo: userId)
          .where('noteId', isEqualTo: noteId)
          .where('imageUrl', isEqualTo: imageUrl)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      _imageUrls.remove(imageUrl);
      await _saveImagesToLocal(noteId, _imageUrls);
      notifyListeners();
    } catch (e) {
      print("❌ Error deleting image: $e");
    }
  }

  /// Move image to permanent storage
  Future<File?> moveFileToPermanentStorage(File file) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final newPath = '${directory.path}/$fileName';
      final File newFile = await file.copy(newPath);

      return newFile;
    } catch (e) {
      print("❌ Error moving file: $e");
      return null;
    }
  }

  /// Reset state
  void reset() {
    _image = null;
    _uploadedImageUrl = null;
    _imageUrls = [];
    _error = null;
    _isUploading = false;
    _isFetching = false;
    notifyListeners();
  }

  /// Add image URL to list
  void addImageUrl(String imageUrl) {
    _imageUrls.add(imageUrl);
    notifyListeners();
  }
}
