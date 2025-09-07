import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'audio_handler.dart';
import 'models.dart';
import 'stations_repository.dart';
import 'm3u_parser.dart';
import 'pls_parser.dart';
import 'opml_parser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start the AudioService with our handler
  final audioHandler = await AudioService.init(
    builder: () => RadioAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.radio_auto_m3u.channel',
      androidNotificationChannelName: 'RadioAutoM3U',
      androidNotificationOngoing: true,
    ),
  );

  runApp(RadioApp(audioHandler: audioHandler));
}

class RadioApp extends StatelessWidget {
  final RadioAudioHandler audioHandler;
  const RadioApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RadioAutoM3U',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StationsPage(audioHandler: audioHandler),
    );
  }
}

class StationsPage extends StatefulWidget {
  final RadioAudioHandler audioHandler;
  const StationsPage({super.key, required this.audioHandler});

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  final repo = StationsRepository();
  late Future<List<Station>> stationsFuture;

  @override
  void initState() {
    super.initState();
    stationsFuture = repo.loadStations();
  }

  void _importM3U(String content) async {
    final parser = M3uParser();
    final parsed = parser.parse(content);
    await repo.saveStations(parsed);
    setState(() {
      stationsFuture = repo.loadStations();
    });
  }

  void _importPLS(String content) async {
    final parser = PlsParser();
    final parsed = parser.parse(content);
    await repo.saveStations(parsed);
    setState(() {
      stationsFuture = repo.loadStations();
    });
  }

  void _importOPML(String content) async {
    final parser = OpmlParser();
    final parsed = parser.parse(content);
    await repo.saveStations(parsed);
    setState(() {
      stationsFuture = repo.loadStations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RadioAutoM3U")),
      body: FutureBuilder<List<Station>>(
        future: stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final stations = snapshot.data ?? [];
          if (stations.isEmpty) {
            return const Center(child: Text("No stations added yet"));
          }
          return ListView.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              return ListTile(
                leading: station.logo != null
                    ? Image.network(
                        station.logo!,
                        width: 40,
                        height: 40,
                        errorBuilder: (_, __, ___) => const Icon(Icons.radio),
                      )
                    : const Icon(Icons.radio),
                title: Text(station.name),
                subtitle: Text(station.url),
                onTap: () async {
                  // Play station using the audio handler
                  await widget.audioHandler.playStation(station);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Playing: ${station.name}")),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final controller = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Paste Playlist (M3U/PLS/OPML)"),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Paste playlist content here",
                  ),
                  maxLines: 10,
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text("Import as M3U"),
                    onPressed: () => Navigator.pop(context, "m3u"),
                  ),
                  TextButton(
                    child: const Text("Import as PLS"),
                    onPressed: () => Navigator.pop(context, "pls"),
                  ),
                  TextButton(
                    child: const Text("Import as OPML"),
                    onPressed: () => Navigator.pop(context, "opml"),
                  ),
                ],
              );
            },
          );

          if (result != null) {
            final text = controller.text.trim();
            if (text.isNotEmpty) {
              if (result == "m3u") {
                _importM3U(text);
              } else if (result == "pls") {
                _importPLS(text);
              } else if (result == "opml") {
                _importOPML(text);
              }
            }
          }
        },
      ),
    );
  }
}
