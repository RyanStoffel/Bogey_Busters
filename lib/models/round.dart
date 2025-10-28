import 'course.dart';
import 'shot.dart';

class Round {
  final String id;
  final String userId;
  final Course course;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<int, HoleScore> holeScores;
  final List<Shot> shots;
  final bool isCompleted;

  Round({
    required this.id,
    required this.userId,
    required this.course,
    required this.startTime,
    this.endTime,
    required this.holeScores,
    required this.shots,
    this.isCompleted = false,
  });

  int get totalScore => holeScores.values.fold(0, (sum, score) => sum + score.strokes);

  int get totalPar => course.totalPar;

  int get scoreRelativeToPar => totalScore - totalPar;

  String get scoreDisplay {
    final relative = scoreRelativeToPar;
    if (relative == 0) return 'E';
    if (relative > 0) return '+$relative';
    return '$relative';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'course': course.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'holeScores': holeScores.map((key, value) => MapEntry(key.toString(), value.toJson())),
      'shots': shots.map((s) => s.toJson()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      id: json['id'] as String,
      userId: json['userId'] as String,
      course: Course.fromJson(json['course']),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      holeScores: (json['holeScores'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(int.parse(key), HoleScore.fromJson(value)),
      ),
      shots: (json['shots'] as List).map((s) => Shot.fromJson(s)).toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Round copyWith({
    String? id,
    String? userId,
    Course? course,
    DateTime? startTime,
    DateTime? endTime,
    Map<int, HoleScore>? holeScores,
    List<Shot>? shots,
    bool? isCompleted,
  }) {
    return Round(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      course: course ?? this.course,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      holeScores: holeScores ?? this.holeScores,
      shots: shots ?? this.shots,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class HoleScore {
  final int holeNumber;
  final int strokes;
  final int par;

  HoleScore({
    required this.holeNumber,
    required this.strokes,
    required this.par,
  });

  int get scoreRelativeToPar => strokes - par;

  String get scoreName {
    final relative = scoreRelativeToPar;
    if (relative <= -4) return 'Condor';
    if (relative == -3) return 'Albatross';
    if (relative == -2) return 'Eagle';
    if (relative == -1) return 'Birdie';
    if (relative == 0) return 'Par';
    if (relative == 1) return 'Bogey';
    if (relative == 2) return 'Double Bogey';
    if (relative == 3) return 'Triple Bogey';
    return '+${relative}';
  }

  Map<String, dynamic> toJson() {
    return {
      'holeNumber': holeNumber,
      'strokes': strokes,
      'par': par,
    };
  }

  factory HoleScore.fromJson(Map<String, dynamic> json) {
    return HoleScore(
      holeNumber: json['holeNumber'] as int,
      strokes: json['strokes'] as int,
      par: json['par'] as int,
    );
  }
}
