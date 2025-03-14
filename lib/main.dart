// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables

import 'package:authenticationapp/providers/forgetpassword_provider.dart';
import 'package:authenticationapp/providers/homescreenprovider.dart';

import 'package:authenticationapp/providers/imageuploadscreen.dart';
import 'package:authenticationapp/screens/authwrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("\ud83d\udea8 Error initializing Firebase: $e");
  }
  await requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.photos,
  ].request();

  if (statuses[Permission.camera] != PermissionStatus.granted ||
      statuses[Permission.photos] != PermissionStatus.granted) {
    debugPrint("\u26a0\ufe0f Permissions denied: Camera or Photos");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthWrapper(),
    );
  }
}
