import '../models/book.dart';

abstract class BookRepository {
  Future<List<Book>> getAllBooks();
  Future<Book?> getBookById(String bookId);
  Future<List<Book>> getUnlockedBooks(String userId);
  Future<List<Book>> getFavoriteBooks(String userId);
  Future<List<Summary>> getTodayUnlockedSummaries(String userId);
  Future<List<Summary>> getBookSummaries(String bookId);
  Future<Summary?> getSummaryById(String summaryId);
  Future<void> saveBooks(List<Book> books);
  Future<void> unlockBook(String bookId, String userId);
  Future<void> toggleBookFavorite(String bookId, String userId);
  Future<void> unlockSummary(String summaryId, String userId);
  Future<void> markSummaryAsRead(String summaryId, String userId);
  Future<List<Summary>> unlockDailySummaries(String userId, int count);
  Future<Book?> getRandomUnlockedBook(String userId);
  Future<List<Summary>> getUserViewHistory(String userId);
}