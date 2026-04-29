import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../state/providers.dart';
import '../../incidents/presentation/report_incident_screen.dart';

import '../../calls/state/call_provider.dart';
import '../../calls/models/call_record.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// ───────────────── EMERGENCY CALL HELPER ─────────────────
  Future<void> makeEmergencyCall(String number) async {
    final uri = Uri(scheme: 'tel', path: number);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch dialer';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(localizationProvider);

    final emergencyContacts = [
      _EmergencyContact(
        label: t.policeHotline,
        number: '888',
        color: const Color(0xFF4189DD),
        sub: t.priorityDispatch,
        service: 'Police',
      ),
      _EmergencyContact(
        label: t.ambulanceHotline,
        number: '777',
        color: const Color(0xFF10B981),
        sub: t.emergencyResponders,
        service: 'Ambulance',
      ),
      _EmergencyContact(
        label: t.fireHotline,
        number: '999',
        color: const Color(0xFFEF4444),
        sub: t.priorityDispatch,
        service: 'Fire',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
          child: Column(
            children: [
              _HeaderSection(t: t),
              const SizedBox(height: 32),
              _ReportNowButton(
                label: t.reportNow,
                sub: t.emergencyResponders,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportIncidentScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.emergencyContacts.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.grey,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: emergencyContacts.map((contact) {
                  return _EmergencyContactCard(
                    contact: contact,
                    onCall: () async {
                      // 1️⃣ Log call attempt FIRST
                      await ref.read(callHistoryProvider.notifier).addCall(
                            CallRecord(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              service: contact.service,
                              number: contact.number,
                              time: DateTime.now(),
                              status: 'completed', // later: missed / failed
                            ),
                          );

                      // 2️⃣ Open phone dialer
                      await makeEmergencyCall(contact.number);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ───────────────────────── HEADER ───────────────────────── */

class _HeaderSection extends StatelessWidget {
  final dynamic t;
  const _HeaderSection({required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4E6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.15),
                blurRadius: 24,
              ),
            ],
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            size: 56,
            color: Color(0xFFEF4444),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          t.appName.toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          t.slogan,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}

/* ─────────────────────── REPORT BUTTON ───────────────────── */

class _ReportNowButton extends StatelessWidget {
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _ReportNowButton({
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub.toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ─────────────────── EMERGENCY CONTACT CARD ───────────────── */

class _EmergencyContactCard extends StatelessWidget {
  final _EmergencyContact contact;
  final VoidCallback onCall;

  const _EmergencyContactCard({
    required this.contact,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: contact.color.withValues(alpha: 0.15),
          child: Icon(Icons.phone, color: contact.color),
        ),
        title: Text(
          contact.label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          contact.sub.toUpperCase(),
          style: const TextStyle(fontSize: 10),
        ),
        trailing: TextButton(
          onPressed: onCall,
          child: Text(
            contact.number,
            style: TextStyle(
              color: contact.color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

/* ───────────────────────── MODEL ───────────────────────── */

class _EmergencyContact {
  final String label;
  final String number;
  final Color color;
  final String sub;
  final String service;

  _EmergencyContact({
    required this.label,
    required this.number,
    required this.color,
    required this.sub,
    required this.service,
  });
}
