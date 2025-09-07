import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'models.dart';

class RadioAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    try {
      await _player.setUrl(mediaId);
      await _player.play();
      mediaItem.add(
        MediaItem(
          id: mediaId,
          title: extras?['title'] ?? 'Unknown Station',
        ),
      );
    } catch (e) {
      print("Error playing mediaId: $e");
    }
  }
}
