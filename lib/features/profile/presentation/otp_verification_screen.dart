import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/state/profile_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // =========================
  // Send OTP (Mock)
  // =========================
  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Mock API delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _otpSent = true;
      _isLoading = false;
    });
  }

  // =========================
  // Verify OTP (Mock Success)
  // =========================
  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Mock verification delay
    await Future.delayed(const Duration(seconds: 1));

    ref.read(profileProvider.notifier).updateEmail(_emailController.text);
    ref.read(profileProvider.notifier).verifyEmail();

    setState(() => _isLoading = false);

    Navigator.pop(context); // return to profile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // Step Indicator
            // =========================
            Text(
              _otpSent ? 'Enter OTP Code' : 'Enter Email Address',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // Email Input
            // =========================
            if (!_otpSent)
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  border: OutlineInputBorder(),
                ),
              ),

            // =========================
            // OTP Input
            // =========================
            if (_otpSent)
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP code',
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 24),

            // =========================
            // Action Button
            // =========================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _otpSent
                        ? _verifyOtp
                        : _sendOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
