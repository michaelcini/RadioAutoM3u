import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class StationsRepository {
  // Load stations from a remote M3U/PLS file
  Future<List<Station>> loadStations(String url) async {
    final uri = Uri.parse(url);
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final body = utf8.decode(resp.bodyBytes);
      // TODO: parse M3U into stations
      // For now return a placeholder
      return [
        Station(name: "Sample Station", url: url),
      ];
    } else {
      throw Exception("Failed to load stations: ${resp.statusCode}");
    }
  }

  // Save stations locally (to be implemented with SharedPreferences later)
  Future<void> saveStations(List<Station> stations) async {
    // Placeholder: no-op for now
  }
}
