
import 'dart:convert';

import 'models.dart';

class M3uParseResult {
  final List<Station> stations;
  final String? title;
  M3uParseResult(this.stations, {this.title});
}

/// Very small M3U/M3U8 parser that supports #EXTM3U and #EXTINF
M3uParseResult parseM3U(String content) {
  final lines = const LineSplitter().convert(content).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  final stations = <Station>[];
  String? pendingName;
  String? pendingLogo;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.startsWith('#EXTINF')) {
      // Example: #EXTINF:-1 tvg-logo="..." group-title="Radio",Station Name
      final commaIndex = line.indexOf(',');
      final name = commaIndex >= 0 ? line.substring(commaIndex + 1).trim() : "Station";
      pendingName = name;
      // very naive logo extraction
      final logoIdx = line.indexOf('tvg-logo="');
      if (logoIdx != -1) {
        final start = logoIdx + 'tvg-logo="'.length;
        final end = line.indexOf('"', start);
        if (end > start) {
          pendingLogo = line.substring(start, end);
        }
      } else {
        pendingLogo = null;
      }
    } else if (!line.startsWith('#')) {
      // URL line
      final url = Uri.tryParse(line);
      if (url != null && (url.hasScheme || line.startsWith('http'))) {
        final name = pendingName ?? line;
        stations.add(Station(id: line, name: name, url: url, logo: pendingLogo));
      }
      pendingName = null;
      pendingLogo = null;
    }
  }
  return M3uParseResult(stations);
}
