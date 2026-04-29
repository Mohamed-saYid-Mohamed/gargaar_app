import 'package:flutter/material.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  double strength = 0;

  void _checkStrength(String value) {
    double s = 0;

    if (value.length >= 6) s += 0.25;
    if (value.length >= 8) s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(value)) s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(value)) s += 0.25;

    setState(() => strength = s);
  }

  Color get strengthColor {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              onChanged: _checkStrength,
              decoration: const InputDecoration(
                hintText: "New password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: strength,
              color: strengthColor,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Confirm password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Reset Password"),
            )
          ],
        ),
      ),
    );
  }
}
