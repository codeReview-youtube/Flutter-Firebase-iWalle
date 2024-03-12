import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class LogService {
  final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  Future<void> logError({
    required String reason,
    dynamic exception,
    dynamic stackTrace,
    fatal = false,
  }) async {
    await crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      printDetails: true,
      fatal: fatal,
    );
  }

  Future<void> logMessage({
    required String message,
  }) async {
    await crashlytics.log(message);
  }

  Future<void> setUserId({
    required String userId,
  }) async {
    await crashlytics.setUserIdentifier(userId);
  }

  Future<void> setCustomKey({
    required String key,
    required String value,
  }) async {
    await crashlytics.setCustomKey(key, value);
  }
}

final LogService logService = LogService();
