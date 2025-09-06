
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'opml_parser.dart';
import 'pls_parser.dart';
import 'm3u_parser.dart';

class StationsRepository {
  static const _kKey = 'stations_v1';
  final SharedPreferences _prefs;
  StationsRepository(this._prefs);

  List<Station> loadStations() {
    final raw = _prefs.getString(_kKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((m) => Station(
      id: m['id'] as String,
      name: m['name'] as String,
      url: Uri.parse(m['url'] as String),
      logo: m['logo'] as String?,
    )).toList();
  }

  Future<void> saveStations(List<Station> stations) async {
    final list = stations.map((s) => {
      'id': s.id,
      'name': s.name,
      'url': s.url.toString(),
      'logo': s.logo,
    }).toList();
    await _prefs.setString(_kKey, jsonEncode(list));
  }

  /// Add a URL that can be either:
  ///  - A direct stream URL
  ///  - A link to an M3U/M3U8 playlist
  /// We try to fetch and parse as M3U; if it returns 0, treat as direct stream.
  Future<List<Station>> addLink(List<Station> current, Uri uri) async {
    try {
      final contentType = resp.headers['content-type'] ?? '';
      final body = resp.body;
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final lower = (resp.headers['content-type'] ?? '').toLowerCase();
        // Try OPML
        if (body.trim().startsWith('<') && body.contains('<opml')) {
          final parsedOpml = parseOPML(body);
          if (parsedOpml.isNotEmpty) { final merged = _mergeUnique(current, parsedOpml); await saveStations(merged); return merged; }
        }
        // PLS
        if (body.contains('[playlist]') || body.toLowerCase().contains('file1=')) {
          final parsedPls = parsePLS(body);
          if (parsedPls.isNotEmpty) { final merged = _mergeUnique(current, parsedPls); await saveStations(merged); return merged; }
        }
        // M3U/M3U8
        if (body.trim().startsWith('#EXTM3U') || uri.path.toLowerCase().endsWith('.m3u') || uri.path.toLowerCase().endsWith('.m3u8') || lower.contains('audio/x-mpegurl')) {
          final parsed = parseM3U(body);
          if (parsed.stations.isNotEmpty) { final merged = _mergeUnique(current, parsed.stations); await saveStations(merged); return merged; }
        }
      }
        final parsed = parseM3U(resp.body);
        if (parsed.stations.isNotEmpty) {
          final merged = _mergeUnique(current, parsed.stations);
          await saveStations(merged);
          return merged;
        }
      }
    } catch (_) {}
    // fallback: treat as direct stream
    final s = Station(id: uri.toString(), name: uri.host.isNotEmpty ? uri.host : uri.toString(), url: uri);
    final merged = _mergeUnique(current, [s]);
    await saveStations(merged);
    return merged;
  }

  List<Station> _mergeUnique(List<Station> a, List<Station> b) {
    final map = { for (final s in a) s.id : s };
    for (final s in b) {
      map[s.id] = s;
    }
    return map.values.toList();
  }
}
