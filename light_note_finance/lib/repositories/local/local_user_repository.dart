import '../../models/user.dart';
import '../../services/hive_service.dart';
import '../user_repository.dart';

class LocalUserRepository implements UserRepository {
  final HiveService _hiveService = HiveService();

  @override
  Future<User?> getCurrentUser() async {
    return await _hiveService.getUser();
  }

  @override
  Future<void> saveUser(User user) async {
    await _hiveService.saveUser(user);
  }

  @override
  Future<void> updateUser(User user) async {
    await _hiveService.saveUser(user);
  }

  @override
  Future<void> addPoints(String userId, int points) async {
    final user = await getCurrentUser();
    if (user != null && user.id == userId) {
      final updatedUser = user.copyWith(points: user.points + points);
      await saveUser(updatedUser);
    }
  }

  @override
  Future<void> spendPoints(String userId, int points) async {
    final user = await getCurrentUser();
    if (user != null && user.id == userId && user.points >= points) {
      final updatedUser = user.copyWith(points: user.points - points);
      await saveUser(updatedUser);
    }
  }

  @override
  Future<void> toggleBookFavorite(String userId, String bookId) async {
    final user = await getCurrentUser();
    if (user != null && user.id == userId) {
      final favoriteIds = List<String>.from(user.favoriteBookIds);
      if (favoriteIds.contains(bookId)) {
        favoriteIds.remove(bookId);
      } else {
        favoriteIds.add(bookId);
      }

      final updatedUser = user.copyWith(favoriteBookIds: favoriteIds);
      await saveUser(updatedUser);
    }
  }

  @override
  Future<void> unlockBook(String userId, String bookId) async {
    final user = await getCurrentUser();
    if (user != null && user.id == userId) {
      final unlockedIds = List<String>.from(user.unlockedBookIds);
      if (!unlockedIds.contains(bookId)) {
        unlockedIds.add(bookId);
        final updatedUser = user.copyWith(unlockedBookIds: unlockedIds);
        await saveUser(updatedUser);
      }
    }
  }

  @override
  Future<void> addToViewHistory(String userId, String summaryId) async {
    final user = await getCurrentUser();
    if (user != null && user.id == userId) {
      final history = List<String>.from(user.viewHistory);

      if (history.contains(summaryId)) {
        history.remove(summaryId);
      }

      history.insert(0, summaryId);

      if (history.length > 100) {
        history.removeRange(100, history.length);
      }

      final updatedUser = user.copyWith(viewHistory: history);
      await saveUser(updatedUser);
    }
  }

  @override
  Future<void> updateWeeklyActivity(String userId) async {
    final user = await getCurrentUser();
    if (user != null && user.id == userId) {
      final today = DateTime.now();
      final weekday = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][today.weekday % 7];

      final activity = Map<String, bool>.from(user.weeklyActivity);
      activity[weekday] = true;

      final updatedUser = user.copyWith(weeklyActivity: activity);
      await saveUser(updatedUser);
    }
  }

  @override
  Future<void> updateUserSettings(String userId, UserSettings settings) async {
    final user = await getCurrentUser();
    if (user != null && user.id == userId) {
      final updatedUser = user.copyWith(settings: settings);
      await saveUser(updatedUser);
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    final user = await getCurrentUser();
    if (user != null && user.id == userId) {
      await _hiveService.clearAllData();
    }
  }
}