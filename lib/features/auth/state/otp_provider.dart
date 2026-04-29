import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/otp_repository.dart';

final otpProvider = StateNotifierProvider<OtpNotifier, bool>((ref) {
  return OtpNotifier(OtpRepository());
});

class OtpNotifier extends StateNotifier<bool> {
  final OtpRepository _repository;

  OtpNotifier(this._repository) : super(false);

  Future<void> sendOtp(String phone) async {
    await _repository.sendOtp(phone);
  }

  Future<bool> verifyOtp(String code) async {
    final result = await _repository.verifyOtp(code);
    state = result;
    return result;
  }
}
