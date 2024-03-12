import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iwalle/services/auth_service.dart';
import 'package:iwalle/services/firestore_service.dart';
import 'package:iwalle/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firestoreService = FirestoreService();
  List<Map<String, dynamic>> _entries = <Map<String, dynamic>>[];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  double _total = 0;

  @override
  void initState() {
    getWalletEntries();
    super.initState();
  }

  Future<void> getWalletEntries() async {
    final user = await authService.currentUser;
    _subscription = firestoreService.walletEntriesRef
        .orderBy('date', descending: true)
        .snapshots()
        .where((event) =>
            event.docs.any((element) => element['userId'] == user!.uid))
        .listen((event) {
      setState(() {
        _entries = event.docs.map((e) => {'id': e.id, ...e.data()}).toList();
        _total = _entries.fold(0, (previousValue, element) {
          return double.parse(previousValue.toString()) + element['amount'];
        });
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          if (_entries.isNotEmpty)
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                'Ballance:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _total.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            height: 20,
          ),
          const Row(
            children: [
              Text(
                'Latest added',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          _buildEntries(),
        ],
      ),
    );
  }

  Widget _buildEntries() {
    return Column(
      children: [
        for (var e in _entries)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Dismissible(
              background: Container(
                color: Colors.red,
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
              ),
              key: Key(e['id']),
              onDismissed: (direction) async {
                await firestoreService.walletEntriesRef.doc(e['id']).delete();
              },
              child: ListTile(
                tileColor: Colors.purple[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(cap(e['name']),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  e['description'],
                  style: const TextStyle(fontSize: 10),
                ),
                leading: Text(formatDate(e['date'].toDate())),
                trailing: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(e['amount'].toString()),
                    Text(
                      cap(e['walletId']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
