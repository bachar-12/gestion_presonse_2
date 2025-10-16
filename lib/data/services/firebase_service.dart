import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool get initialized => _initialized;

  static FirebaseAuth get auth {
    if (!_initialized) {
      throw StateError('Firebase not initialized');
    }
    return FirebaseAuth.instance;
  }

  static FirebaseFirestore get db {
    if (!_initialized) {
      throw StateError('Firebase not initialized');
    }
    return FirebaseFirestore.instance;
  }

  static FirebaseStorage get storage {
    if (!_initialized) {
      throw StateError('Firebase not initialized');
    }
    return FirebaseStorage.instance;
  }

  static FirebaseMessaging get messaging {
    if (!_initialized) {
      throw StateError('Firebase not initialized');
    }
    return FirebaseMessaging.instance;
  }

  /// Tries to initialize Firebase.
  ///
  /// On web, you will need options (via `firebase_options.dart`). For now we
  /// catch and log to avoid crashing in skeleton mode.
  static Future<bool> ensureInitialized() async {
    if (_initialized) return true;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      return true;
    } catch (e) {
      // If running on web without options or without platform files, just log.
      // Replace with your own logging if needed.
      // ignore: avoid_print
      print('Firebase init skipped or failed: $e');
      _initialized = false;
      return false;
    }
  }
}
