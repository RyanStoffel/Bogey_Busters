class Course {
  final String id;
  final String name;
  final String location;
  final int numberOfHoles;
  final List<Hole> holes;
  final double? latitude;
  final double? longitude;

  Course({
    required this.id,
    required this.name,
    required this.location,
    required this.numberOfHoles,
    required this.holes,
    this.latitude,
    this.longitude,
  });

  int get totalPar => holes.fold(0, (sum, hole) => sum + hole.par);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'numberOfHoles': numberOfHoles,
      'holes': holes.map((h) => h.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      numberOfHoles: json['numberOfHoles'] as int,
      holes: (json['holes'] as List).map((h) => Hole.fromJson(h)).toList(),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }
}

class Hole {
  final int number;
  final int par;
  final int distance;
  final double? latitude;
  final double? longitude;

  Hole({
    required this.number,
    required this.par,
    required this.distance,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'par': par,
      'distance': distance,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Hole.fromJson(Map<String, dynamic> json) {
    return Hole(
      number: json['number'] as int,
      par: json['par'] as int,
      distance: json['distance'] as int,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }
}
