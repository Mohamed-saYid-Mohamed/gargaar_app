import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../state/auth_provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/theme_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _needsVerification = false;

  /* ───────── LOGIN HANDLER ───────── */

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _error = null;
      _needsVerification = false;
    });

    final auth = ref.read(authProvider.notifier);

    final result = await auth.login(
      _identifierCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!result.success && mounted) {
      setState(() {
        _error = result.message ?? 'Invalid email or password';
        _needsVerification = result.needsVerification;
      });
    }
  }

  Future<void> _resendVerification() async {
    await ref.read(authProvider.notifier).resendVerificationEmail();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verification email sent again. Please check your inbox."),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  /* ───────── UI ───────── */

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final strings = ref.watch(languageProvider.notifier).strings;

    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              /* ───── LANGUAGE SWITCH ───── */

              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LangButton(
                        label: 'EN',
                        selected: lang == 'en',
                        onTap: () => ref
                            .read(languageProvider.notifier)
                            .setLanguage('en'),
                      ),
                      _LangButton(
                        label: 'SO',
                        selected: lang == 'so',
                        onTap: () => ref
                            .read(languageProvider.notifier)
                            .setLanguage('so'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              /* ───── LOGO ───── */

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.brightness_6),
                    onPressed: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings['appName'] ?? 'Gargaar',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        strings['slogan'] ?? 'Emergency Support',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Text(
                        strings['welcome'] ?? 'Welcome',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      /* ───── ERROR BOX ───── */

                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_needsVerification) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: _resendVerification,
                                    icon: const Icon(Icons.email_outlined, size: 16),
                                    label: const Text("Resend Verification Email"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.centerLeft,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                      /* ───── IDENTIFIER ───── */

                      _InputField(
                        controller: _identifierCtrl,
                        label: strings['emailPhone'] ?? 'Email / Phone',
                        hint: lang == 'en'
                            ? 'Email or phone'
                            : 'Email ama taleefan',
                      ),
                      const SizedBox(height: 16),

                      /* ───── PASSWORD ───── */

                      _InputField(
                        controller: _passwordCtrl,
                        label: strings['password'] ?? 'Password',
                        hint: '••••••••',
                        obscure: true,
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text('Forgot password?'),
                        ),
                      ),

                      /* ───── LOGIN BUTTON ───── */

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 6,
                          ),
                          child: Text(
                            strings['signIn'] ?? 'Sign In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      /* ───── SIGNUP ───── */

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            strings['newHere'] ?? 'New here?',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: Text(
                              strings['signUp'] ?? 'Sign Up',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ─────────────────── SMALL WIDGETS ─────────────────── */

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          ),
        ),
      ],
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}
