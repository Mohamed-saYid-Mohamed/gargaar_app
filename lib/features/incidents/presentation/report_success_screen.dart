import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/providers.dart';
import 'report_tracking_screen.dart';
import '../models/report_status.dart';
import '../../chat/presentation/incident_chat_screen.dart';

const Color kPrimaryRed = Color(0xFFEF4444);
const Color kPrimaryBlue = Color(0xFF4189DD);

class ReportSuccessScreen extends ConsumerWidget {
  const ReportSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportId = ref.watch(reportIdProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryBlue.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: kPrimaryBlue,
                  size: 80,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Report Submitted',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Report ID (NOW VISIBLE)
              if (reportId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Report ID: $reportId',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Description
              const Text(
                'Thank you for reporting the incident.\nAuthorities will respond as soon as possible.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // Track button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.track_changes),
                  label: const Text('Track Report Status'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportTrackingScreen(
                          status: ReportStatus.submitted,
                          incidentId: reportId,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Chat button
              if (reportId != null)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton.icon(
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Chat with Admin'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IncidentChatScreen(
                            incidentId: reportId,
                            status: 'Submitted',
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // Back to Home
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
