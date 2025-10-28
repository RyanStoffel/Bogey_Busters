class Shot {
  final String id;
  final int holeNumber;
  final double? distance;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final String? club;

  Shot({
    required this.id,
    required this.holeNumber,
    this.distance,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.club,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'holeNumber': holeNumber,
      'distance': distance,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'club': club,
    };
  }

  factory Shot.fromJson(Map<String, dynamic> json) {
    return Shot(
      id: json['id'] as String,
      holeNumber: json['holeNumber'] as int,
      distance: json['distance'] as double?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      club: json['club'] as String?,
    );
  }
}
