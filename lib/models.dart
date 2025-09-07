import 'package:audio_service/audio_service.dart';

class Station {
  final String id;
  final String name;
  final String url;
  final String? logo; // optional logo

  Station({
    required this.id,
    required this.name,
    required this.url,
    this.logo,
  });

  MediaItem toMediaItem() {
    return MediaItem(
      id: id,
      title: name,
      artUri: logo != null ? Uri.parse(logo!) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'logo': logo,
    };
  }

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      logo: json['logo'] as String?,
    );
  }
}
