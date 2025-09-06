
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class RadioAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  RadioAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Propagate player state to system
    _player.playbackEventStream.listen((_) {
      final playing = _player.playing;
      final processing = _player.processingState;
      playbackState.add(
        PlaybackState(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          androidCompactActionIndices: const [1, 2],
          processingState: switch (processing) {
            ProcessingState.idle => AudioProcessingState.idle,
            ProcessingState.loading => AudioProcessingState.loading,
            ProcessingState.buffering => AudioProcessingState.buffering,
            ProcessingState.ready => AudioProcessingState.ready,
            ProcessingState.completed => AudioProcessingState.completed,
          },
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: _player.currentIndex,
        ),
      );
    });

    // Keep current MediaItem in sync
    Rx.combineLatest2<SequenceState?, PlaybackEvent, MediaItem?>(
      _player.sequenceStateStream, _player.playbackEventStream, (a, b) => a?.currentSource?.tag as MediaItem?,
    ).listen((item) {
      if (item != null) mediaItem.add(item);
    });
  }

  @override
  Future<void> addQueueItem(MediaItem item) async {
    final source = AudioSource.uri(Uri.parse(item.id), tag: item);
    final current = _player.sequence;
    if (current == null) {
      await _player.setAudioSource(ConcatenatingAudioSource(children: [source]));
    } else {
      await (current as ConcatenatingAudioSource).add(source);
    }
    final newQueue = [...queue.value, item];
    queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    final children = newQueue.map((i) => AudioSource.uri(Uri.parse(i.id), tag: i)).toList();
    await _player.setAudioSource(ConcatenatingAudioSource(children: children));
    queue.add(newQueue);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.dispose();
  }

  @override
  Future<void> skipToNext() async => _player.seekToNext();

  @override
  Future<void> skipToPrevious() async => _player.seekToPrevious();

  @override
  Future<void> playFromSearch(String query, [Map<String, dynamic>? extras]) async {
    // Simple voice search support: try to find station by name or host
    final q = query.toLowerCase();
    final qIdx = queue.value.indexWhere((m) => m.title.toLowerCase().contains(q) || m.id.toLowerCase().contains(q));
    if (qIdx >= 0) {
      await _player.seek(Duration.zero, index: qIdx);
      await _player.play();
      return;
    }
    // not found - no-op
  }

  @override
  Future<void> playFromMediaId(String mediaId) async {
    // Find in queue; if not found, just set as single
    final idx = queue.value.indexWhere((m) => m.id == mediaId);
    if (idx >= 0) {
      await _player.seek(Duration.zero, index: idx);
      await _player.play();
    } else {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(mediaId), tag: MediaItem(id: mediaId, title: mediaId)));
      await _player.play();
    }
  }
}
