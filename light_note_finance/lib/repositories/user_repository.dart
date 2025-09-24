import '../models/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<void> saveUser(User user);
  Future<void> updateUser(User user);
  Future<void> addPoints(String userId, int points);
  Future<void> spendPoints(String userId, int points);
  Future<void> toggleBookFavorite(String userId, String bookId);
  Future<void> unlockBook(String userId, String bookId);
  Future<void> addToViewHistory(String userId, String summaryId);
  Future<void> updateWeeklyActivity(String userId);
  Future<void> updateUserSettings(String userId, UserSettings settings);
  Future<void> deleteUser(String userId);
}