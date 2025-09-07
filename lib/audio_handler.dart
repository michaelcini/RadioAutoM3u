import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'models.dart';

/// Main Audio Handler for RadioAutoM3U
class RadioAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  RadioAudioHandler() {
    // Broadcast player state changes
    _player.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ));
    });
  }

  /// Play a specific [Station] from queue
  Future<void> playStation(Station station) async {
    final item = MediaItem(
      id: station.url,
      album: "RadioAutoM3U",
      title: station.name,
      artUri: station.logo != null ? Uri.parse(station.logo!) : null,
    );

    // Update current media item (for Android Auto & notification)
    this.mediaItem.add(item);

    try {
      await _player.setUrl(station.url);
      await _player.play();
    } catch (e) {
      print("Error playing station: $e");
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (queue.value.isNotEmpty) {
      final currentIndex = queue.value.indexOf(mediaItem.value!);
      final nextIndex = (currentIndex + 1) % queue.value.length;
      final next = queue.value[nextIndex];
      mediaItem.add(next);
      await _player.setUrl(next.id);
      play();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (queue.value.isNotEmpty) {
      final currentIndex = queue.value.indexOf(mediaItem.value!);
      final prevIndex =
          (currentIndex - 1 + queue.value.length) % queue.value.length;
      final prev = queue.value[prevIndex];
      mediaItem.add(prev);
      await _player.setUrl(prev.id);
      play();
    }
  }

  /// Play from Android Auto (by Media ID = URL)
  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    try {
      await _player.setUrl(mediaId);
      await _player.play();
    } catch (e) {
      print("Error in playFromMediaId: $e");
    }
  }
}
