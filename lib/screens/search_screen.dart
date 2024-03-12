import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iwalle/services/firestore_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSubmit(String value) {
    final searchValue = value.toLowerCase().trim();
    firestoreService.walletEntriesRef
        .where(
          Filter.or(
            Filter('name', whereIn: [searchValue]),
            Filter('walletId', whereIn: [searchValue]),
          ),
        )
        .get()
        .then((values) {
      setState(() {
        _searchResults =
            values.docs.map((e) => {'id': e.id, ...e.data()}).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              onSubmitted: _onSubmit,
              controller: _searchController,
              autocorrect: true,
              autofocus: true,
              cursorColor: Colors.purple,
              enableSuggestions: true,
              keyboardAppearance: Brightness.light,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
                hintText: 'Search',
              ),
            ),
            const SizedBox(height: 20),
            if (_searchResults.isNotEmpty)
              Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        'Entries',
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
                  Column(
                    children: _searchResults.map(_buildSearchTile).toList(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTile(Map<String, dynamic> e) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        tileColor: Colors.purple[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(e['name'],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          e['description'],
          style: const TextStyle(fontSize: 10),
        ),
        leading:
            Text('${e['date'].toDate().day} / ${e['date'].toDate().month}'),
        trailing: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(e['amount'].toString()),
            Text(
              e['walletId'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
