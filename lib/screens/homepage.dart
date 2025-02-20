/// home.dart
// ignore_for_file: unused_local_variable

import 'package:authenticationapp/providers/homescreenprovider.dart';
import 'package:authenticationapp/screens/imageupload.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:authenticationapp/screens/loginpage.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static const List<Color> noteColors = [
    Color(0xFFffab91),
    Color(0xFFfff59d),
    Color(0xFFb2dfdb),
    Color(0xFFe1bee7),
    Color(0xFFbbdefb),
    Color(0xFFf8bbd0),
  ];

  Future<void> logOut(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Log Out',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange.shade400,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade400,
                  Colors.deepOrange.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                backgroundColor: Colors.transparent,
              ),
              child: Text(
                'Log Out',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await FirebaseAuth.instance.signOut();
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully logged out',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(10),
          ),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LogIn()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error logging out. Please try again.',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.deepOrange.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    }
  }

  Future<String?> addOrUpdateNote(BuildContext context,
      {String? id, String? currentTitle, String? currentContent}) async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    String? title = currentTitle;
    String? content = currentContent;
    final titleController = TextEditingController(text: currentTitle);
    final contentController = TextEditingController(text: currentContent);
    String? createdNoteId;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.yellow.shade50,
                Colors.orange.shade50,
                Colors.deepOrange.shade50,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.orange.shade700,
                    Colors.deepOrange.shade900,
                  ],
                ).createShader(bounds),
                child: Text(
                  id == null ? 'New Note' : 'Edit Note',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(15),
                  ),
                  style: GoogleFonts.poppins(),
                  onChanged: (value) => title = value,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Write your note here...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(15),
                  ),
                  style: GoogleFonts.poppins(),
                  onChanged: (value) => content = value,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.deepOrange.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (title?.isNotEmpty == true && content?.isNotEmpty == true) {
                          if (id == null) {
                            // Add the note and get the ID
                            createdNoteId = await notesProvider.addNote(title!, content!);
                            Navigator.pop(context);
                          } else {
                            await notesProvider.updateNote(id, title!, content!);
                            Navigator.pop(context);
                          }
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please add both title and description',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                              backgroundColor: Colors.deepOrange.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)
                              ),
                              margin: const EdgeInsets.all(10),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        id == null ? 'Add Note' : 'Save Changes',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    return createdNoteId; // Return the ID of the created note, or null if editing or canceled
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LogIn()), 
          (route) => false
        );
        return false;
      },
      child: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.yellow.shade100,
                    Colors.orange.shade100,
                    Colors.deepOrange.shade100,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.deepOrange.shade400,
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LogIn()), 
                                    (route) => false
                                  );
                                },
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.orange.shade700,
                                    Colors.deepOrange.shade900,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  "My Notes",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  notesProvider.isGridView
                                      ? Icons.view_list
                                      : Icons.grid_view,
                                  color: Colors.deepOrange.shade400,
                                ),
                                onPressed: () => notesProvider.toggleView(),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade400,
                                      Colors.deepOrange.shade400,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => logOut(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('notes')
                            .where('userEmail', isEqualTo: FirebaseAuth.instance.currentUser?.email)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepOrange.shade400,
                                ),
                              ),
                            );
                          }

                          if (FirebaseAuth.instance.currentUser == null) {
                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 1000),
                              builder: (context, double value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.login_rounded,
                                          size: 80,
                                          color: Colors.deepOrange.shade200,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Please Login First',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange.shade400,
                                          ),
                                        ),
                                        Text(
                                          'Sign in to view and create notes',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 1000),
                              builder: (context, double value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.note_add_rounded,
                                          size: 80,
                                          color: Colors.deepOrange.shade200,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No Notes Yet',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange.shade400,
                                          ),
                                        ),
                                        Text(
                                          'Tap + to create your first note',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          final notes = snapshot.data!.docs;

                          if (notesProvider.isGridView) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: notes.length,
                              itemBuilder: (context, index) {
                                final note = notes[index];
                                final noteData =
                                    note.data() as Map<String, dynamic>;
                                final colorIndex = noteData['colorIndex'] ??
                                    index % noteColors.length;

                                return buildNoteCard(context, note.id, noteData,
                                    noteColors[colorIndex]);
                              },
                            );
                          } else {
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: notes.length,
                              itemBuilder: (context, index) {
                                final note = notes[index];
                                final noteData =
                                    note.data() as Map<String, dynamic>;
                                final colorIndex = noteData['colorIndex'] ??
                                    index % noteColors.length;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: buildNoteCard(context, note.id, noteData,
                                      noteColors[colorIndex]),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade400,
                    Colors.deepOrange.shade400,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () async {
                  // Store the result of addOrUpdateNote which should return the noteId if a new note is created
                  final result = await addOrUpdateNote(context);
                  
                  // If result is not null, it means a new note was created
                  if (result != null) {
                    // Show popup asking if user wants to add images
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        title: Text(
                          'Add Images',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade400,
                          ),
                        ),
                        content: Text(
                          'Do you want to add images to this note?',
                          style: GoogleFonts.poppins(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'No',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade400,
                                  Colors.deepOrange.shade400,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                                // Navigate to image upload screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageUploadScreen(
                                      noteId: result,
                                      userEmail: FirebaseAuth.instance.currentUser?.email ?? ''
                                    )
                                  )
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                backgroundColor: Colors.transparent,
                              ),
                              child: Text(
                                'Yes',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: const Icon(Icons.add),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNoteCard(BuildContext context, String id,
      Map<String, dynamic> noteData, Color color) {
    final timestamp = noteData['timestamp'] as Timestamp?;
    final formattedTime = timestamp != null
        ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
        : 'Unknown Date';

    return GestureDetector(
      onTap: () => addOrUpdateNote(
        context,
        id: id,
        currentTitle: noteData['title'] as String?,
        currentContent: noteData['content'] as String?,
      ),
      onLongPress: () => deleteNoteDialog(context, id),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    noteData['title'] ?? 'Untitled',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => deleteNoteDialog(context, id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                noteData['content'] ?? '',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formattedTime,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteNoteDialog(BuildContext context, String id) async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Delete Note',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this note?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await notesProvider.deleteNote(id);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}