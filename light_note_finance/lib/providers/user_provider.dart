import 'package:flutter/material.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';
import '../repositories/repository_factory.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  late final UserRepository _userRepository;
  User? _user;
  bool _isLoading = false;
  String? _error;

  UserProvider() {
    _userRepository = RepositoryFactory.createUserRepository();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initializeUser() async {
    _setLoading(true);
    try {
      _user = await _userRepository.getCurrentUser();

      if (_user == null) {
        _user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          settings: UserSettings(),
        );
        await _userRepository.saveUser(_user!);
      }

      _updateLastLogin();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize user: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeFirstLogin(String selectedBookId) async {
    if (_user == null) return;

    try {
      _user = _user!.copyWith(
        isFirstLogin: false,
        currentBookId: selectedBookId,
        unlockedBookIds: [selectedBookId],
        lastLoginAt: DateTime.now(),
      );

      await _userRepository.updateUser(_user!);
      notifyListeners();
    } catch (e) {
      _setError('Failed to complete first login: $e');
    }
  }

  Future<void> addPoints(int points) async {
    if (_user == null) return;

    try {
      await _userRepository.addPoints(_user!.id, points);
      _user = _user!.copyWith(points: _user!.points + points);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add points: $e');
    }
  }

  Future<void> spendPoints(int points) async {
    if (_user == null || _user!.points < points) {
      _setError('Insufficient points');
      return;
    }

    try {
      await _userRepository.spendPoints(_user!.id, points);
      _user = _user!.copyWith(points: _user!.points - points);
      notifyListeners();
    } catch (e) {
      _setError('Failed to spend points: $e');
    }
  }

  Future<void> toggleBookFavorite(String bookId) async {
    if (_user == null) return;

    try {
      await _userRepository.toggleBookFavorite(_user!.id, bookId);

      final favoriteIds = List<String>.from(_user!.favoriteBookIds);
      if (favoriteIds.contains(bookId)) {
        favoriteIds.remove(bookId);
      } else {
        favoriteIds.add(bookId);
      }

      _user = _user!.copyWith(favoriteBookIds: favoriteIds);
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle favorite: $e');
    }
  }

  Future<void> unlockBook(String bookId) async {
    if (_user == null) return;

    try {
      await _userRepository.unlockBook(_user!.id, bookId);

      final unlockedIds = List<String>.from(_user!.unlockedBookIds);
      if (!unlockedIds.contains(bookId)) {
        unlockedIds.add(bookId);
        _user = _user!.copyWith(unlockedBookIds: unlockedIds);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to unlock book: $e');
    }
  }

  Future<void> addToViewHistory(String summaryId) async {
    if (_user == null) return;

    try {
      await _userRepository.addToViewHistory(_user!.id, summaryId);

      final history = List<String>.from(_user!.viewHistory);
      if (history.contains(summaryId)) {
        history.remove(summaryId);
      }
      history.insert(0, summaryId);
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }

      _user = _user!.copyWith(viewHistory: history);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add to history: $e');
    }
  }

  Future<void> updateWeeklyActivity() async {
    if (_user == null) return;

    try {
      await _userRepository.updateWeeklyActivity(_user!.id);

      final today = DateTime.now();
      final weekday = AppConstants.weekdays[today.weekday % 7];

      final activity = Map<String, bool>.from(_user!.weeklyActivity);
      activity[weekday] = true;

      _user = _user!.copyWith(weeklyActivity: activity);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update weekly activity: $e');
    }
  }

  Future<void> updateUserSettings(UserSettings settings) async {
    if (_user == null) return;

    try {
      await _userRepository.updateUserSettings(_user!.id, settings);
      _user = _user!.copyWith(settings: settings);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update settings: $e');
    }
  }

  void _updateLastLogin() {
    if (_user != null) {
      _user = _user!.copyWith(lastLoginAt: DateTime.now());
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  Future<void> clearViewHistory() async {
    if (_user == null) return;

    try {
      // 清空本地用戶的瀏覽歷史
      _user = _user!.copyWith(viewHistory: []);
      notifyListeners();

      // 可以在這裡添加調用repository清空歷史的邏輯
      // await _userRepository.clearViewHistory(_user!.id);
    } catch (e) {
      _setError('Failed to clear view history: $e');
    }
  }

  Future<void> activateWeeklyBoost() async {
    if (_user == null) return;

    try {
      // 實作週度增強邏輯
      // 這裡可以設置一個標記，表示用戶購買了週度增強
      // 在實際應用中，這會影響每日摘要解鎖數量
      notifyListeners();
    } catch (e) {
      _setError('Failed to activate weekly boost: $e');
    }
  }

}