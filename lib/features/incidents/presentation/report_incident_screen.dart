import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../state/providers.dart';
import '../../../core/services/audio_recording_service.dart';
import '../../records/models/incident_record.dart';
import '../../records/data/records_repository_provider.dart';
import '../../records/state/records_provider.dart';

import '../models/incident_type.dart';
import '../models/incident_location.dart';
import 'report_success_screen.dart';

const double kRadius = 20;
const Color kPrimaryRed = Color(0xFFEF4444);
const Color kPrimaryBlue = Color(0xFF4189DD);

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() =>
      _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  // ───────── LOCATION (AUTO) ─────────
  Position? _currentPosition;
  final bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  // ───────── VOICE ─────────
  final AudioRecordingService _audioService = AudioRecordingService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioFilePath;

  Future<void> _startVoiceRecording() async {
    final path = await _audioService.startRecording();
    if (path != null) {
      setState(() {
        _audioFilePath = path;
        recordedVoice = File(path);
        _isRecording = true;
      });
      print("VOICE RECORDED: ${recordedVoice!.path}");
    }
  }

  Future<void> _stopVoiceRecording() async {
    await _audioService.stopRecording();
    setState(() => _isRecording = false);
  }

  Future<void> _togglePlayback() async {
    if (_audioFilePath == null) return;

    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(_audioFilePath!));
      setState(() => _isPlaying = true);
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  // ───────── FORM STATE ─────────
  IncidentType? selectedType;
  String? priority;
  bool isAnonymous = false;

  final TextEditingController descriptionController = TextEditingController();

  // ───────── MEDIA ─────────
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  File? selectedVideo;
  File? recordedVoice;

  @override
  void dispose() {
    descriptionController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        selectedVideo = null;
      });
      print("IMAGE SELECTED: ${selectedImage!.path}");
    }
  }

  Future<void> pickVideo(ImageSource source) async {
    final picked = await _picker.pickVideo(source: source);
    if (picked != null) {
      setState(() {
        selectedVideo = File(picked.path);
        selectedImage = null;
      });
      print("VIDEO SELECTED: ${selectedVideo!.path}");
    }
  }

  // ───────── SUBMIT ─────────
  Future<void> _submitIncident() async {
    print("🚀 Submit button clicked");

    final description = descriptionController.text.trim();
    final hasText = description.isNotEmpty;
    final hasVoice = recordedVoice != null;

    // Log values as requested
    print("SELECTED IMAGE: $selectedImage");
    print("RECORDED VOICE: $recordedVoice");
    print("Values: $description, ${recordedVoice?.path}, $selectedType, $priority");

    if (selectedType == null || priority == null) {
      _showSnack('Please select incident type and priority');
      return;
    }

    if (!hasText && !hasVoice) {
      _showSnack('Provide text or voice description');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Report'),
        content: const Text('Submit this emergency report now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final location = IncidentLocation(
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
      );

      await ref.read(submitIncidentProvider.notifier).submitIncident(
            type: selectedType!,
            description: description,
            location: location,
            isAnonymous: isAnonymous,
            priority: priority!,
            imageFile: selectedImage,
            videoFile: selectedVideo,
            audioFile: recordedVoice,
          );

      // ✅ ADD TO LOCAL RECORDS (HISTORY)
      final record = IncidentRecord(
        id: ref.read(reportIdProvider) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: selectedType!.name,
        description: description,
        reportedAt: DateTime.now(),
        imagePath: selectedImage?.path,
        latitude: _currentPosition?.latitude ?? 0,
        longitude: _currentPosition?.longitude ?? 0,
        audioPath: recordedVoice?.path, // Local path
        status: 'submitted',
      );

      await ref.read(recordsRepositoryProvider).addRecord(record);
      ref.invalidate(recordsProvider);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ReportSuccessScreen(),
        ),
      );
    } catch (e) {
      // Error is already logged in provider, but can add extra here if needed
      _showSnack('Error saving incident: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(submitIncidentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _anonymousToggle(),
          const SizedBox(height: 20),
          _incidentTypeSection(),
          const SizedBox(height: 20),
          _prioritySection(),
          const SizedBox(height: 20),
          _descriptionSection(),
          const SizedBox(height: 20),
          _mediaSection(),
          const SizedBox(height: 30),
          _autoLocationInfo(),
          const SizedBox(height: 30),
          _submitButton(submitState),
        ],
      ),
    );
  }

// ---------------- SECTIONS ----------------

  Widget _anonymousToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Anonymously',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Your identity will not be shared',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          Switch(
            activeThumbColor: kPrimaryBlue,
            value: isAnonymous,
            onChanged: (v) => setState(() => isAnonymous = v),
          ),
        ],
      ),
    );
  }

  Widget _incidentTypeSection() {
    final types = ref.watch(incidentTypesProvider);

    if (types.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Incident Type',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: types
              .where((t) =>
                  t.name == 'Accident' || t.name == 'Fire' || t.name == 'Crime')
              .map((type) {
            final selected = selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? kPrimaryBlue : Colors.grey.shade300,
                    width: 2,
                  ),
                  color: selected ? kPrimaryBlue.withOpacity(0.1) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type.name == 'Fire'
                          ? Icons.local_fire_department
                          : type.name == 'Accident'
                              ? Icons.car_crash
                              : Icons.security,
                      size: 28,
                      color: selected ? kPrimaryBlue : Colors.grey,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      type.name.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: selected ? kPrimaryBlue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _prioritySection() {
    if (selectedType == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _priorityCard(
                'Critical',
                'critical',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _priorityCard(
                'Highly Critical',
                'highly_critical',
                kPrimaryRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _priorityCard(String label, String value, Color color) {
    final selected = priority == value;

    return GestureDetector(
      onTap: () => setState(() => priority = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? color : Colors.grey.shade200,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 12,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _descriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description (Text or Voice)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Describe what happened (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              iconSize: 40,
              icon: Icon(_isRecording ? Icons.mic : Icons.mic_none),
              color: _isRecording ? Colors.red : Colors.blue,
              onPressed:
                  _isRecording ? _stopVoiceRecording : _startVoiceRecording,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isRecording
                    ? 'Recording... tap to stop'
                    : _audioFilePath != null
                        ? 'Voice message attached'
                        : 'Tap mic to record voice message',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        if (_audioFilePath != null)
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.stop : Icons.play_arrow,
                ),
                onPressed: _togglePlayback,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _audioFilePath = null),
              ),
            ],
          ),
      ],
    );
  }

  Widget _mediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attach Evidence',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _mediaCard(
                label: 'Take Photo',
                icon: Icons.camera_alt,
                selected: selectedImage != null,
                onTap: () => pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _mediaCard(
                label: 'Record Video',
                icon: Icons.videocam,
                selected: selectedVideo != null,
                onTap: () => pickVideo(ImageSource.camera),
              ),
            ),
          ],
        ),

        // Preview section
        if (selectedImage != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(selectedImage!, height: 140, fit: BoxFit.cover),
          ),
        ],

        if (selectedVideo != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Video recorded',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }

  Widget _mediaCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kPrimaryBlue : Colors.grey.shade300,
            width: 2,
          ),
          color: selected ? kPrimaryBlue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: selected ? kPrimaryBlue : Colors.grey,
            ),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: selected ? kPrimaryBlue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _autoLocationInfo() {
    if (_currentPosition == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Fetching current location...',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location (Auto-detected)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(AsyncValue<void> submitState) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kPrimaryRed.withOpacity(0.4),
            blurRadius: 16,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: submitState.isLoading ? null : _submitIncident,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: submitState.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'SUBMIT REPORT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}

  // OTHER SECTIONS (unchanged logic)
  // _anonymousToggle(), _incidentTypeSection(),
  // _prioritySection(), _mediaSection(), _submitButton()