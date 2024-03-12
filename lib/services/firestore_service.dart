import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore instance = FirebaseFirestore.instance;

  final walletRef = FirebaseFirestore.instance.collection('wallets');
  final walletEntriesRef =
      FirebaseFirestore.instance.collection('walletEntries');
}

final FirestoreService firestoreService = FirestoreService();
