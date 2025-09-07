class Station {
  final String id;
  final String name;
  final String url;
  final String? logo;

  Station({
    required this.id,
    required this.name,
    required this.url,
    this.logo,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      logo: json['logo'],
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
}
