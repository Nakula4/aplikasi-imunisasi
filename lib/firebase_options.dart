import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDp0uoEdd8M82cbaveehd9T3YDpB1ZFPO0',
    appId: '1:466468445341:web:6c2c6d4c8571c7a53f4874',
    messagingSenderId: '466468445341',
    projectId: 'imunisasiku-1abc0',
    authDomain: 'imunisasiku-1abc0.firebaseapp.com',
    storageBucket: 'imunisasiku-1abc0.firebasestorage.app',
    measurementId: 'G-MB5TTXB9WY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJ70A-aySIOVW2WiI_IP4HQ08SFVP097E',
    appId: '1:466468445341:android:0cc7bbd9f5f5b6ae3f4874',
    messagingSenderId: '466468445341',
    projectId: 'imunisasiku-1abc0',
    storageBucket: 'imunisasiku-1abc0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCqcXc4t-pEQpG0zc7wwQKqCNR9v_IjizA',
    appId: '1:466468445341:ios:4e2760aab33a6ed23f4874',
    messagingSenderId: '466468445341',
    projectId: 'imunisasiku-1abc0',
    storageBucket: 'imunisasiku-1abc0.firebasestorage.app',
    iosBundleId: 'com.example.imunisasiku',
  );
}
