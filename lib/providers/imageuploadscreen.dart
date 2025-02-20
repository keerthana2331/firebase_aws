import 'dart:convert';
import 'dart:io';
import 'package:authenticationapp/aw3service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

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

  final Map<String, String> _downloadedFiles = {};

  File? get image => _image;
  bool get isUploading => _isUploading;
  String? get uploadedImageUrl => _uploadedImageUrl;
  List<String> get imageUrls => _imageUrls;
  bool get isFetching => _isFetching;
  String? get error => _error;
  bool get isLoading => _isUploading || _isFetching;

  String? get userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print(" User is not logged in!");
      return null;
    }
    return user.uid;
  }

  List<String> get userImageUrls => _imageUrls;

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

  Future<bool> uploadImageToS3(
      {required String noteId, required String userEmail}) async {
    if (_image == null || userId == null) {
      _error = "No image selected or user not logged in";
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      print(" Uploading image for user: $userId, note: $noteId");
      final result = await _s3Service.uploadFile(_image!, noteId);

      if (result != null) {
        _uploadedImageUrl = result;

        if (!_imageUrls.contains(result)) {
          _imageUrls.insert(0, result);
        }

        await FirebaseFirestore.instance.collection('images').add({
          'userId': userId,
          'noteId': noteId,
          'imageUrl': result,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await saveImagesToLocal(noteId, _imageUrls);

        print(" Image uploaded successfully: $_uploadedImageUrl");
      } else {
        _error = "Upload failed";
        print(" Upload failed");
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

  Future<void> fetchImagesFromFirestore(String noteId, String userEmail) async {
    if (_isFetching || userId == null) return;

    try {
      _isFetching = true;
      _error = null;
      notifyListeners();

      await loadImagesFromLocal(noteId);

      print(" Fetching images from Firestore...");

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('images')
              .where('userId', isEqualTo: userId)
              .where('noteId', isEqualTo: noteId)
              .orderBy('timestamp', descending: true)
              .get();

      final List<String> firestoreUrls = snapshot.docs
          .map((doc) => doc.data()['imageUrl'] as String?)
          .where((url) => url != null && url.isNotEmpty)
          .cast<String>()
          .toList();

      final Set<String> uniqueUrls = {..._imageUrls, ...firestoreUrls};
      _imageUrls = uniqueUrls.toList();

      print(" Fetched ${_imageUrls.length} unique images successfully");
      await saveImagesToLocal(noteId, _imageUrls);
    } catch (e) {
      _error = "Error fetching images: $e";
      print(" Error fetching images: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> loadImagesFromLocal(String noteId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? imagesJson = prefs.getString('images_${userId}_$noteId');

    if (imagesJson != null) {
      _imageUrls = List<String>.from(jsonDecode(imagesJson));
    } else {
      _imageUrls = [];
    }
  }

  Future<void> saveImagesToLocal(String noteId, List<String> imageUrls) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('images_${userId}_$noteId', jsonEncode(imageUrls));
  }

  Future<void> deleteImage(
      String imageUrl, String noteId, String userEmail) async {
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

      _downloadedFiles.remove(imageUrl);
      await saveImagesToLocal(noteId, _imageUrls);
      notifyListeners();
    } catch (e) {
      print(" Error deleting image: $e");
    }
  }

  void addImageUrl(String imageUrl) {
    if (!_imageUrls.contains(imageUrl)) {
      _imageUrls.add(imageUrl);
      notifyListeners();
    }
  }
}
