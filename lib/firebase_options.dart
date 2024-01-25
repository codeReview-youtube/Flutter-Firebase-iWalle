import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMugXcxgCN6-2KTjngr71CrOTXjyX47Lo',
    appId: '1:176775409282:ios:4c3c40b181e5e682da8e9b',
    messagingSenderId: '176775409282',
    projectId: 'iwalle',
    // databaseURL:
    // 'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
    // storageBucket: 'flutterfire-e2e-tests.appspot.com',
    // androidClientId:
    // '406099696497-tvtvuiqogct1gs1s6lh114jeps7hpjm5.apps.googleusercontent.com',
    // iosClientId:
    // '406099696497-taeapvle10rf355ljcvq5dt134mkghmp.apps.googleusercontent.com',
    iosBundleId: 'io.codereview.iwalle',
  );
}
