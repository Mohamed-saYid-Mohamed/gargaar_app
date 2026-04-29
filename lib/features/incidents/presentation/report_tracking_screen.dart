import 'package:flutter/material.dart';
import '../models/report_status.dart';
import '../../chat/presentation/incident_chat_screen.dart';

const Color kPrimaryBlue = Color(0xFF4189DD);
const Color kPrimaryRed = Color(0xFFEF4444);

class ReportTrackingScreen extends StatelessWidget {
  final ReportStatus status;
  final String? incidentId;
  final String? incidentType;

  const ReportTrackingScreen({
    super.key,
    required this.status,
    this.incidentId,
    this.incidentType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Status'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _statusTimeline(),
            const SizedBox(height: 40),
            _statusMessage(),
            const Spacer(),
            if (incidentId != null) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IncidentChatScreen(
                          incidentId: incidentId!,
                          incidentType: incidentType,
                          status: status.label,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat with Admin'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryBlue,
                    side: const BorderSide(color: kPrimaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
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
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTimeline() {
    return Column(
      children: ReportStatus.values.map((step) {
        final isCompleted = step.stepIndex <= status.stepIndex;
        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? kPrimaryBlue : Colors.grey.shade300,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                if (step != ReportStatus.cancelled)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? kPrimaryBlue : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Text(
              step.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _statusMessage() {
    switch (status) {
      case ReportStatus.pending:
        return const Text(
          'Your report is pending review.',
          textAlign: TextAlign.center,
        );
      case ReportStatus.submitted:
        return const Text(
          'Your report has been received and is being reviewed.',
          textAlign: TextAlign.center,
        );
      case ReportStatus.responding:
        return const Text(
          'Emergency units are responding to the incident.',
          textAlign: TextAlign.center,
        );
      case ReportStatus.resolved:
        return const Text(
          'The incident has been resolved. Thank you for your cooperation.',
          textAlign: TextAlign.center,
        );
      case ReportStatus.cancelled:
        return const Text(
          'This report has been cancelled.',
          textAlign: TextAlign.center,
        );
    }
  }
}
