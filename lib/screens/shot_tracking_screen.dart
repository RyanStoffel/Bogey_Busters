import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_state.dart';
import '../services/location_service.dart';
import '../models/shot.dart';
import '../models/round.dart';
import '../utils/theme.dart';

class ShotTrackingScreen extends StatefulWidget {
  const ShotTrackingScreen({super.key});

  @override
  State<ShotTrackingScreen> createState() => _ShotTrackingScreenState();
}

class _ShotTrackingScreenState extends State<ShotTrackingScreen> {
  final LocationService _locationService = LocationService();
  final _uuid = const Uuid();

  int _currentHoleIndex = 0;
  Position? _lastShotPosition;
  bool _isRecordingShot = false;
  List<Shot> _currentHoleShots = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final confirm = await _showExitConfirmation();
        return confirm ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Track Round'),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                final confirm = await _showExitConfirmation();
                if (confirm == true && mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        body: Consumer<AppState>(
          builder: (context, appState, child) {
            final currentRound = appState.currentRound;

            if (currentRound == null) {
              return const Center(
                child: Text('No active round'),
              );
            }

            final course = currentRound.course;
            final currentHole = course.holes[_currentHoleIndex];
            final holeScore = currentRound.holeScores[currentHole.number];
            final strokes = holeScore?.strokes ?? 0;

            return Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentHoleIndex + 1) / course.numberOfHoles,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),

                // Hole info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.primaryGreen.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Hole ${currentHole.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHoleInfo('Par', '${currentHole.par}'),
                          const SizedBox(width: 32),
                          _buildHoleInfo('Distance', '${currentHole.distance} yds'),
                          const SizedBox(width: 32),
                          _buildHoleInfo('Strokes', '$strokes'),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Score card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stroke Count',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: strokes > 0
                                          ? () => _updateStrokes(
                                              appState, currentHole.number, -1)
                                          : null,
                                      icon: const Icon(Icons.remove_circle),
                                      color: AppTheme.errorColor,
                                      iconSize: 40,
                                    ),
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$strokes',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _updateStrokes(
                                          appState, currentHole.number, 1),
                                      icon: const Icon(Icons.add_circle),
                                      color: AppTheme.primaryGreen,
                                      iconSize: 40,
                                    ),
                                  ],
                                ),
                                if (strokes > 0) ...[
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getScoreColor(
                                            strokes - currentHole.par),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        holeScore?.scoreName ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // GPS tracking card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.gps_fixed,
                                      color: AppTheme.primaryGreen,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'GPS Shot Tracking',
                                      style:
                                          Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: _isRecordingShot
                                        ? null
                                        : () => _recordShot(
                                            appState, currentHole.number),
                                    icon: _isRecordingShot
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Icon(Icons.add_location),
                                    label: Text(
                                      _lastShotPosition == null
                                          ? 'Record First Shot'
                                          : 'Record Next Shot',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                if (_currentHoleShots.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Shots on this hole:',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  ..._currentHoleShots.asMap().entries.map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor:
                                                    AppTheme.primaryGreen,
                                                child: Text(
                                                  '${entry.key + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  entry.value.distance != null
                                                      ? _locationService
                                                          .formatDistanceYards(
                                                              entry.value.distance!)
                                                      : 'No distance',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Navigation buttons
                        Row(
                          children: [
                            if (_currentHoleIndex > 0)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _currentHoleIndex--;
                                      _resetHoleState();
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Previous'),
                                ),
                              ),
                            if (_currentHoleIndex > 0) const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: strokes > 0
                                    ? () {
                                        if (_currentHoleIndex <
                                            course.numberOfHoles - 1) {
                                          setState(() {
                                            _currentHoleIndex++;
                                            _resetHoleState();
                                          });
                                        } else {
                                          _finishRound(appState);
                                        }
                                      }
                                    : null,
                                icon: Icon(
                                  _currentHoleIndex < course.numberOfHoles - 1
                                      ? Icons.arrow_forward
                                      : Icons.check,
                                ),
                                label: Text(
                                  _currentHoleIndex < course.numberOfHoles - 1
                                      ? 'Next Hole'
                                      : 'Finish Round',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHoleInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int relativeToPar) {
    if (relativeToPar <= -2) return Colors.green[700]!;
    if (relativeToPar == -1) return Colors.green;
    if (relativeToPar == 0) return Colors.blue;
    if (relativeToPar == 1) return Colors.orange;
    return Colors.red;
  }

  void _updateStrokes(AppState appState, int holeNumber, int change) {
    final currentRound = appState.currentRound;
    if (currentRound == null) return;

    final currentScore = currentRound.holeScores[holeNumber]?.strokes ?? 0;
    final newScore = currentScore + change;

    if (newScore >= 0) {
      appState.currentRound!.holeScores[holeNumber] = currentRound
          .holeScores[holeNumber]!
          .copyWith(strokes: newScore);
      appState.updateCurrentRound(appState.currentRound!);
      setState(() {});
    }
  }

  Future<void> _recordShot(AppState appState, int holeNumber) async {
    setState(() => _isRecordingShot = true);

    try {
      final position = await _locationService.getCurrentPosition();

      double? distance;
      if (_lastShotPosition != null) {
        distance = _locationService.calculateDistance(
          _lastShotPosition!.latitude,
          _lastShotPosition!.longitude,
          position.latitude,
          position.longitude,
        );
      }

      final shot = Shot(
        id: _uuid.v4(),
        holeNumber: holeNumber,
        distance: distance,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );

      appState.currentRound!.shots.add(shot);
      await appState.updateCurrentRound(appState.currentRound!);

      setState(() {
        _lastShotPosition = position;
        _currentHoleShots.add(shot);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              distance != null
                  ? 'Shot recorded: ${_locationService.formatDistanceYards(distance)}'
                  : 'First shot recorded',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording shot: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isRecordingShot = false);
    }
  }

  void _resetHoleState() {
    _lastShotPosition = null;
    _currentHoleShots = [];
  }

  Future<void> _finishRound(AppState appState) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Round'),
        content: const Text(
          'Are you sure you want to finish this round? Your score will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finish'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await appState.completeCurrentRound();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/end-round',
          (route) => route.settings.name == '/home',
        );
      }
    }
  }

  Future<bool?> _showExitConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Round'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

extension on HoleScore {
  HoleScore copyWith({int? strokes}) {
    return HoleScore(
      holeNumber: holeNumber,
      strokes: strokes ?? this.strokes,
      par: par,
    );
  }
}
