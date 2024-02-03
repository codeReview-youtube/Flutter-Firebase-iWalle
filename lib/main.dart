import 'dart:ui';
import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:iwalle/auth_service.dart';
import 'package:iwalle/firebase_options.dart';

import 'package:iwalle/home_screen.dart';
import 'package:iwalle/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } else {
    // for android: this will be initialized with the google-services.json file
    await Firebase.initializeApp();
  }

  print("Firebase initialized");
  // Enable during dev mode.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // .setCrashlyticsCollectionEnabled(!kDebugMode);
  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 90, 7, 232),
          primary: const Color.fromARGB(255, 90, 7, 232),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.data != null) {
            return const MyHomePage(title: 'IWalle');
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
