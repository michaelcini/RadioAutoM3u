import 'package:xml/xml.dart';
import 'models.dart';

class OpmlParser {
  List<Station> parse(String content) {
    final doc = XmlDocument.parse(content);
    final List<Station> stations = [];

    for (final outline in doc.findAllElements("outline")) {
      final name = outline.getAttribute("text") ?? "Unnamed";
      final url = outline.getAttribute("xmlUrl");
      if (url != null && url.isNotEmpty) {
        stations.add(Station(
          id: url,
          name: name,
          url: url,
          logo: null,
        ));
      }
    }

    return stations;
  }
}
