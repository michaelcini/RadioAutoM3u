import 'package:xml/xml.dart';
import 'models.dart';

class OpmlParser {
  List<Station> parse(String content) {
    final document = XmlDocument.parse(content);
    final List<Station> stations = [];

    for (final outline in document.findAllElements('outline')) {
      final title = outline.getAttribute('title') ?? outline.getAttribute('text');
      final url = outline.getAttribute('xmlUrl') ?? outline.getAttribute('url');

      if (url != null) {
        stations.add(
          Station(
            id: url,
            name: title ?? "Unnamed",
            url: url,
            logo: null,
          ),
        );
      }
    }

    return stations;
  }
}
