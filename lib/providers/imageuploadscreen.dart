import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:authenticationapp/aw3service.dart';

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

  get lastUploadedUrl => null;

  get isLoading => null;

  get userImageUrls => null;

  /// Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress image for better upload performance
      );

      if (pickedFile == null) {
        _error = "No image selected";
        notifyListeners();
        return;
      }

      File tempImage = File(pickedFile.path);
      print("✅ Picked Image Path: ${tempImage.path}");

      // Move image to permanent storage
      _image = await moveFileToPermanentStorage(tempImage);

      if (_image != null) {
        print("📂 Moved Image Path: ${_image!.path}");
        _error = null;
      } else {
        _error = "Failed to process image";
        print("❌ Failed to move image to permanent storage.");
      }

      notifyListeners();
    } catch (e) {
      _error = "Error picking image: $e";
      print("❌ Error picking image: $e");
      notifyListeners();
    }
  }
    Future<void> deleteImage(String imageUrl, String noteId, String userEmail) async {
    // Implement the logic to delete the image
    // For example, remove the image from the list and notify listeners
    userImageUrls.remove(imageUrl);
    notifyListeners();
  }

  /// Move image to permanent storage
  Future<File?> moveFileToPermanentStorage(File file) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final newPath = '${directory.path}/$fileName';
      final File newFile = await file.copy(newPath);
      
      // Save the image path to SharedPreferences
      await saveImagePath(newFile.path);

      return newFile;
    } catch (e) {
      print("❌ Error moving file: $e");
      return null;
    }
  }

  /// Upload image to AWS S3
  Future<bool> uploadImageToS3({
    required String noteId,
    required String userEmail,
  }) async {
    if (_image == null) {
      _error = "No image selected to upload";
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _s3Service.uploadFile(_image!, noteId);

      if (result != null) {
        _uploadedImageUrl = result;
        // Add to local list immediately for faster UI update
        _imageUrls.insert(0, result);
        _error = null;
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


Future<void> fetchImagesFromFirestore(String noteId, String userEmail) async {
  if (_isFetching) return;

  try {
    _isFetching = true;
    _error = null;
    notifyListeners();

    // Try loading images from local storage first
    await _loadImagesFromLocal(noteId);

    // If we already have images, no need to fetch
    if (_imageUrls.isNotEmpty) {
      print("📁 Loaded ${_imageUrls.length} images from local storage.");
      return;
    }

    print("🌍 No local images found, fetching from Firestore...");

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('images')
        .where('noteId', isEqualTo: noteId)
        .get();

    _imageUrls = snapshot.docs
        .map((doc) => doc.data()['imageUrl'] as String?)
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .toList();

    print("✅ Fetched ${_imageUrls.length} images successfully");

    // Save fetched images to local storage
    await _saveImagesToLocal(noteId, _imageUrls);

  } catch (e) {
    _error = "Error fetching images: $e";
    print("❌ Error fetching images: $e");
  } finally {
    _isFetching = false;
    notifyListeners();
  }
}

// Function to load images from local storage
Future<void> _loadImagesFromLocal(String noteId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? imagesJson = prefs.getString('images_$noteId');

  if (imagesJson != null) {
    _imageUrls = List<String>.from(jsonDecode(imagesJson));
  }
}

// Function to save images locally
Future<void> _saveImagesToLocal(String noteId, List<String> imageUrls) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('images_$noteId', jsonEncode(imageUrls));
}



  /// Save the image path to SharedPreferences
  Future<void> saveImagePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedImagePath', path);
  }

  /// Retrieve the saved image path from SharedPreferences
  Future<String?> getImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('savedImagePath');
  }

  /// Reset selected image
  void resetImage() {
    _image = null;
    _uploadedImageUrl = null;
    _error = null;
    notifyListeners();
  }

  /// Reset error state
  void resetError() {
    _error = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _image = null;
    _uploadedImageUrl = null;
    _imageUrls = [];
    _error = null;
    _isUploading = false;
    _isFetching = false;
    notifyListeners();
  }

  void addImageUrl(String imageUrl) {}
}
