import 'package:local_auth/local_auth.dart';

class LockService {
  LockService._();
  static final instance = LockService._();

  final _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final canCheck =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canCheck) return false;
      return await _auth.authenticate(
        localizedReason: 'unclock this note',
        biometricOnly: false,
      );
    } catch (_) {
      return false;
    }
  }
}
