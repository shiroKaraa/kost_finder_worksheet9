import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_keys.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // CATATAN KEAMANAN:
  // anonKey (publishable key) di bawah ini AMAN ditanam di aplikasi klien.
  // Kunci ini hanya berperan sebagai identitas proyek dan berjalan dengan
  // peran "anon" (belum login), sehingga TIDAK bisa melewati Row Level Security.
  // Keamanan data sepenuhnya bergantung pada kebijakan RLS yang diatur di Supabase.
  // Yang TIDAK BOLEH ada di aplikasi Flutter adalah service_role key / secret key,
  // karena kunci tersebut melewati RLS dan membocorkan seluruh data.
  await Supabase.initialize(
    url: 'https://uovjjhtutaljzalqjufa.supabase.co',
    anonKey: 'sb_publishable_R2DIWN4xm7MPKExAefmEuQ_PsYsOHF7',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    debugPrint('Auth event: ${data.event}');
    if (data.event == AuthChangeEvent.signedOut) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  });

  NotificationService.instance.setupInteractedMessage();

  runApp(const KostFinderApp());
}

class KostFinderApp extends StatelessWidget {
  const KostFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kost Finder',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      home: AuthService.instance.isLoggedIn
          ? const HomePage()
          : const LoginPage(),
    );
  }
}