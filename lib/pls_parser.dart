import 'models.dart';

class PlsParser {
  List<Station> parse(String content) {
    final lines = content.split("\n");
    final List<Station> stations = [];

    String? name;
    String? url;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.toLowerCase().startsWith("title")) {
        name = trimmed.split("=").last.trim();
      } else if (trimmed.toLowerCase().startsWith("file")) {
        url = trimmed.split("=").last.trim();
        if (url.isNotEmpty) {
          stations.add(Station(
            id: url,
            name: name ?? "Unnamed",
            url: url,
            logo: null,
          ));
        }
        name = null;
        url = null;
      }
    }

    return stations;
  }
}
