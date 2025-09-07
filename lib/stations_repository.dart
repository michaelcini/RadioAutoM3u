import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class StationsRepository {
  final List<Station> _stations = [];

  List<Station> get stations => List.unmodifiable(_stations);

  Future<List<Station>> loadStations(String url) async {
    final uri = Uri.parse(url);
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final body = utf8.decode(resp.bodyBytes);
      // TODO: parse M3U/PLS/OPML here
      final station = Station(
        id: uri.toString(),
        name: "Sample Station",
        url: uri.toString(),
      );
      _stations.add(station);
      return _stations;
    } else {
      throw Exception("Failed to load stations: ${resp.statusCode}");
    }
  }

  Future<void> saveStations(List<Station> stations) async {
    // TODO: persist with SharedPreferences
  }

  void addLink(String name, String url, {String? logo}) {
    _stations.add(
      Station(
        id: url,
        name: name,
        url: url,
        logo: logo,
      ),
    );
  }
}
