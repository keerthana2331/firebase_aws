// ignore_for_file: prefer_final_fields, avoid_print

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesProvider with ChangeNotifier {
  bool _isGridView = true;
  List<QueryDocumentSnapshot> _notes = [];
  bool _isLoading = false;
  List<Color> noteColors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.orange];

  bool get isGridView => _isGridView;
  List<QueryDocumentSnapshot> get notes => _notes;
  bool get isLoading => _isLoading;

  void toggleView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

 Future<String> addNote(String title, String content) async {
  try {
    // Add the color index randomly or sequentially
    int colorIndex = Random().nextInt(noteColors.length);
    
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('notes')
        .add({
      'title': title,
      'content': content,
      'userEmail': FirebaseAuth.instance.currentUser?.email,
      'timestamp': FieldValue.serverTimestamp(),
      'colorIndex': colorIndex,
    });
    
    return docRef.id; // Return the ID of the newly created note
  } catch (e) {
    print('Error adding note: $e');
    rethrow;
  }
}

  Future<void> updateNote(String id, String title, String content) async {
    try {
      await FirebaseFirestore.instance.collection('notes').doc(id).update({
        'title': title,
        'content': content,
        'lastModified': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      print('Error updating note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await FirebaseFirestore.instance.collection('notes').doc(id).delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  Stream<QuerySnapshot> getNotesStream() {
    return FirebaseFirestore.instance
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}