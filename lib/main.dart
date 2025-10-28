import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'utils/theme.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/past_rounds_screen.dart';
import 'screens/choose_course_screen.dart';
import 'screens/shot_tracking_screen.dart';
import 'screens/manual_entry_screen.dart';
import 'screens/end_round_screen.dart';

void main() {
  runApp(const BogeyBustersApp());
}

class BogeyBustersApp extends StatelessWidget {
  const BogeyBustersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Bogey Busters',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoadingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/past-rounds': (context) => const PastRoundsScreen(),
          '/choose-course': (context) => const ChooseCourseScreen(),
          '/shot-tracking': (context) => const ShotTrackingScreen(),
          '/manual-entry': (context) => const ManualEntryScreen(),
          '/end-round': (context) => const EndRoundScreen(),
        },
      ),
    );
  }
}
