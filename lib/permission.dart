import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class ImageDownloadPermission {
  // Check and request storage permission
 static Future<bool> requestStoragePermission(BuildContext context) async {
  PermissionStatus status;

  if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
    return true; // Permission is already granted
  }

  if (await Permission.photos.isDenied || await Permission.photos.isRestricted) {
    status = await Permission.photos.request();
  } else if (await Permission.storage.isDenied || await Permission.storage.isRestricted) {
    status = await Permission.storage.request();
  } else {
    return true; // No need to request again
  }

  if (status.isGranted) {
    return true;
  } else if (status.isPermanentlyDenied) {
    await _showPermissionDialog(context);
  }

  return false;
}


  // Custom permission dialog
  static Future<void> _showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Storage permission is required to download images. Please grant permission in Settings.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Example usage in download function
  static Future<void> downloadImage(BuildContext context) async {
    bool hasPermission = await requestStoragePermission(context);
    
    if (hasPermission) {
      try {
        // Your image download logic here
        // Example: await GallerySaver.saveImage(imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image downloaded successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download image')),
        );
      }
    }
  }
}
