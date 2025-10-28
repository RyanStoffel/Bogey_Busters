import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/round.dart';
import '../models/course.dart';
import '../models/shot.dart';

class RoundService {
  static const String _roundsKey = 'rounds';
  static const String _currentRoundKey = 'current_round';
  final _uuid = const Uuid();

  Future<List<Round>> getAllRounds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final roundsJson = prefs.getString(_roundsKey);

    if (roundsJson == null) return [];

    final allRounds = (jsonDecode(roundsJson) as List)
        .map((r) => Round.fromJson(r))
        .toList();

    return allRounds.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Future<Round?> getCurrentRound() async {
    final prefs = await SharedPreferences.getInstance();
    final roundJson = prefs.getString(_currentRoundKey);

    if (roundJson == null) return null;
    return Round.fromJson(jsonDecode(roundJson));
  }

  Future<Round> startNewRound(String userId, Course course) async {
    final prefs = await SharedPreferences.getInstance();

    final holeScores = <int, HoleScore>{};
    for (final hole in course.holes) {
      holeScores[hole.number] = HoleScore(
        holeNumber: hole.number,
        strokes: 0,
        par: hole.par,
      );
    }

    final round = Round(
      id: _uuid.v4(),
      userId: userId,
      course: course,
      startTime: DateTime.now(),
      holeScores: holeScores,
      shots: [],
      isCompleted: false,
    );

    await prefs.setString(_currentRoundKey, jsonEncode(round.toJson()));
    return round;
  }

  Future<void> updateRound(Round round) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentRoundKey, jsonEncode(round.toJson()));
  }

  Future<void> completeRound(Round round) async {
    final prefs = await SharedPreferences.getInstance();

    final completedRound = round.copyWith(
      endTime: DateTime.now(),
      isCompleted: true,
    );

    // Add to all rounds
    final roundsJson = prefs.getString(_roundsKey);
    final rounds = roundsJson != null
        ? (jsonDecode(roundsJson) as List).map((r) => Round.fromJson(r)).toList()
        : <Round>[];

    rounds.add(completedRound);
    await prefs.setString(
      _roundsKey,
      jsonEncode(rounds.map((r) => r.toJson()).toList()),
    );

    // Clear current round
    await prefs.remove(_currentRoundKey);
  }

  Future<void> addShot(Round round, Shot shot) async {
    final updatedShots = [...round.shots, shot];
    final updatedRound = round.copyWith(shots: updatedShots);
    await updateRound(updatedRound);
  }

  Future<void> updateHoleScore(Round round, int holeNumber, int strokes) async {
    final updatedScores = Map<int, HoleScore>.from(round.holeScores);
    final currentScore = updatedScores[holeNumber]!;
    updatedScores[holeNumber] = HoleScore(
      holeNumber: holeNumber,
      strokes: strokes,
      par: currentScore.par,
    );

    final updatedRound = round.copyWith(holeScores: updatedScores);
    await updateRound(updatedRound);
  }

  Future<void> saveManualRound(String userId, Course course, Map<int, int> scores) async {
    final prefs = await SharedPreferences.getInstance();

    final holeScores = <int, HoleScore>{};
    for (final entry in scores.entries) {
      final hole = course.holes.firstWhere((h) => h.number == entry.key);
      holeScores[entry.key] = HoleScore(
        holeNumber: entry.key,
        strokes: entry.value,
        par: hole.par,
      );
    }

    final round = Round(
      id: _uuid.v4(),
      userId: userId,
      course: course,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      holeScores: holeScores,
      shots: [],
      isCompleted: true,
    );

    final roundsJson = prefs.getString(_roundsKey);
    final rounds = roundsJson != null
        ? (jsonDecode(roundsJson) as List).map((r) => Round.fromJson(r)).toList()
        : <Round>[];

    rounds.add(round);
    await prefs.setString(
      _roundsKey,
      jsonEncode(rounds.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> deleteRound(String roundId) async {
    final prefs = await SharedPreferences.getInstance();
    final roundsJson = prefs.getString(_roundsKey);

    if (roundsJson == null) return;

    final rounds = (jsonDecode(roundsJson) as List)
        .map((r) => Round.fromJson(r))
        .where((r) => r.id != roundId)
        .toList();

    await prefs.setString(
      _roundsKey,
      jsonEncode(rounds.map((r) => r.toJson()).toList()),
    );
  }
}
