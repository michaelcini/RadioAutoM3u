
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
        stations.add(Station(
  id: someId,
  name: someName,
  url: someUri.toString(),
  logo: someLogo,
);
      } catch (_) {}
    }
  }
  return stations;
}
