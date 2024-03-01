import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final walletEntryRef = FirebaseFirestore.instance.collection('walletEntries');
  List<Map<String, dynamic>> _entries = <Map<String, dynamic>>[];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  @override
  void initState() {
    getWalletEntries();
    super.initState();
  }

  Future<void> getWalletEntries() async {
    final user = authService.auth.currentUser;
    _subscription = walletEntryRef
        .where('userId', isEqualTo: user!.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        _entries = event.docs
            .map((e) => {
                  'id': e.id,
                  ...e.data(),
                })
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(
            height: 10,
          ),
          _buildEntryList(),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        tooltip: 'add entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEntryList() {
    return Column(
      children: _entries
          .map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: Key(entry['id']),
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    walletEntryRef.doc(entry['id']).delete();
                  },
                  child: ListTile(
                    tileColor: Colors.purple[50],
                    title: Text(
                      entry['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      entry['description'],
                      style: const TextStyle(fontSize: 10),
                    ),
                    leading: Text(
                        '${entry['date'].toDate().day} / ${entry['date'].toDate().month}'),
                    trailing: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(entry['amount'].toString()),
                        Text(
                          entry['walletId'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
