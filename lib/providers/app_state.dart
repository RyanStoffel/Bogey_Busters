import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/round.dart';
import '../models/course.dart';
import '../services/auth_service.dart';
import '../services/round_service.dart';
import '../services/course_service.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final RoundService _roundService = RoundService();
  final CourseService _courseService = CourseService();

  User? _currentUser;
  Round? _currentRound;
  List<Round> _rounds = [];
  List<Course> _courses = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  Round? get currentRound => _currentRound;
  List<Round> get rounds => _rounds;
  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null) {
        await loadUserData();
      }
      _courses = _courseService.getSampleCourses();
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    if (_currentUser == null) return;

    try {
      _rounds = await _roundService.getAllRounds(_currentUser!.id);
      _currentRound = await _roundService.getCurrentRound();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);
      if (_currentUser != null) {
        await loadUserData();
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signup(email, password, name);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _currentRound = null;
    _rounds = [];
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    await _authService.updateUser(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> startRound(Course course) async {
    if (_currentUser == null) return;

    _currentRound = await _roundService.startNewRound(_currentUser!.id, course);
    notifyListeners();
  }

  Future<void> updateCurrentRound(Round round) async {
    await _roundService.updateRound(round);
    _currentRound = round;
    notifyListeners();
  }

  Future<void> completeCurrentRound() async {
    if (_currentRound == null) return;

    await _roundService.completeRound(_currentRound!);
    await loadUserData();
    _currentRound = null;
    notifyListeners();
  }

  Future<void> saveManualRound(Course course, Map<int, int> scores) async {
    if (_currentUser == null) return;

    await _roundService.saveManualRound(_currentUser!.id, course, scores);
    await loadUserData();
  }

  Future<void> deleteRound(String roundId) async {
    await _roundService.deleteRound(roundId);
    await loadUserData();
  }
}
