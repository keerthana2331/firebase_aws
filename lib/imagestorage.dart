// import 'package:shared_preferences/shared_preferences.dart';

// class ImageStorageHelper {
//   static const String _keyPrefix = 'user_images_';

//   // Save a new image path to the list
//   static Future<void> saveImagePath(String imageUrl, String userId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final key = _keyPrefix + userId;
    
//     // Get existing images or create new list
//     List<String> existingImages = prefs.getStringList(key) ?? [];
    
//     // Add new image if it doesn't exist
//     if (!existingImages.contains(imageUrl)) {
//       existingImages.add(imageUrl);
//       await prefs.setStringList(key, existingImages);
//     }
//   }

//   // Get all saved image paths
//   static Future<List<String>> getSavedImagePaths(String userId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final key = _keyPrefix + userId;
//     return prefs.getStringList(key) ?? [];
//   }

//   // Clear all images for a user
//   static Future<void> clearImages(String userId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final key = _keyPrefix + userId;
//     await prefs.remove(key);
//   }
// }
