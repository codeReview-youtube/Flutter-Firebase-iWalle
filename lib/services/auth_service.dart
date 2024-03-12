import 'package:firebase_auth/firebase_auth.dart';
import 'package:iwalle/services/log_service.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserCredential?> signInAnonymous() async {
    try {
      UserCredential userCredential = await auth.signInAnonymously();
      print('User credential: $userCredential');
      return userCredential;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> verifyEmail() async {
    await auth.currentUser!.sendEmailVerification();
  }

  Future<UserCredential?> signOrCreateUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredentials = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredentials.user != null &&
          !userCredentials.user!.emailVerified) {
        await userCredentials.user!.sendEmailVerification();
      }
      return userCredentials;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        UserCredential userCredentials =
            await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (userCredentials.user != null) {
          await userCredentials.user!.sendEmailVerification();
        }
        return userCredentials;
      }
      logService.logError(
        reason: 'Sign in or create user failed',
        exception: e,
        stackTrace: e.stackTrace,
        fatal: true,
      );
      return null;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<User?> get currentUser async {
    return auth.currentUser;
  }

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<void> deleteAccount() async {
    await auth.currentUser!.delete();
  }
}

final AuthService authService = AuthService();
