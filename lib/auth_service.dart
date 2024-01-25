import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInAnonymous() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      print('User credential: $userCredential');
      return userCredential;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

final AuthService authService = AuthService();
