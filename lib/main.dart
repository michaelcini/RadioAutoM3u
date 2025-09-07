// Supports HLS (.m3u8), M3U/PLS/OPML playlists, station logos and voice search (playFromSearch).

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_handler.dart';
import 'models.dart';
import 'stations_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.radioauto.channel.audio',
    androidNotificationChannelName: 'Radio Playback',
    androidNotificationOngoing: true,
  );
  final handler = await AudioService.init(
    builder: () => RadioAudioHandler(),
    config: const AudioServiceConfig(
      androidStopForegroundOnPause: false,
      androidNotificationChannelId: 'com.example.radioauto.channel.audio',
      androidNotificationChannelName: 'Radio Playback',
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(RadioApp(handler: handler, prefs: prefs));
}

class RadioApp extends StatefulWidget {
  final AudioHandler handler;
  final SharedPreferences prefs;
  const RadioApp({super.key, required this.handler, required this.prefs});

  @override
  State<RadioApp> createState() => _RadioAppState();
}

class _RadioAppState extends State<RadioApp> {
  late final StationsRepository repo;
  List<Station> stations = await repo.loadStations("https://vibefm.radioca.st/vibe_live");

  final _linkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    repo = StationsRepository(widget.prefs);
    stations = repo.loadStations();
    if (stations.isEmpty) {
      // Seed with an example
      stations = [
        Station(id: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one", name: "BBC Radio 1", url: Uri.parse("https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one")),
      ];
      repo.saveStations(stations);
    }
    _syncQueue();
  }

  Future<void> _syncQueue() async {
    final items = stations.map((s) => s.toMediaItem()).toList();
    await widget.handler.updateQueue(items);
  }

  Future<void> _addLink() async {
    final text = _linkCtrl.text.trim();
    if (text.isEmpty) return;
    final uri = Uri.tryParse(text);
    if (uri == null) return;
    final updated = await repo.addLink(stations, uri);
    setState(() => stations = updated);
    _linkCtrl.clear();
    _syncQueue();
  }

  Future<void> _playStation(Station s) async {
    await widget.handler.playFromMediaId(s.url.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Auto',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Radio Auto (M3U)')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(children: [
                Expanded(child: TextField(
                  controller: _linkCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Add station or M3U link (http/https)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  onSubmitted: (_) => _addLink(),
                )),
                const SizedBox(width: 8),
                FilledButton(onPressed: _addLink, child: const Text('Add')),
              ]),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: stations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final s = stations[i];
                    return ListTile(
                      leading: s.logo != null ? CircleAvatar(backgroundImage: NetworkImage(s.logo!)) : const CircleAvatar(child: Icon(Icons.radio)),
                      title: Text(s.name),
                      subtitle: Text(s.url.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _playStation(s),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
