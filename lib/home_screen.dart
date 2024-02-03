import 'package:flutter/material.dart';
import 'package:iwalle/auth_service.dart';
import 'package:iwalle/log_service.dart';

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('User is logged in!'),
            FutureBuilder(
              future: authService.currentUser,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Column(
                    children: [
                      Text('User: ${snapshot.data!.email}'),
                      if (snapshot.data!.emailVerified)
                        ElevatedButton(
                          onPressed: () async {
                            await authService.verifyEmail();
                          },
                          child: const Text('Send Email Verification'),
                        ),
                    ],
                  );
                }
                return const Text(
                  'Could not get user email or signed anonymously',
                );
              },
            ),
            const SizedBox(
              height: 100,
            ),
            ElevatedButton(
              onPressed: () {
                logService.crashlytics.crash();
              },
              child: const Text('Send Crash example'),
            ),
            ElevatedButton(
              onPressed: () => throw Exception(),
              child: const Text('Throw Exception'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await authService.auth.signOut();
        },
        tooltip: 'user',
        child: const Icon(Icons.person),
      ),
    );
  }
}
