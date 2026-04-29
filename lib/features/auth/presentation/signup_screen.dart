import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String? _selectedCity;
  String? _selectedDistrict;

  // Somalia cities and their districts
  static const Map<String, List<String>> _cityDistricts = {
    'Mogadishu': [
      'Abdiaziz', 'Bondhere', 'Daynile', 'Dharkenley', 'Hamar-Jajab',
      'Hamar-Weyne', 'Hodan', 'Howlwadag', 'Karan', 'Shangani',
      'Shibis', 'Waberi', 'Wadajir', 'Wardhigley', 'Yaqshid',
    ],
    'Hargeisa': [
      'Hargeisa Central', 'Ahmed Dhagah', 'Ga\'an Libah', 'Mohamoud Haibe', 'Ayaha',
    ],
    'Kismayo': [
      'Kismayo Central', 'Farjano', 'Dalxiiska', 'Alanley',
    ],
    'Baidoa': [
      'Baidoa Central', 'Bulo-Gaduud', 'Dinsoor', 'Qansaxdhere',
    ],
    'Garowe': [
      'Garowe Central', 'Xaafuun', 'Burtinle',
    ],
    'Bosaso': [
      'Bosaso Central', 'Qandala', 'Caluula', 'Iskushuban',
    ],
    'Berbera': [
      'Berbera Central', 'Sheikh', 'Oodweyne',
    ],
    'Merca': [
      'Merca Central', 'Baraawe', 'Qoryooley',
    ],
    'Beledweyne': [
      'Beledweyne Central', 'Buloburde', 'Jalalaqsi',
    ],
    'Jowhar': [
      'Jowhar Central', 'Jalalaqsi', 'Balcad',
    ],
  };

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nationalIdCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _error = "Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await ref.read(authProvider.notifier).signup(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            nationalId: _nationalIdCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
            city: _selectedCity ?? '',
            district: _selectedDistrict ?? '',
          );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        // Show success and move back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Account created! Please check your email for verification.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Back to login
      } else {
        setState(() => _error = "Signup failed. Please try again.");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().contains('already-in-use')
              ? "This email is already registered."
              : "An error occurred. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Text(
                  "CREATE ACCOUNT",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Join the community safety network",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),
                _InputField(
                  controller: _nameCtrl,
                  label: "Full Name",
                  hint: "Ex: Ahmed Ali",
                ),
                _InputField(
                  controller: _nationalIdCtrl,
                  label: "National ID (Optional)",
                  hint: "12345678901",
                  required: false,
                ),
                // ── City Dropdown ──
                _DropdownField(
                  label: 'City',
                  value: _selectedCity,
                  items: _cityDistricts.keys.toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCity = val;
                      _selectedDistrict = null; // reset district when city changes
                    });
                  },
                ),
                // ── District Dropdown ──
                _DropdownField(
                  label: 'District',
                  value: _selectedDistrict,
                  items: _selectedCity != null
                      ? (_cityDistricts[_selectedCity] ?? [])
                      : [],
                  hint: _selectedCity == null
                      ? 'Select a city first'
                      : 'Select district',
                  onChanged: _selectedCity == null
                      ? null
                      : (val) => setState(() => _selectedDistrict = val),
                ),
                _InputField(
                  controller: _phoneCtrl,
                  label: "Phone",
                  hint: "+252 61XXXXXXX",
                ),
                _InputField(
                  controller: _emailCtrl,
                  label: "Email",
                  hint: "email@example.com",
                  keyboardType: TextInputType.emailAddress,
                ),
                _InputField(
                  controller: _passwordCtrl,
                  label: "Password",
                  hint: "••••••••",
                  obscure: true,
                ),
                _InputField(
                  controller: _confirmPasswordCtrl,
                  label: "Confirm Password",
                  hint: "••••••••",
                  obscure: true,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            "Create Account",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already a member? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final bool required;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.required = true,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            validator: (v) {
              if (!required) return null;
              if (v == null || v.isEmpty) return "Required field";
              if (label.toLowerCase() == "email") {
                if (!v.contains('@') || !v.contains('.')) return "Invalid email";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String? hint;
  final ValueChanged<String?>? onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: hint ?? 'Select $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Please select a $label' : null,
            onChanged: onChanged,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
