import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letsmeet/screens/home.dart';
import 'package:letsmeet/screens/login_screen.dart';
import 'package:letsmeet/screens/new_meeting.dart';
import 'package:letsmeet/screens/onboarding/introduction_page.dart';
import 'package:letsmeet/screens/profile.dart';
import 'package:letsmeet/screens/speech_translate.dart';
import 'package:letsmeet/screens/video_call_zego.dart';
import 'package:letsmeet/utils/ThemeProvider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebase();

  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: const FirebaseOptions(
          appId: '1:270549215024:web:6c416fc9183214db6d8af5',
          apiKey: 'AIzaSyDqZUp-WFfAz1WmZikBzJJb8xcCNT67UcY',
          projectId: 'image-ai-e609e',
          messagingSenderId: '270549215024',
        ),
      );
    } else {
      Platform.isAndroid ? await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCmTywTZWB6tuzTJfpLQ-hMNoCdfgGB3YA', 
          appId: '1:270549215024:android:7a7025748e94404d6d8af5', 
          messagingSenderId: "270549215024", 
          projectId: 'image-ai-e609e'),

      ):await Firebase.initializeApp();
    }
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return GetMaterialApp(
            title: "Leet's Meet",
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            routes: _routes(),
            home: _getInitialScreen(),
          );
        },
      ),
    );
  }

  Map<String, Widget Function(BuildContext)> _routes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/home': (context) => const HomeScreen(),
      '/profile': (context) => const EditProfile(),
      '/new_meeting': (context) => NewMeetingDialog(),
      '/speech_page': (context) => SpeechTranslate(),
      '/videoCall': (context) {
        final meetingCode = Get.arguments as String?;
        return VideoCallZ(
          channelName: meetingCode ?? '',
          conferenceID: meetingCode ?? '',
          role: Role.Audience, // Adjust based on your logic
        );
      },
    };
  }

  Widget _getInitialScreen() {
    User? user = FirebaseAuth.instance.currentUser;
    return user == null ? IntroductionPage() : const HomeScreen();
  }
}
