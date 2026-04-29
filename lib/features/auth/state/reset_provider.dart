import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetState {
  final String identifier;
  final String generatedOtp;
  final int resendSeconds;
  final bool isOtpVerified;

  const ResetState({
    required this.identifier,
    required this.generatedOtp,
    required this.resendSeconds,
    required this.isOtpVerified,
  });

  ResetState copyWith({
    String? identifier,
    String? generatedOtp,
    int? resendSeconds,
    bool? isOtpVerified,
  }) {
    return ResetState(
      identifier: identifier ?? this.identifier,
      generatedOtp: generatedOtp ?? this.generatedOtp,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
    );
  }
}

class ResetNotifier extends StateNotifier<ResetState?> {
  ResetNotifier() : super(null);

  void startReset(String identifier) {
    state = ResetState(
      identifier: identifier,
      generatedOtp: "123456", // mock
      resendSeconds: 120,
      isOtpVerified: false,
    );
    _startCountdown();
  }

  void verifyOtp(String entered) {
    if (state == null) return;

    if (entered == state!.generatedOtp) {
      state = state!.copyWith(isOtpVerified: true);
    }
  }

  void _startCountdown() {
    if (state == null) return;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      if (state == null || state!.resendSeconds == 0) {
        return false;
      }

      state = state!.copyWith(
        resendSeconds: state!.resendSeconds - 1,
      );

      return state!.resendSeconds > 0;
    });
  }

  void resendOtp() {
    if (state == null) return;

    state = state!.copyWith(
      generatedOtp: "123456",
      resendSeconds: 120,
    );

    _startCountdown();
  }

  void clear() => state = null;
}

final resetProvider =
    StateNotifierProvider<ResetNotifier, ResetState?>((ref) => ResetNotifier());
