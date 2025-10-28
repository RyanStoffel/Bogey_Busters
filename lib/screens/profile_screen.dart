import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final user = appState.currentUser;
          final rounds = appState.rounds;

          if (user == null) {
            return const Center(child: Text('No user data'));
          }

          // Calculate stats
          final totalRounds = rounds.length;
          final avgScore = totalRounds > 0
              ? rounds.fold<int>(0, (sum, r) => sum + r.totalScore) / totalRounds
              : 0.0;
          final bestScore = totalRounds > 0
              ? rounds.map((r) => r.totalScore).reduce((a, b) => a < b ? a : b)
              : 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.golf_course,
                              title: 'Total Rounds',
                              value: totalRounds.toString(),
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.show_chart,
                              title: 'Avg Score',
                              value: avgScore.toStringAsFixed(1),
                              color: AppTheme.accentGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.emoji_events,
                              title: 'Best Score',
                              value: bestScore.toString(),
                              color: AppTheme.lightGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.calendar_today,
                              title: 'Member Since',
                              value: user.createdAt.year.toString(),
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Options
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.history,
                                  color: AppTheme.primaryGreen),
                              title: const Text('Past Rounds'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.of(context).pushNamed('/past-rounds');
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.notifications_outlined,
                                  color: AppTheme.primaryGreen),
                              title: const Text('Notifications'),
                              trailing: Switch(
                                value: true,
                                onChanged: (value) {},
                                activeColor: AppTheme.primaryGreen,
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.help_outline,
                                  color: AppTheme.primaryGreen),
                              title: const Text('Help & Support'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {},
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.info_outline,
                                  color: AppTheme.primaryGreen),
                              title: const Text('About'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await appState.logout();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: const BorderSide(
                              color: AppTheme.errorColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
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
