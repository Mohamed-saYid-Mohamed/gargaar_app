import 'package:flutter/material.dart';
import 'records_screen.dart';
import '../../calls/presentation/call_history_screen.dart';
import '../presentation/records_analysis_screen.dart';

class RecordsShellScreen extends StatefulWidget {
  const RecordsShellScreen({super.key});

  @override
  State<RecordsShellScreen> createState() => _RecordsShellScreenState();
}

class _RecordsShellScreenState extends State<RecordsShellScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Reports'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecordsAnalysisScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _RecordsTabs(
            index: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: const [
                RecordsScreen(), // REPORTS
                CallHistoryScreen(), // CALL HISTORY
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordsTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _RecordsTabs({
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _tab('Reports', 0),
            _tab('Call History', 1),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int i) {
    final selected = index == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
