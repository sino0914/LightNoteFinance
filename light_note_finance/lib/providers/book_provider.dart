import 'package:flutter/material.dart';
import '../models/book.dart';
import '../repositories/repository_factory.dart';
import '../repositories/book_repository.dart';
import '../repositories/user_repository.dart';

class BookProvider extends ChangeNotifier {
  late final BookRepository _bookRepository;
  late final UserRepository _userRepository;
  List<Book> _books = [];
  List<Summary> _todaySummaries = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  BookProvider() {
    _bookRepository = RepositoryFactory.createBookRepository();
    _userRepository = RepositoryFactory.createUserRepository();
  }

  List<Book> get books => _books;
  List<Summary> get todaySummaries => _todaySummaries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Book> get unlockedBooks =>
      _books.where((book) => book.isUnlocked).toList();

  List<Book> get favoriteBooks =>
      _books.where((book) => book.isFavorite).toList();

  Future<void> initializeBooks() async {
    _setLoading(true);
    try {
      final user = await _userRepository.getCurrentUser();
      _currentUserId = user?.id;

      _books = await _bookRepository.getAllBooks();
      await _loadTodaySummaries();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize books: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> unlockBook(String bookId) async {
    if (_currentUserId == null) return;

    try {
      await _bookRepository.unlockBook(bookId, _currentUserId!);

      final bookIndex = _books.indexWhere((book) => book.id == bookId);
      if (bookIndex != -1) {
        _books[bookIndex] = _books[bookIndex].copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to unlock book: $e');
    }
  }

  Future<void> toggleBookFavorite(String bookId) async {
    if (_currentUserId == null) return;

    try {
      await _bookRepository.toggleBookFavorite(bookId, _currentUserId!);

      final bookIndex = _books.indexWhere((book) => book.id == bookId);
      if (bookIndex != -1) {
        _books[bookIndex] = _books[bookIndex].copyWith(
          isFavorite: !_books[bookIndex].isFavorite,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to toggle favorite: $e');
    }
  }

  Future<void> unlockSummary(String summaryId) async {
    if (_currentUserId == null) return;

    try {
      await _bookRepository.unlockSummary(summaryId, _currentUserId!);

      bool updated = false;
      for (int i = 0; i < _books.length; i++) {
        for (int j = 0; j < _books[i].summaries.length; j++) {
          if (_books[i].summaries[j].id == summaryId) {
            _books[i].summaries[j] = _books[i].summaries[j].copyWith(
              isUnlocked: true,
              unlockedAt: DateTime.now(),
            );
            updated = true;
            break;
          }
        }
        if (updated) break;
      }

      if (updated) {
        await _loadTodaySummaries();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to unlock summary: $e');
    }
  }

  Future<void> markSummaryAsRead(String summaryId) async {
    if (_currentUserId == null) return;

    try {
      await _bookRepository.markSummaryAsRead(summaryId, _currentUserId!);

      bool updated = false;
      for (int i = 0; i < _books.length; i++) {
        for (int j = 0; j < _books[i].summaries.length; j++) {
          if (_books[i].summaries[j].id == summaryId) {
            _books[i].summaries[j] = _books[i].summaries[j].copyWith(
              isRead: true,
              readAt: DateTime.now(),
            );
            updated = true;
            break;
          }
        }
        if (updated) break;
      }

      if (updated) {
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to mark summary as read: $e');
    }
  }

  Future<void> _loadTodaySummaries() async {
    if (_currentUserId == null) return;

    try {
      _todaySummaries = await _bookRepository.getTodayUnlockedSummaries(_currentUserId!);
    } catch (e) {
      _setError('Failed to load today summaries: $e');
    }
  }

  void setTodaySummaries(List<Summary> summaries) {
    _todaySummaries = summaries;
    notifyListeners();
  }

  Future<void> unlockDailySummaries(int count) async {
    if (_currentUserId == null) return;

    try {
      final newSummaries = await _bookRepository.unlockDailySummaries(_currentUserId!, count);

      if (newSummaries.isNotEmpty) {
        await _loadTodaySummaries();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to unlock daily summaries: $e');
    }
  }

  Book? getBookById(String bookId) {
    try {
      return _books.firstWhere((book) => book.id == bookId);
    } catch (e) {
      return null;
    }
  }

  Summary? getSummaryById(String summaryId) {
    try {
      for (final book in _books) {
        for (final summary in book.summaries) {
          if (summary.id == summaryId) {
            return summary;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<Summary> getBookSummaries(String bookId) {
    final book = getBookById(bookId);
    return book?.summaries ?? [];
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

  Future<List<Summary>> getUserViewHistory(String userId) async {
    try {
      return await _bookRepository.getUserViewHistory(userId);
    } catch (e) {
      _setError('Failed to get view history: $e');
      return [];
    }
  }
}