import '../../models/book.dart';
import '../../services/hive_service.dart';
import '../../services/book_service.dart';
import '../book_repository.dart';
import '../user_repository.dart';
import 'local_user_repository.dart';

class LocalBookRepository implements BookRepository {
  final HiveService _hiveService = HiveService();
  final BookService _bookService = BookService();
  final UserRepository _userRepository = LocalUserRepository();

  @override
  Future<List<Book>> getAllBooks() async {
    var books = await _hiveService.getBooks();
    if (books.isEmpty) {
      books = await _bookService.getDefaultBooks();
      await _hiveService.saveBooks(books);
    }
    return books;
  }

  @override
  Future<Book?> getBookById(String bookId) async {
    final books = await getAllBooks();
    try {
      return books.firstWhere((book) => book.id == bookId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Book>> getUnlockedBooks(String userId) async {
    final user = await _userRepository.getCurrentUser();
    if (user == null || user.id != userId) return [];

    final books = await getAllBooks();
    return books.where((book) => user.unlockedBookIds.contains(book.id)).toList();
  }

  @override
  Future<List<Book>> getFavoriteBooks(String userId) async {
    final user = await _userRepository.getCurrentUser();
    if (user == null || user.id != userId) return [];

    final books = await getAllBooks();
    return books.where((book) => user.favoriteBookIds.contains(book.id)).toList();
  }

  @override
  Future<List<Summary>> getTodayUnlockedSummaries(String userId) async {
    final books = await getAllBooks();
    return await _bookService.getTodayUnlockedSummaries(books);
  }

  @override
  Future<List<Summary>> getBookSummaries(String bookId) async {
    final book = await getBookById(bookId);
    return book?.summaries ?? [];
  }

  @override
  Future<Summary?> getSummaryById(String summaryId) async {
    final books = await getAllBooks();
    for (final book in books) {
      for (final summary in book.summaries) {
        if (summary.id == summaryId) {
          return summary;
        }
      }
    }
    return null;
  }

  @override
  Future<void> saveBooks(List<Book> books) async {
    await _hiveService.saveBooks(books);
  }

  @override
  Future<void> unlockBook(String bookId, String userId) async {
    final books = await getAllBooks();
    final bookIndex = books.indexWhere((book) => book.id == bookId);

    if (bookIndex != -1) {
      books[bookIndex] = books[bookIndex].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      await saveBooks(books);
      await _userRepository.unlockBook(userId, bookId);
    }
  }

  @override
  Future<void> toggleBookFavorite(String bookId, String userId) async {
    final books = await getAllBooks();
    final bookIndex = books.indexWhere((book) => book.id == bookId);

    if (bookIndex != -1) {
      books[bookIndex] = books[bookIndex].copyWith(
        isFavorite: !books[bookIndex].isFavorite,
      );
      await saveBooks(books);
      await _userRepository.toggleBookFavorite(userId, bookId);
    }
  }

  @override
  Future<void> unlockSummary(String summaryId, String userId) async {
    final books = await getAllBooks();
    bool updated = false;

    for (int i = 0; i < books.length; i++) {
      for (int j = 0; j < books[i].summaries.length; j++) {
        if (books[i].summaries[j].id == summaryId) {
          books[i].summaries[j] = books[i].summaries[j].copyWith(
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
      await saveBooks(books);
    }
  }

  @override
  Future<void> markSummaryAsRead(String summaryId, String userId) async {
    final books = await getAllBooks();
    bool updated = false;

    for (int i = 0; i < books.length; i++) {
      for (int j = 0; j < books[i].summaries.length; j++) {
        if (books[i].summaries[j].id == summaryId) {
          books[i].summaries[j] = books[i].summaries[j].copyWith(
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
      await saveBooks(books);
      await _userRepository.addToViewHistory(userId, summaryId);
    }
  }

  @override
  Future<List<Summary>> unlockDailySummaries(String userId, int count) async {
    final books = await getAllBooks();
    return await _bookService.unlockDailySummaries(books, count);
  }

  @override
  Future<Book?> getRandomUnlockedBook(String userId) async {
    final books = await getAllBooks();
    return await _bookService.getRandomUnlockedBook(books);
  }

  @override
  Future<List<Summary>> getUserViewHistory(String userId) async {
    final user = await _userRepository.getCurrentUser();
    if (user == null || user.id != userId) return [];

    final summaries = <Summary>[];
    for (final summaryId in user.viewHistory) {
      final summary = await getSummaryById(summaryId);
      if (summary != null) {
        summaries.add(summary);
      }
    }
    return summaries;
  }
}