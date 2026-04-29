import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<String?> startRecording() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return null;

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.m4a';

    if (await _recorder.hasPermission()) {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: path,
      );
      return path;
    }
    return null;
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
  }
}
