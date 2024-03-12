import 'package:flutter/material.dart';
import 'package:iwalle/services/auth_service.dart';
import 'package:iwalle/services/firestore_service.dart';
import 'package:iwalle/utils.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Map<String, dynamic>> _entries = <Map<String, dynamic>>[];
  List<String> _wallets = <String>[];
  double _total = 0;

  @override
  void initState() {
    getWalletEntries();
    super.initState();
  }

  Future<void> getWalletEntries() async {
    final user = await authService.currentUser;
    firestoreService.walletEntriesRef
        .orderBy('date', descending: true)
        .snapshots()
        .where((event) =>
            event.docs.any((element) => element['userId'] == user!.uid))
        .listen((event) {
      setState(() {
        _entries = event.docs.map((e) => {'id': e.id, ...e.data()}).toList();
        _wallets =
            event.docs.map((e) => e['walletId'].toString()).toSet().toList();
        _total = _entries.fold(0, (previousValue, element) {
          return double.parse(previousValue.toString()) + element['amount'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Row(
              children: [
                Text(
                  'Transactions',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_entries.isNotEmpty)
              Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _entries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(_entries[index]['name']),
                        subtitle:
                            Text(formatDate(_entries[index]['date'].toDate())),
                        trailing: Text(_entries[index]['amount'].toString()),
                      );
                    },
                  ),
                  const Divider(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        "Count: ${_entries.length.toString()}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        "Total ballance: ${_total.toString()}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Wallets: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      for (var wallet in _wallets)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            cap(wallet),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        )
                    ],
                  )
                ],
              )
            else
              const Center(
                child: Text('No transactions'),
              ),
          ],
        ),
      ),
    );
  }
}
