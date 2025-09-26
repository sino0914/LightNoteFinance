import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../constants/app_constants.dart';

class BookService {
  String _convertImageUrlToAssetPath(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'assets/images/default-book.png';
    }

    // 如果是 ../uploads/ 格式，轉換為 assets/uploads/
    if (imageUrl.startsWith('../uploads/')) {
      final filename = imageUrl.replaceFirst('../uploads/', '');
      return 'assets/uploads/$filename';
    }

    // 如果是 /uploads/ 格式，轉換為 assets/uploads/
    if (imageUrl.startsWith('/uploads/')) {
      final filename = imageUrl.replaceFirst('/uploads/', '');
      return 'assets/uploads/$filename';
    }

    // 如果已經是正確的 assets/ 格式，直接返回
    if (imageUrl.startsWith('assets/')) {
      return imageUrl;
    }

    // 默認情況，假設是檔名，加上 assets/uploads/ 前綴
    return 'assets/uploads/$imageUrl';
  }

  Future<List<Book>> getDefaultBooks() async {
    try {
      // 嘗試從 assets 讀取資料
      print('Loading books from assets...');
      final jsonString = await rootBundle.loadString('assets/data/books.json');
      print('JSON loaded successfully, length: ${jsonString.length}');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      print('JSON parsed, found ${jsonData.length} books');

      final books = jsonData.map((json) {
        final book = Book.fromJson(json);
        // 轉換 imageUrl 為正確的 asset 路徑
        return book.copyWith(
          imageUrl: _convertImageUrlToAssetPath(book.imageUrl),
        );
      }).toList();

      print('Books converted successfully: ${books.map((b) => b.title).toList()}');
      return books;
    } catch (e, stackTrace) {
      print('Failed to load books from assets: $e');
      print('Stack trace: $stackTrace');
    }

    // 如果讀取失敗，返回空資料
    return [];
  }

  Future<List<Summary>> getTodayUnlockedSummaries(List<Book> books) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todaySummaries = <Summary>[];

    for (final book in books) {
      for (final summary in book.summaries) {
        if (summary.isUnlocked &&
            summary.unlockedAt != null &&
            summary.unlockedAt!.isAfter(todayStart) &&
            summary.unlockedAt!.isBefore(todayEnd)) {
          todaySummaries.add(summary);
        }
      }
    }

    todaySummaries.sort((a, b) => a.unlockedAt!.compareTo(b.unlockedAt!));
    return todaySummaries.take(AppConstants.defaultDailySummaryCount).toList();
  }

  Future<List<Summary>> unlockDailySummaries(List<Book> books, int count) async {
    final unlockedSummaries = <Summary>[];
    final random = Random();

    final availableSummaries = <Summary>[];
    for (final book in books) {
      if (book.isUnlocked) {
        for (final summary in book.summaries) {
          if (!summary.isUnlocked) {
            availableSummaries.add(summary);
          }
        }
      }
    }

    if (availableSummaries.isEmpty) {
      // 當可解鎖的摘要為0時，才解鎖新書
      final lockedBooks = books.where((book) => !book.isUnlocked).toList();
      if (lockedBooks.isEmpty) {
        return []; // 沒有新書可以解鎖
      }

      final randomBook = lockedBooks[random.nextInt(lockedBooks.length)];

      // 先解鎖書籍本身
      final bookIndex = books.indexOf(randomBook);
      if (bookIndex != -1) {
        books[bookIndex] = randomBook.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }

      // 然後解鎖該書籍的摘要
      final newUnlockedSummaries = books[bookIndex].summaries
          .where((s) => !s.isUnlocked)
          .take(count)
          .toList();

      for (final summary in newUnlockedSummaries) {
        final summaryIndex = books[bookIndex].summaries.indexOf(summary);
        if (summaryIndex != -1) {
          books[bookIndex].summaries[summaryIndex] = summary.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
        }
      }

      return newUnlockedSummaries;
    }

    availableSummaries.shuffle(random);
    final summariesToUnlock = availableSummaries.take(count).toList();

    for (final summary in summariesToUnlock) {
      for (final book in books) {
        final summaryIndex = book.summaries
            .indexWhere((s) => s.id == summary.id);

        if (summaryIndex != -1) {
          book.summaries[summaryIndex] = summary.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
          unlockedSummaries.add(book.summaries[summaryIndex]);
          break;
        }
      }
    }

    return unlockedSummaries;
  }

  Future<Book?> getRandomUnlockedBook(List<Book> books) async {
    final availableBooks = books.where((book) => !book.isUnlocked).toList();

    if (availableBooks.isEmpty) return null;

    final random = Random();
    return availableBooks[random.nextInt(availableBooks.length)];
  }
}