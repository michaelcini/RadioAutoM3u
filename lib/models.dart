import 'package:audio_service/audio_service.dart';

class Station {
  final String name;
  final String url;

  Station({
    required this.name,
    required this.url,
  });

  /// Convert a station into a MediaItem for audio_service
  MediaItem toMediaItem() {
    return MediaItem(
      id: url,
      title: name,
    );
  }

  /// Convert Station to Map (useful for saving with SharedPreferences / JSON)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }

  /// Create Station from Map
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
