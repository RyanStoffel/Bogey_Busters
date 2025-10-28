import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../utils/theme.dart';

class EndRoundScreen extends StatefulWidget {
  const EndRoundScreen({super.key});

  @override
  State<EndRoundScreen> createState() => _EndRoundScreenState();
}

class _EndRoundScreenState extends State<EndRoundScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Round Complete'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: Consumer<AppState>(
          builder: (context, appState, child) {
            final rounds = appState.rounds;
            if (rounds.isEmpty) {
              return const Center(child: Text('No round data'));
            }

            final lastRound = rounds.first;
            final course = lastRound.course;
            final totalScore = lastRound.totalScore;
            final scoreRelativeToPar = lastRound.scoreRelativeToPar;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Celebration header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
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
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Round Complete!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getCongratulationsMessage(scoreRelativeToPar),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Score card
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Text(
                                      course.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      DateFormat('MMMM dd, yyyy')
                                          .format(lastRound.startTime),
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const Divider(height: 32),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildScoreStat(
                                          'Total Score',
                                          totalScore.toString(),
                                          Icons.sports_golf,
                                        ),
                                        Container(
                                          width: 1,
                                          height: 60,
                                          color: Colors.grey[300],
                                        ),
                                        _buildScoreStat(
                                          'Relative to Par',
                                          lastRound.scoreDisplay,
                                          Icons.golf_course,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Stats grid
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.flag,
                                    title: 'Holes',
                                    value: '${course.numberOfHoles}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.golf_course_outlined,
                                    title: 'Par',
                                    value: '${course.totalPar}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.gps_fixed,
                                    title: 'GPS Shots',
                                    value: '${lastRound.shots.length}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.timer_outlined,
                                    title: 'Duration',
                                    value: _calculateDuration(lastRound),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Scorecard summary
                            Card(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.list_alt,
                                          color: AppTheme.primaryGreen,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Scorecard',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: course.holes.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final hole = course.holes[index];
                                      final score =
                                          lastRound.holeScores[hole.number];
                                      return ListTile(
                                        dense: true,
                                        leading: CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                              AppTheme.primaryGreen,
                                          child: Text(
                                            '${hole.number}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text('Par ${hole.par}'),
                                        trailing: score != null &&
                                                score.strokes > 0
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${score.strokes}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppTheme
                                                          .primaryGreen,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getScoreColor(
                                                              score
                                                                  .scoreRelativeToPar)
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      score.scoreName,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: _getScoreColor(
                                                            score
                                                                .scoreRelativeToPar),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const Text('-'),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Action buttons
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/home',
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(Icons.home),
                                label: const Text(
                                  'Back to Home',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed('/choose-course');
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text(
                                  'Start New Round',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _getCongratulationsMessage(int scoreRelativeToPar) {
    if (scoreRelativeToPar <= -10) return 'Incredible! That\'s amazing!';
    if (scoreRelativeToPar <= -5) return 'Excellent round!';
    if (scoreRelativeToPar <= -1) return 'Great job out there!';
    if (scoreRelativeToPar == 0) return 'Perfect par round!';
    if (scoreRelativeToPar <= 5) return 'Good effort!';
    return 'You finished the round!';
  }

  Color _getScoreColor(int relativeToPar) {
    if (relativeToPar <= -2) return Colors.green[700]!;
    if (relativeToPar == -1) return Colors.green;
    if (relativeToPar == 0) return Colors.blue;
    if (relativeToPar == 1) return Colors.orange;
    return Colors.red;
  }

  String _calculateDuration(round) {
    if (round.endTime == null) return '-';
    final duration = round.endTime!.difference(round.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
