import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/course.dart';
import '../utils/theme.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  Course? _selectedCourse;
  final Map<int, TextEditingController> _scoreControllers = {};
  bool _isSaving = false;

  @override
  void dispose() {
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Entry'),
        actions: [
          if (_selectedCourse != null)
            TextButton(
              onPressed: _isSaving ? null : _saveRound,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (_selectedCourse == null) {
            return _buildCourseSelection(appState);
          }

          return _buildScoreEntry();
        },
      ),
    );
  }

  Widget _buildCourseSelection(AppState appState) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryGreen.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.primaryGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select a course to manually enter your scores',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryGreen,
                      ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appState.courses.length,
            itemBuilder: (context, index) {
              final course = appState.courses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.golf_course,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(course.name),
                  subtitle: Text(course.location),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    setState(() {
                      _selectedCourse = course;
                      // Initialize controllers for each hole
                      for (var hole in course.holes) {
                        _scoreControllers[hole.number] =
                            TextEditingController();
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScoreEntry() {
    final course = _selectedCourse!;

    return Column(
      children: [
        // Course info header
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedCourse = null;
                        _scoreControllers.clear();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          course.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHeaderStat('Holes', '${course.numberOfHoles}'),
                  _buildHeaderStat('Par', '${course.totalPar}'),
                  _buildHeaderStat('Score', _calculateTotalScore().toString()),
                ],
              ),
            ],
          ),
        ),

        // Score entry list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: course.holes.length,
            itemBuilder: (context, index) {
              final hole = course.holes[index];
              return _HoleScoreCard(
                hole: hole,
                controller: _scoreControllers[hole.number]!,
                onScoreChanged: () {
                  setState(() {}); // Rebuild to update total
                },
              );
            },
          ),
        ),

        // Save button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canSave() ? _saveRound : null,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Round',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStat(String label, String value) {
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  int _calculateTotalScore() {
    int total = 0;
    for (var controller in _scoreControllers.values) {
      final score = int.tryParse(controller.text) ?? 0;
      total += score;
    }
    return total;
  }

  bool _canSave() {
    // Check if at least one score is entered
    return _scoreControllers.values.any((c) => c.text.isNotEmpty);
  }

  Future<void> _saveRound() async {
    setState(() => _isSaving = true);

    try {
      final appState = context.read<AppState>();
      final scores = <int, int>{};

      for (var entry in _scoreControllers.entries) {
        final score = int.tryParse(entry.value.text);
        if (score != null && score > 0) {
          scores[entry.key] = score;
        }
      }

      if (scores.isEmpty) {
        throw Exception('Please enter at least one score');
      }

      await appState.saveManualRound(_selectedCourse!, scores);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Round saved successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving round: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _HoleScoreCard extends StatelessWidget {
  final Hole hole;
  final TextEditingController controller;
  final VoidCallback onScoreChanged;

  const _HoleScoreCard({
    required this.hole,
    required this.controller,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Hole number
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${hole.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Hole info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Par ${hole.par}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${hole.distance} yards',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Score input
            SizedBox(
              width: 80,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
                decoration: const InputDecoration(
                  hintText: '-',
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onChanged: (value) => onScoreChanged(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
