import '../../models/user.dart';
import '../../services/api_service.dart';
import '../user_repository.dart';

class ApiUserRepository implements UserRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/user/current');
      if (response.isSuccess && response.data != null) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<void> saveUser(User user) async {
    try {
      await _apiService.post('/user', user.toJson());
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      await _apiService.put('/user/${user.id}', user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> addPoints(String userId, int points) async {
    try {
      await _apiService.post('/user/$userId/points/add', {'points': points});
    } catch (e) {
      throw Exception('Failed to add points: $e');
    }
  }

  @override
  Future<void> spendPoints(String userId, int points) async {
    try {
      await _apiService.post('/user/$userId/points/spend', {'points': points});
    } catch (e) {
      throw Exception('Failed to spend points: $e');
    }
  }

  @override
  Future<void> toggleBookFavorite(String userId, String bookId) async {
    try {
      await _apiService.post('/user/$userId/favorites/toggle', {'bookId': bookId});
    } catch (e) {
      throw Exception('Failed to toggle book favorite: $e');
    }
  }

  @override
  Future<void> unlockBook(String userId, String bookId) async {
    try {
      await _apiService.post('/user/$userId/books/unlock', {'bookId': bookId});
    } catch (e) {
      throw Exception('Failed to unlock book: $e');
    }
  }

  @override
  Future<void> addToViewHistory(String userId, String summaryId) async {
    try {
      await _apiService.post('/user/$userId/history', {'summaryId': summaryId});
    } catch (e) {
      throw Exception('Failed to add to view history: $e');
    }
  }

  @override
  Future<void> updateWeeklyActivity(String userId) async {
    try {
      await _apiService.post('/user/$userId/activity/weekly', {
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update weekly activity: $e');
    }
  }

  @override
  Future<void> updateUserSettings(String userId, UserSettings settings) async {
    try {
      await _apiService.put('/user/$userId/settings', settings.toJson());
    } catch (e) {
      throw Exception('Failed to update user settings: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete('/user/$userId');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}