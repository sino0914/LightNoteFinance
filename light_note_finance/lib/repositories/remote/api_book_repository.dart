import '../../models/book.dart';
import '../../services/api_service.dart';
import '../book_repository.dart';

class ApiBookRepository implements BookRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<Book>> getAllBooks() async {
    try {
      final response = await _apiService.get('/books');
      if (response.isSuccess && response.data != null) {
        final List<dynamic> booksJson = response.data;
        return booksJson.map((json) => Book.fromApiJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get all books: $e');
    }
  }

  @override
  Future<Book?> getBookById(String bookId) async {
    try {
      final response = await _apiService.get('/books/$bookId');
      if (response.isSuccess && response.data != null) {
        return Book.fromApiJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get book: $e');
    }
  }

  @override
  Future<List<Book>> getUnlockedBooks(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/books/unlocked');
      if (response.isSuccess && response.data != null) {
        final List<dynamic> booksJson = response.data;
        return booksJson.map((json) => Book.fromApiJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get unlocked books: $e');
    }
  }

  @override
  Future<List<Book>> getFavoriteBooks(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/books/favorites');
      if (response.isSuccess && response.data != null) {
        final List<dynamic> booksJson = response.data;
        return booksJson.map((json) => Book.fromApiJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get favorite books: $e');
    }
  }

  @override
  Future<List<Summary>> getTodayUnlockedSummaries(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/summaries/today');
      if (response.isSuccess && response.data != null) {
        final List<dynamic> summariesJson = response.data;
        return summariesJson.map((json) => Summary.fromApiJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get today summaries: $e');
    }
  }

  @override
  Future<List<Summary>> getBookSummaries(String bookId) async {
    try {
      final response = await _apiService.get('/books/$bookId/summaries');
      if (response.isSuccess && response.data != null) {
        final List<dynamic> summariesJson = response.data;
        return summariesJson.map((json) => Summary.fromApiJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get book summaries: $e');
    }
  }

  @override
  Future<Summary?> getSummaryById(String summaryId) async {
    try {
      final response = await _apiService.get('/summaries/$summaryId');
      if (response.isSuccess && response.data != null) {
        return Summary.fromApiJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get summary: $e');
    }
  }

  @override
  Future<void> saveBooks(List<Book> books) async {
    try {
      final booksJson = books.map((book) => book.toJson()).toList();
      await _apiService.post('/books/batch', {'books': booksJson});
    } catch (e) {
      throw Exception('Failed to save books: $e');
    }
  }

  @override
  Future<void> unlockBook(String bookId, String userId) async {
    try {
      await _apiService.post('/books/$bookId/unlock', {'userId': userId});
    } catch (e) {
      throw Exception('Failed to unlock book: $e');
    }
  }

  @override
  Future<void> toggleBookFavorite(String bookId, String userId) async {
    try {
      await _apiService.post('/books/$bookId/favorite/toggle', {'userId': userId});
    } catch (e) {
      throw Exception('Failed to toggle book favorite: $e');
    }
  }

  @override
  Future<void> unlockSummary(String summaryId, String userId) async {
    try {
      await _apiService.post('/summaries/$summaryId/unlock', {'userId': userId});
    } catch (e) {
      throw Exception('Failed to unlock summary: $e');
    }
  }

  @override
  Future<void> markSummaryAsRead(String summaryId, String userId) async {
    try {
      await _apiService.post('/summaries/$summaryId/read', {'userId': userId});
    } catch (e) {
      throw Exception('Failed to mark summary as read: $e');
    }
  }

  @override
  Future<List<Summary>> unlockDailySummaries(String userId, int count) async {
    try {
      final response = await _apiService.post('/users/$userId/summaries/unlock-daily', {
        'count': count,
      });
      if (response.isSuccess && response.data != null) {
        final List<dynamic> summariesJson = response.data;
        return summariesJson.map((json) => Summary.fromApiJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to unlock daily summaries: $e');
    }
  }

  @override
  Future<Book?> getRandomUnlockedBook(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/books/random-unlocked');
      if (response.isSuccess && response.data != null) {
        return Book.fromApiJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get random unlocked book: $e');
    }
  }

  @override
  Future<List<Summary>> getUserViewHistory(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/history');
      if (response.isSuccess && response.data != null) {
        final List<dynamic> summariesJson = response.data;
        return summariesJson.map((json) => Summary.fromApiJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get user view history: $e');
    }
  }
}