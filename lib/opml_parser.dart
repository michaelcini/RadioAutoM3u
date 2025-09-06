
import 'package:xml/xml.dart' as xml;
import 'models.dart';

List<Station> parseOPML(String content) {
  final doc = xml.XmlDocument.parse(content);
  final outlines = doc.findAllElements('outline');
  final stations = <Station>[];
  for (final o in outlines) {
    final url = o.getAttribute('xmlUrl') ?? o.getAttribute('url');
    final title = o.getAttribute('text') ?? o.getAttribute('title') ?? url;
    if (url != null) {
      final id = url;
      try {
        stations.add(Station(id: id, name: title ?? id, url: Uri.parse(url)));
      } catch (_) {}
    }
  }
  return stations;
}
