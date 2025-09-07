
import 'models.dart';

List<Station> parsePLS(String content) {
  // very simple PLS parser: looks for FileN entries and TitleN
  final lines = content.split(RegExp(r'\r?\n')).map((l) => l.trim()).where((l) => l.isNotEmpty);
  final files = <int, String>{};
  final titles = <int, String>{};
  for (final line in lines) {
    final m = RegExp(r'^(File|Title)(\d+)=(.+)$', caseSensitive: false).firstMatch(line);
    if (m != null) {
      final key = m.group(1)!.toLowerCase();
      final idx = int.tryParse(m.group(2)!) ?? 0;
      final val = m.group(3)!.trim();
      if (key == 'file') files[idx] = val;
      if (key == 'title') titles[idx] = val;
    }
  }
  final stations = <Station>[];
  for (final idx in files.keys) {
    final url = files[idx]!;
    final name = titles[idx] ?? url;
    stations.add(Station(
  id: someId,
  name: someName,
  url: someUri.toString(),
  logo: someLogo,
);
  }
  return stations;
}
