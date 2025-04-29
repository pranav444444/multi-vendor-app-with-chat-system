import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:multi_vendor_app/controllers/categories__controller.dart';
import 'package:multi_vendor_app/views/screens/auth/welcome_screens/welcome_register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      if (Platform.isAndroid) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyBQAVBwdraZWgnVIWfEfFhV6VjmeDslYrE',
            appId: '1:173942864540:android:f9a046310da2199fdb0b59',
            messagingSenderId: '173942864540',
            projectId: 'my-app-d565f',
            storageBucket: 'gs://my-app-d565f.firebasestorage.app',
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    }
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 250, 41, 184)),
        useMaterial3: true,
      ),
      home: WelcomeRegisterScreen(),
      initialBinding: BindingsBuilder(() {
        Get.put<CategoryController>(CategoryController()); // Ensure controller is bound
      }),
    );
  }
}
