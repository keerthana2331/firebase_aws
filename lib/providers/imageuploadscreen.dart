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
        
       
        if (!_imageUrls.contains(result)) {
          _imageUrls.insert(0, result);
        }

        await FirebaseFirestore.instance.collection('images').add({
          'userId': userId,
          'noteId': noteId,
          'imageUrl': result,
          'timestamp': FieldValue.serverTimestamp(),
        });

       
        await _saveImagesToLocal(noteId, _imageUrls);

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
      print("Error uploading image: $e");
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

    print(" Fetching images for: userEmail=$userEmail, noteId=$noteId");

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('images')
        .where('userEmail', isEqualTo: userEmail) 
        .where('noteId', isEqualTo: noteId)
        .orderBy('timestamp', descending: true)
        .get();

    if (snapshot.docs.isEmpty) {
      print(" No images found for userEmail: $userEmail and noteId: $noteId");
    } else {
      print(" Found ${snapshot.docs.length} images!");
      for (var doc in snapshot.docs) {
        print(" Image URL: ${doc.data()['imageUrl']}");
      }
    }


    _imageUrls = snapshot.docs
        .map((doc) => doc.data()['imageUrl'] as String)
        .where((url) => url.isNotEmpty)
        .toList();

    await _saveImagesToLocal(noteId, _imageUrls);

  } catch (e) {
    _error = "Error fetching images: $e";
    print(" Error: $e");
  } finally {
    _isFetching = false;
    notifyListeners();
  }
}



  Future<void> _saveImagesToLocal(String noteId, List<String> imageUrls) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('images_${userId}_$noteId', jsonEncode(imageUrls));
  }


  Future<File?> downloadImage(String imageUrl, String noteId) async {
    try {
 
      if (_downloadedFiles.containsKey(imageUrl)) {
        final existingPath = _downloadedFiles[imageUrl];
        if (existingPath != null && File(existingPath).existsSync()) {
          print(" Returning already downloaded file: $existingPath");
          return File(existingPath);
        }
      }

    
      final String filename = '${imageUrl.hashCode}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      
  
      _downloadedFiles[imageUrl] = filePath;
      
      print(" Image downloaded to: $filePath");
      return File(filePath);
    } catch (e) {
      print(" Error downloading image: $e");
      return null;
    }
  }

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

      _downloadedFiles.remove(imageUrl);
      await _saveImagesToLocal(noteId, _imageUrls);
      notifyListeners();
    } catch (e) {
      print(" Error deleting image: $e");
    }
  }

  Future<File?> moveFileToPermanentStorage(File file) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
   
      final String uniqueId = base64Encode(file.path.codeUnits).replaceAll(RegExp(r'[\/\+\=]'), '');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$uniqueId.jpg';
      final newPath = '${directory.path}/$fileName';
      
  
      if (await File(newPath).exists()) {
        print(" File already exists at destination: $newPath");
        return File(newPath);
      }
      
      final File newFile = await file.copy(newPath);
      print(" File moved to permanent storage: $newPath");
      return newFile;
    } catch (e) {
      print(" Error moving file: $e");
      return null;
    }
  }


  void reset() {
    _image = null;
    _uploadedImageUrl = null;
    _imageUrls = [];
    _error = null;
    _isUploading = false;
    _isFetching = false;
    notifyListeners();
  }

  void addImageUrl(String imageUrl) {
    if (!_imageUrls.contains(imageUrl)) {
      _imageUrls.add(imageUrl);
      notifyListeners();
    }
  }
}