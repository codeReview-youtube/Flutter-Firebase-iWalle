import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:iwalle/screens/add_screen.dart';
import 'package:iwalle/services/auth_service.dart';
import 'package:iwalle/firebase_options.dart';

import 'package:iwalle/screens/home_screen.dart';
import 'package:iwalle/screens/login_screen.dart';
import 'package:iwalle/screens/profile_screen.dart';
import 'package:iwalle/screens/search_screen.dart';
import 'package:iwalle/screens/stats_screen.dart';

const bool useEmulator = false;
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
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  if (useEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeStateApp(),
        '/auth': (context) => const LoginScreen()
        // '/add': (context) => const AddScreen(),
      },
    );
  }
}

class HomeStateApp extends StatefulWidget {
  const HomeStateApp({super.key});

  @override
  State<HomeStateApp> createState() => HomeStateAppState();
}

class HomeStateAppState extends State<HomeStateApp> {
  int _selectedTab = 0;

  @override
  void initState() {
    checkAuthState();
    super.initState();
  }

  void checkAuthState() {
    authService.authStateChanges.listen((User? user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
  }

  final List<Map<String, dynamic>> _screens = [
    {
      "label": "Home",
      "appBar": const Text('Home'),
      "body": const HomeScreen(),
      "icon": Icons.home,
      "activeIcon": Icons.home_filled
    },
    {
      "label": "Search",
      "appBar": const Text('Search wallets'),
      "body": const SearchScreen(),
      "icon": Icons.search,
      "activeIcon": Icons.search_sharp
    },
    {
      "label": "Add",
      "appBar": const Text('Add Entry'),
      "body": const AddScreen(),
      "icon": Icons.add,
      "activeIcon": Icons.add_circle_sharp
    },
    {
      "label": "Stats",
      "appBar": const Text('Statistics'),
      "body": const StatsScreen(),
      "icon": Icons.money,
      "activeIcon": Icons.money_off
    },
    {
      "label": "Profile",
      "appBar": const Text('My Profile'),
      "body": const ProfileScreen(),
      "icon": Icons.person,
      "activeIcon": Icons.person_outline
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _screens[_selectedTab]["appBar"],
      ),
      body: _screens[_selectedTab]["body"],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: _screens
            .map(
              (e) => BottomNavigationBarItem(
                icon: Icon(e["icon"] as IconData),
                label: e["label"] as String,
                activeIcon: Icon(e["activeIcon"], color: Colors.purple),
              ),
            )
            .toList(),
        currentIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
      ),
    );
  }
}
