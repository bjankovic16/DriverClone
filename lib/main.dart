import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_udemy_app/auth/signin_page.dart';
import 'package:project_udemy_app/pages/map_page.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isAndroid) {
    await Firebase.initializeApp(
      name: "projectUdemy",
      options: const FirebaseOptions(
          apiKey: "AIzaSyCWXjg9C8GF9tBmeji3pOhY7aBxO5r36Ps",
          authDomain: "projectudemy-3f1bc.firebaseapp.com",
          projectId: "projectudemy-3f1bc",
          storageBucket: "projectudemy-3f1bc.appspot.com",
          messagingSenderId: "1000301951759",
          appId: "1:1000301951759:web:1d5071dd2bdfda59271c7a"
      )
    );
  } else {
    await Firebase.initializeApp(
      name: "projectUdemy",
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser == null? SigninPage(): MapPage(),
    );
  }
}