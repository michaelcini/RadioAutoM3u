import 'package:flutter/material.dart';
import 'models.dart';
import 'stations_repository.dart';
import 'm3u_parser.dart';
import 'pls_parser.dart';
import 'opml_parser.dart';

void main() {
  runApp(const RadioApp());
}

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RadioAutoM3U',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StationsPage(),
    );
  }
}

class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  final repo = StationsRepository();
  late Future<List<Station>> stationsFuture;

  @override
  void initState() {
    super.initState();
    stationsFuture = repo.loadStations(); // returns Future<List<Station>>
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
                    ? Image.network(station.logo!, width: 40, height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.radio))
                    : const Icon(Icons.radio),
                title: Text(station.name),
                subtitle: Text(station.url),
                onTap: () {
                  // TODO: connect with player later
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Would play: ${station.name}")),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: Hook with file picker / text input to import m3u/pls/opml
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Import feature coming soon")),
          );
        },
      ),
    );
  }
}
