import 'models.dart';

class PlsParser {
  List<Station> parse(String content) {
    final List<Station> stations = [];
    final lines = content.split("\n");

    String? currentName;
    String? currentUrl;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith("Title")) {
        currentName = trimmed.split("=").last.trim();
      } else if (trimmed.startsWith("File")) {
        currentUrl = trimmed.split("=").last.trim();

        if (currentUrl.isNotEmpty) {
          stations.add(
            Station(
              id: currentUrl,
              name: currentName ?? "Unnamed",
              url: currentUrl,
              logo: null,
            ),
          );
          currentName = null;
          currentUrl = null;
        }
      }
    }

    return stations;
  }
}
