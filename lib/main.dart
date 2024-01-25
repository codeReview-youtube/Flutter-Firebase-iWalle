import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iwalle/auth_service.dart';
import 'package:iwalle/firebase_options.dart';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("App started");
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } else {
    // for android: this will be initialized with the google-services.json file
    await Firebase.initializeApp();
  }
  print("Firebase initialized");
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
            seedColor: const Color.fromARGB(255, 86, 11, 217)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('User is logged in')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await authService.signInAnonymous();
        },
        tooltip: 'user',
        child: const Icon(Icons.person),
      ),
    );
  }
}
