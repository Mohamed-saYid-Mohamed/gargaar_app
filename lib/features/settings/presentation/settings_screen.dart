import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/settings_storage.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

/* ───────── STEP 1A — STATE ───────── */

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final theme = await SettingsStorage.loadTheme();
    final lang = await SettingsStorage.loadLanguage();
    final notif = await SettingsStorage.loadNotifications();

    if (!mounted) return;

    if (theme != null) {
      ref.read(themeProvider.notifier).setTheme(
            theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
          );
    }

    setState(() {
      _notificationsEnabled = notif;
    });

    if (lang != null) {
      ref.read(languageProvider.notifier).setLanguage(lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageNotifier = ref.watch(languageProvider.notifier);
    final strings = languageNotifier.strings;
    final currentLang = ref.watch(languageProvider);

    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings['settings'] ?? 'Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /* ───────── Appearance ───────── */

          const _SectionTitle('Appearance'),
          _SwitchTile(
            title: 'Dark Mode',
            value: isDarkMode,
            onChanged: (v) async {
              ref
                  .read(themeProvider.notifier)
                  .setTheme(v ? ThemeMode.dark : ThemeMode.light);
              await SettingsStorage.saveTheme(v ? 'dark' : 'light');
            },
          ),
          const SizedBox(height: 24),

          /* ───────── Notifications ───────── */

          const _SectionTitle('Notifications'),
          _SwitchTile(
            title: 'Enable Notifications',
            value: _notificationsEnabled,
            onChanged: (v) async {
              setState(() => _notificationsEnabled = v);
              await SettingsStorage.saveNotifications(v);
            },
          ),
          const SizedBox(height: 24),

          /* ───────── Privacy ───────── */

          // const _SectionTitle('Privacy'),
          // _RadioTile(
          //   value: _locationPrivacy,
          //   options: const {
          //     'always': 'Always share location',
          //     'incident': 'Only during incident',
          //   },
          //   onChanged: (v) {
          //     setState(() => _locationPrivacy = v);
          //   },
          // ),
          const SizedBox(height: 24),

          /* ───────── Language ───────── */

          _SectionTitle(strings['language'] ?? 'Language'),
          Card(
            child: ListTile(
              title: Text(strings['language'] ?? 'Language'),
              subtitle: Text(
                currentLang == 'en' ? 'English' : 'Soomaali',
              ),
              trailing: const Icon(Icons.swap_horiz),
              onTap: () {
                final newLang = currentLang == 'en' ? 'so' : 'en';
                languageNotifier.setLanguage(newLang);
                SettingsStorage.saveLanguage(newLang);
              },
            ),
          ),
          const SizedBox(height: 24),

          /* ───────── Support ───────── */

          const _SectionTitle('Support'),
          _SimpleTile(
            title: 'Emergency Guidelines',
            onTap: () => _showEmergencyGuidelines(context),
          ),
          _SimpleTile(
            title: 'Contact Team',
            onTap: () => _showContactTeam(context),
          ),
        ],
      ),
    );
  }
}

/* ───────── STEP 1B — EMERGENCY GUIDELINES ───────── */

void _showEmergencyGuidelines(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Guidelines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _GuidelineItem('Stay calm and assess the situation'),
            _GuidelineItem('Move to a safe location if possible'),
            _GuidelineItem('Call emergency services immediately'),
            _GuidelineItem('Provide clear and accurate information'),
            _GuidelineItem('Follow instructions from responders'),
          ],
        ),
      );
    },
  );
}

class _GuidelineItem extends StatelessWidget {
  final String text;
  const _GuidelineItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────── STEP 1C — CONTACT TEAM ───────── */

void _showContactTeam(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _ContactRow(
              icon: Icons.email,
              label: 'Email',
              value: 'support@gargaar.app',
            ),
            SizedBox(height: 12),
            _ContactRow(
              icon: Icons.phone,
              label: 'Phone',
              value: '+252 61 0000000',
            ),
          ],
        ),
      );
    },
  );
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/* ───────── REUSABLE WIDGETS ───────── */

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

// Removed _RadioTile

class _SimpleTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _SimpleTile({
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
