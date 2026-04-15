import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ConnektApp());
}

class ConnektApp extends StatelessWidget {
  const ConnektApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connekt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthProvider(),
    );
  }
}

