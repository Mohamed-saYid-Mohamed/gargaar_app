class OtpRepository {
  String? _generatedCode;

  Future<String> sendOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock 4 digit code
    _generatedCode = '1234';

    return _generatedCode!;
  }

  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return code == _generatedCode;
  }
}
