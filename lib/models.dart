
import 'package:just_audio/just_audio.dart';

class Station {
  final String id;
  final String name;
  final Uri url;
  final String? logo;

  const Station({required this.id, required this.name, required this.url, this.logo});

  factory Station.fromMediaItem(MediaItem item) {
    return Station(
      id: item.id,
      name: item.title,
      url: Uri.parse(item.id),
      logo: item.artUri?.toString(),
    );
  }

  MediaItem toMediaItem() {
    return MediaItem(
      id: url.toString(),
      title: name,
      artUri: logo != null ? Uri.parse(logo!) : null,
      album: "Radio",
      extras: {"isLiveStream": true},
    );
  }

  Station copyWith({String? name, Uri? url, String? logo}) {
    return Station(id: id, name: name ?? this.name, url: url ?? this.url, logo: logo ?? this.logo);
  }
}
