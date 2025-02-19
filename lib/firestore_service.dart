import 'package:authenticationapp/models/listmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:flutter/foundation.dart'; // Import for File handling


class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance; // Initialize Firebase Storage

  // Fetch notes including image URLs
  Stream<List<Note>> getNotes() {
    return db.collection('notes').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Note.fromMap(doc.id, doc.data())).toList());
  }

  // Add a new note with an optional image
  Future<void> addNote(Note note, {File? image}) async {
    String? imageUrl;

    // If image is provided, upload it
    if (image != null) {
      imageUrl = await _uploadImage(image);
    }

    // Convert note to Map and add imageUrl if available
    Map<String, dynamic> noteData = note.toMap();
    if (imageUrl != null) {
      noteData['imageUrl'] = imageUrl;
    }

    await db.collection('notes').add(noteData);
  }

  // Update a note with a new image
  Future<void> updateNote(Note note, {File? image}) async {
    String? imageUrl;

    if (image != null) {
      imageUrl = await _uploadImage(image);
    }

    Map<String, dynamic> noteData = note.toMap();
    if (imageUrl != null) {
      noteData['imageUrl'] = imageUrl;
    }

    await db.collection('notes').doc(note.id).update(noteData);
  }

  // Delete a note and its associated image
  Future<void> deleteNote(String id, {String? imageUrl}) async {
    if (imageUrl != null) {
      await _deleteImage(imageUrl);
    }

    await db.collection('notes').doc(id).delete();
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage.ref().child('note_images/$fileName.jpg');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Delete image from Firebase Storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      await storage.refFromURL(imageUrl).delete();
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting image: $e");
      }
    }
  }
}
