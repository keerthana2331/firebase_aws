// import 'dart:io';
// import 'package:authenticationapp/aw3service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/widgets.dart';



// class ImageGalleryPage extends StatelessWidget {
//   final String noteId;
//   final String userEmail;

//   const ImageGalleryPage({
//     Key? key, 
//     required this.noteId,
//     required this.userEmail,
//   }) : super(key: key);

//   Future<void> _downloadImage(BuildContext context, String imageUrl) async {
//     // Implement download functionality here
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Downloading image...')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => ImageGalleryProvider()..fetchImages(noteId),
//       child: Scaffold(
//         backgroundColor: Colors.grey[50],
//         appBar: AppBar(
//           title: Text('Image Gallery', style: GoogleFonts.poppins()),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: Consumer<ImageGalleryProvider>(
//           builder: (context, provider, child) {
//             if (provider.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             return SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Image Preview Section
//                     if (provider.selectedImage != null)
//                       _buildImagePreview(provider.selectedImage!)
//                     else
//                       _buildEmptyPreview(),

//                     const SizedBox(height: 16),
                    
//                     // Action Buttons
//                     _buildActionButtons(context, provider),
                    
//                     const SizedBox(height: 24),
                    
//                     // Image Gallery Section
//                     _buildGallerySection(provider),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildImagePreview(File image) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Image.file(
//           image,
//           height: 300,
//           width: double.infinity,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Container(
//               height: 300,
//               color: Colors.grey[200],
//               child: const Center(
//                 child: Icon(Icons.error_outline, size: 50, color: Colors.red),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyPreview() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Container(
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Center(
//           child: Text(
//             'No image selected',
//             style: GoogleFonts.poppins(
//               color: Colors.grey[600],
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context, ImageGalleryProvider provider) {
//     return Column(
//       children: [
//         ElevatedButton.icon(
//           icon: const Icon(Icons.photo_library),
//           label: Text('Select Image', style: GoogleFonts.poppins()),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           onPressed: () => provider.pickImage(ImageSource.gallery),
//         ),
//         if (provider.selectedImage != null) ...[
//           const SizedBox(height: 12),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.upload),
//             label: Text(
//               provider.isUploading ? 'Uploading...' : 'Upload Image',
//               style: GoogleFonts.poppins(),
//             ),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: provider.isUploading
//                 ? null
//                 : () async {
//                     final success = await provider.uploadImage(
//                       noteId: noteId,
//                       userEmail: userEmail,
//                     );
//                     if (success) {
//                       provider.fetchImages(noteId);
//                     }
//                   },
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildGallerySection(ImageGalleryProvider provider) {
//     if (provider.images.isEmpty) {
//       return Center(
//         child: Text(
//           'No images uploaded yet',
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             color: Colors.grey[600],
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Uploaded Images',
//           style: GoogleFonts.poppins(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 8),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: provider.images.length,
//           itemBuilder: (context, index) {
//             return Card(
//               margin: const EdgeInsets.only(bottom: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 4,
//               child: Column(
//                 children: [
//                   ClipRRect(
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(12),
//                     ),
//                     child: Image.network(
//                       provider.images[index].imageUrl,
//                       height: 200,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Container(
//                           height: 200,
//                           color: Colors.grey[100],
//                           child: const Center(
//                             child: CircularProgressIndicator(),
//                           ),
//                         );
//                       },
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           height: 200,
//                           color: Colors.grey[100],
//                           child: const Center(
//                             child: Icon(
//                               Icons.error_outline,
//                               size: 40,
//                               color: Colors.red,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.download),
//                           onPressed: () => _downloadImage(
//                             context,
//                             provider.images[index].imageUrl,
//                           ),
//                           tooltip: 'Download Image',
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete_outline),
//                           onPressed: () => provider.deleteImage(
//                             provider.images[index].id,
//                             noteId,
//                           ),
//                           tooltip: 'Delete Image',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class ImageModel {
//   final String id;
//   final String imageUrl;
//   final DateTime timestamp;

//   ImageModel({
//     required this.id,
//     required this.imageUrl,
//     required this.timestamp,
//   });

//   factory ImageModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return ImageModel(
//       id: doc.id,
//       imageUrl: data['imageUrl'] ?? '',
//       timestamp: (data['timestamp'] as Timestamp).toDate(),
//     );
//   }
// }

// class ImageGalleryProvider extends ChangeNotifier {
//   final AWSS3Service _s3Service = AWSS3Service();
//   final ImagePicker _picker = ImagePicker();
  
//   List<ImageModel> _images = [];
//   File? _selectedImage;
//   bool _isLoading = false;
//   bool _isUploading = false;

//   List<ImageModel> get images => _images;
//   File? get selectedImage => _selectedImage;
//   bool get isLoading => _isLoading;
//   bool get isUploading => _isUploading;

//   Future<void> fetchImages(String noteId) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('images')
//           .where('noteId', isEqualTo: noteId)
//           .orderBy('timestamp', descending: true)
//           .get();

//       _images = snapshot.docs
//           .map((doc) => ImageModel.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       print('Error fetching images: $e');
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile != null) {
//         _selectedImage = File(pickedFile.path);
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//     }
//   }

//   Future<bool> uploadImage({
//     required String noteId,
//     required String userEmail,
//   }) async {
//     if (_selectedImage == null) return false;

//     _isUploading = true;
//     notifyListeners();

//     try {
//       final imageUrl = await _s3Service.uploadFile(_selectedImage!, noteId);
//       if (imageUrl != null) {
//         _selectedImage = null;
//         return true;
//       }
//     } catch (e) {
//       print('Error uploading image: $e');
//     }

//     _isUploading = false;
//     notifyListeners();
//     return false;
//   }

//   Future<void> deleteImage(String imageId, String noteId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('images')
//           .doc(imageId)
//           .delete();
      
//       await fetchImages(noteId);
//     } catch (e) {
//       print('Error deleting image: $e');
//     }
//   }
// }