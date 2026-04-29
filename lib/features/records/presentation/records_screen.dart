import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import 'record_map_screen.dart';
import '../../incidents/models/report_status.dart';
import '../../incidents/presentation/report_tracking_screen.dart';
import '../../chat/presentation/incident_chat_screen.dart';
import '../models/incident_record.dart';
import '../state/records_provider.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  final AudioPlayer _player = AudioPlayer();

  String? _playingRecordId;

  //  FILTER STATE
  String _selectedTypeFilter = 'All';
  String _selectedStatusFilter = 'All';

  //  VIEW MORE STATE
  bool _showAllRecords = false;

  final List<String> _typeFilters = ['All', 'Accident', 'Fire', 'Crime'];
  final List<String> _statusFilters = [
    'All',
    'Submitted',
    'Responding',
    'Resolved',
    'Cancelled'
  ];

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  ReportStatus _mapStatus(String status) {
    final s = status.toLowerCase();
    if (s == 'responding' || s == 'in progress') return ReportStatus.responding;
    if (s == 'resolved' || s == 'solved') return ReportStatus.resolved;
    if (s == 'cancelled' || s == 'canceled') return ReportStatus.cancelled;
    return ReportStatus.submitted;
  }

  // 🎧 AUDIO TOGGLE
  Future<void> _togglePlay(IncidentRecord record) async {
    final path = record.audioPath;
    if (path == null) return;

    final file = File(path);
    if (!file.existsSync()) return;

    if (_playingRecordId == record.id) {
      await _player.stop();
      setState(() => _playingRecordId = null);
      return;
    }

    await _player.stop();
    await _player.setSourceDeviceFile(path);
    await _player.resume();

    setState(() => _playingRecordId = record.id);

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _playingRecordId = null);
      }
    });
  }

  // 🔍 RECORD ANALYSIS (COMPACT & SMART)
  Widget _recordAnalysis(IncidentRecord record) {
    String priority;
    Color priorityColor;

    switch (record.type) {
      case 'Fire':
        priority = 'High';
        priorityColor = Colors.red;
        break;
      case 'Crime':
        priority = 'High';
        priorityColor = Colors.deepOrange;
        break;
      case 'Accident':
        priority = 'Medium';
        priorityColor = Colors.orange;
        break;
      default:
        priority = 'Low';
        priorityColor = Colors.green;
    }

    String action;
    if (record.status == 'resolved') {
      action = 'Resolved • No action needed';
    } else if (priority == 'High') {
      action = 'Immediate response required';
    } else {
      action = 'Monitor & follow up';
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: priorityColor),
          const SizedBox(width: 4),
          Text(
            'Priority: $priority',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: priorityColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordsProvider);

    return Scaffold(
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          // 🔍 APPLY FILTERS
          final filteredRecords = records.where((r) {
            final typeOk = _selectedTypeFilter == 'All'
                ? true
                : r.type == _selectedTypeFilter;

            final statusOk = _selectedStatusFilter == 'All'
                ? true
                : r.status == _selectedStatusFilter;

            return typeOk && statusOk;
          }).toList();

          // 🔽 SHOW 3 BY DEFAULT
          final visibleRecords = _showAllRecords
              ? filteredRecords
              : filteredRecords.take(3).toList();

          return Column(
            children: [
              // 🔽 FILTER DROPDOWNS
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedTypeFilter,
                      items: _typeFilters
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedTypeFilter = v!;
                          _showAllRecords = false;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedStatusFilter,
                      items: _statusFilters
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedStatusFilter = v!;
                          _showAllRecords = false;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // 📋 RECORD LIST
              Expanded(
                child: visibleRecords.isEmpty
                    ? const Center(
                        child: Text('No reports for this filter'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: visibleRecords.length,
                        itemBuilder: (context, index) {
                          final record = visibleRecords[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (record.imagePath != null)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                    child: Image.file(
                                      File(record.imagePath!),
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // TYPE + STATUS
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            record.type,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ReportTrackingScreen(
                                                    status: _mapStatus(
                                                        record.status),
                                                    incidentId: record.id,
                                                    incidentType: record.type,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color:
                                                        Colors.blue.shade200),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons.track_changes,
                                                      size: 14,
                                                      color: Colors.blue),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    record.status.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 2),

                                      // ID + DATE
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'ID: ${record.id}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd MMM • HH:mm')
                                                .format(record.reportedAt),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      // DESCRIPTION
                                      Text(
                                        record.description,
                                        style: const TextStyle(fontSize: 13),
                                      ),

                                      // 🔍 ANALYSIS
                                      _recordAnalysis(record),

                                      const SizedBox(height: 6),

                                      // ACTIONS
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      RecordMapScreen(
                                                    latitude: record.latitude,
                                                    longitude: record.longitude,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Row(
                                              children: [
                                                Icon(Icons.location_on,
                                                    color: Colors.red,
                                                    size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                  'View',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => IncidentChatScreen(
                                                    incidentId: record.id,
                                                    incidentType: record.type,
                                                    status: record.status,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.chat_outlined, size: 16),
                                            label: const Text(
                                              'Open Chat',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          if (record.audioPath != null) ...[
                                            const SizedBox(width: 8),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                shape: const StadiumBorder(),
                                              ),
                                              onPressed: () =>
                                                  _togglePlay(record),
                                              icon: Icon(
                                                _playingRecordId == record.id
                                                    ? Icons.stop_circle
                                                    : Icons.play_circle,
                                                size: 16,
                                              ),
                                              label: Text(
                                                _playingRecordId == record.id
                                                    ? 'Playing'
                                                    : 'Audio',
                                                style: const TextStyle(
                                                    fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // 🔽 VIEW MORE / LESS
              if (filteredRecords.length > 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllRecords = !_showAllRecords;
                      });
                    },
                    child: Text(
                      _showAllRecords ? 'View less' : 'View more',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
