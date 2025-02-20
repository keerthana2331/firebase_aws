import 'package:authenticationapp/models/listmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Stream<List<Note>> getNotes() {
    return db.collection('notes').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Note.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> addNote(Note note, {File? image}) async {
    String? imageUrl;

    if (image != null) {
      imageUrl = await uploadImage(image);
    }

    Map<String, dynamic> noteData = note.toMap();
    if (imageUrl != null) {
      noteData['imageUrl'] = imageUrl;
    }

    await db.collection('notes').add(noteData);
  }

  Future<void> updateNote(Note note, {File? image}) async {
    String? imageUrl;

    if (image != null) {
      imageUrl = await uploadImage(image);
    }

    Map<String, dynamic> noteData = note.toMap();
    if (imageUrl != null) {
      noteData['imageUrl'] = imageUrl;
    }

    await db.collection('notes').doc(note.id).update(noteData);
  }

  Future<void> deleteNote(String id, {String? imageUrl}) async {
    if (imageUrl != null) {
      await deleteImage(imageUrl);
    }

    await db.collection('notes').doc(id).delete();
  }

  Future<String> uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage.ref().child('note_images/$fileName.jpg');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      await storage.refFromURL(imageUrl).delete();
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting image: $e");
      }
    }
  }
}
