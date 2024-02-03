import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:iwalle/firebase_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: firebaseConfig.apiKey,
    appId: firebaseConfig.appId,
    messagingSenderId: firebaseConfig.messagingSenderId,
    projectId: firebaseConfig.projectId,
    iosBundleId: firebaseConfig.iosBundleId,
  );
}
