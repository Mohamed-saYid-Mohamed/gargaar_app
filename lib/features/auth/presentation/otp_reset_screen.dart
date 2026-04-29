import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/reset_provider.dart';
import 'new_password_screen.dart';

class OtpResetScreen extends ConsumerStatefulWidget {
  const OtpResetScreen({super.key});

  @override
  ConsumerState<OtpResetScreen> createState() => _OtpResetScreenState();
}

class _OtpResetScreenState extends ConsumerState<OtpResetScreen> {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  String get enteredOtp => controllers.map((c) => c.text).join();

  void _verify() {
    ref.read(resetProvider.notifier).verifyOtp(enteredOtp);

    final state = ref.read(resetProvider);

    if (state?.isOtpVerified == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NewPasswordScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(resetProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "Enter the 6-digit code sent to ${resetState?.identifier ?? ''}",
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextField(
                    controller: controllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verify,
              child: const Text("Verify"),
            ),
            const SizedBox(height: 24),
            if (resetState != null && resetState.resendSeconds > 0)
              Text(
                "Resend in "
                "${(resetState.resendSeconds ~/ 60).toString().padLeft(2, '0')}:"
                "${(resetState.resendSeconds % 60).toString().padLeft(2, '0')}",
              )
            else
              TextButton(
                onPressed: () => ref.read(resetProvider.notifier).resendOtp(),
                child: const Text("Resend OTP"),
              ),
          ],
        ),
      ),
    );
  }
}
