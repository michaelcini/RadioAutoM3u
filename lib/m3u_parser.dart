import 'dart:convert';
import 'models.dart';

class M3uParser {
  List<Station> parse(String content) {
    final lines = const LineSplitter().convert(content);
    final List<Station> stations = [];

    String? currentName;
    String? currentLogo;

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith("#EXTINF")) {
        final logoMatch = RegExp(r'tvg-logo="([^"]+)"').firstMatch(trimmed);
        currentLogo = logoMatch != null ? logoMatch.group(1) : null;

        final parts = trimmed.split(',');
        currentName = parts.length > 1 ? parts.last.trim() : "Unknown Station";
      } else if (!trimmed.startsWith("#")) {
        final url = trimmed;
        final id = url;
        stations.add(Station(
          id: id,
          name: currentName ?? "Unnamed",
          url: url,
          logo: currentLogo,
        ));

        currentName = null;
        currentLogo = null;
      }
    }

    return stations;
  }
}
