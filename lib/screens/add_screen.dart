import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iwalle/services/auth_service.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final walletRef = FirebaseFirestore.instance.collection('wallets');
  final walletEntriesRef =
      FirebaseFirestore.instance.collection('walletEntries');
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<Map<String, dynamic>> _wallets = <Map<String, dynamic>>[];
  bool _existingWallet = true;
  final TextEditingController _walletNameController = TextEditingController();
  final TextEditingController _walletCategoryController =
      TextEditingController();
  final TextEditingController _walletDescriptionController =
      TextEditingController();
  final TextEditingController _walletAmountController = TextEditingController();

  List<String> _dropdownList = <String>['placeholder'];
  String _selectedWallet = 'placeholder';
  String _userId = '';

  @override
  void initState() {
    getWalletEntries();
    super.initState();
  }

  Future<void> getWalletEntries() async {
    final user = await authService.currentUser;
    _subscription = await walletEntriesRef
        .where('userId', isEqualTo: user!.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        _dropdownList = _wallets.map((e) => e['name'] as String).toList();
        _selectedWallet = _dropdownList.first;
        _userId = user.uid;
        _wallets = event.docs
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
    _walletAmountController.dispose();
    _walletCategoryController.dispose();
    _walletDescriptionController.dispose();
    _walletNameController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Wallet Entry'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Create new wallet or expand your existing wallet(s)',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                      value: _existingWallet,
                      onChanged: (value) {
                        setState(() {
                          _existingWallet = value as bool;
                        });
                      }),
                  const Text(
                    'Add to existing wallet',
                  ), // Todo: bring existing wallet name and show it here. case also of multiple
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: _existingWallet ? 'Entry name' : 'Wallet name',
                ),
                controller: _walletNameController,
              ),
              const SizedBox(height: 20),
              if (_existingWallet)
                Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select wallet'),
                      _buildDropDown(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _walletAmountController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _walletDescriptionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Short description',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _walletCategoryController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ElevatedButton(
                onPressed: _addWallet,
                child: const Text('Add'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _addWallet() {
    if (_existingWallet) {
      final wallet = {
        'name': _walletNameController.text,
        'category': _walletCategoryController.text,
        'description': _walletDescriptionController.text,
        'amount': double.parse(_walletAmountController.text),
        'userId': _userId,
        'walletId': _selectedWallet,
        'date': Timestamp.now(),
      };
      walletEntriesRef.add(wallet).then((id) {
        updateExistingWallet();
        clearFieldsAndNavigate();
      }).onError((error, stackTrace) {
        print('error adding wallet entry: $error');
      });
    } else {
      final wallet = {
        'name': _walletNameController.text,
        'totalBallance': 0,
        'userId': _userId,
        'date': Timestamp.now(),
      };
      walletRef.add(wallet).then((id) {
        print('add wallet: $id');
        clearFieldsAndNavigate();
      }).onError((error, stackTrace) {
        print('error adding wallet: $error');
      });
    }
  }

  Future<void> updateExistingWallet() async {
    final wallet = _wallets.firstWhere(
      (element) => element['name'] == _selectedWallet,
    );

    final updatedAmount =
        double.parse(wallet['totalBallance'].toString().trim()) +
            double.parse(_walletAmountController.text.trim());
    return walletRef.doc(wallet['id']).update({'totalBallance': updatedAmount});
  }

  void clearFieldsAndNavigate() {
    _walletNameController.clear();
    _walletCategoryController.clear();
    _walletDescriptionController.clear();
    _walletAmountController.clear();
    Navigator.pop(context);
  }

  Widget _buildDropDown() {
    return DropdownButton<String>(
      value: _selectedWallet,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        setState(() {
          _selectedWallet = value!;
        });
      },
      items: _dropdownList.map<DropdownMenuItem<String>>((e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        );
      }).toList(),
    );
  }
}
