import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../constants/app_constants.dart';

class BookService {
  Future<List<Book>> getDefaultBooks() async {
    try {
      // 嘗試從 assets 讀取資料
      print('Loading books from assets...');
      final jsonString = await rootBundle.loadString('assets/data/books.json');
      print('JSON loaded successfully, length: ${jsonString.length}');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      print('JSON parsed, found ${jsonData.length} books');
      final books = jsonData.map((json) => Book.fromJson(json)).toList();
      print('Books converted successfully: ${books.map((b) => b.title).toList()}');
      return books;
    } catch (e, stackTrace) {
      print('Failed to load books from assets: $e');
      print('Stack trace: $stackTrace');
    }

    // 如果讀取失敗，返回預設資料
    return [
      Book(
        id: 'book_1',
        title: '投資心理學',
        description: '了解投資市場中的心理陷阱，培養理性投資思維',
        imageUrl: 'assets/images/book1.jpg',
        summaries: _generateSummaries('book_1', '投資心理學', 30),
        isUnlocked: false,
      ),
      Book(
        id: 'book_2',
        title: '財務自由之路',
        description: '從基礎理財到資產配置，打造財務自由的完整指南',
        imageUrl: 'assets/images/book2.jpg',
        summaries: _generateSummaries('book_2', '財務自由之路', 25),
        isUnlocked: false,
      ),
      Book(
        id: 'book_3',
        title: '聰明的投資者',
        description: '價值投資之父班傑明・葛拉漢的經典投資智慧',
        imageUrl: 'assets/images/book3.jpg',
        summaries: _generateSummaries('book_3', '聰明的投資者', 35),
        isUnlocked: false,
      ),
      Book(
        id: 'book_4',
        title: '窮爸爸富爸爸',
        description: '改變金錢觀念，學習富人的思維模式',
        imageUrl: 'assets/images/book4.jpg',
        summaries: _generateSummaries('book_4', '窮爸爸富爸爸', 28),
        isUnlocked: false,
      ),
      Book(
        id: 'book_5',
        title: '股票作手回憶錄',
        description: '傳奇投資者的投機智慧與市場洞察',
        imageUrl: 'assets/images/book5.jpg',
        summaries: _generateSummaries('book_5', '股票作手回憶錄', 32),
        isUnlocked: false,
      ),
    ];
  }

  List<Summary> _generateSummaries(String bookId, String bookTitle, int count) {
    final summaries = <Summary>[];

    for (int i = 1; i <= count; i++) {
      summaries.add(Summary(
        id: '${bookId}_summary_$i',
        bookId: bookId,
        content: _generateSampleContent(bookTitle, i),
        order: i,
        isUnlocked: false,
      ));
    }

    return summaries;
  }

  String _generateSampleContent(String bookTitle, int chapter) {
    final contents = {
      '投資心理學': [
        '市場波動往往受到投資者情緒的影響，理性分析比情緒反應更重要。',
        '過度自信是投資失敗的主要原因之一，保持謙遜的學習態度至關重要。',
        '群體心理會導致泡沫的形成與破滅，獨立思考是成功投資的關鍵。',
        '損失厭惡使投資者過早賣出獲利股票，持有虧損股票太久。',
        '確認偏誤讓投資者只看到支持自己觀點的信息，忽略相反證據。',
      ],
      '財務自由之路': [
        '建立緊急預備金是理財的第一步，應準備3-6個月的生活費。',
        '投資組合多元化可以降低風險，不要把雞蛋放在同一個籃子裡。',
        '定期定額投資能平均成本，降低市場波動對投資的影響。',
        '了解自己的風險承受能力，選擇適合的投資工具。',
        '長期投資比短期投機更容易獲得穩定收益。',
      ],
      '聰明的投資者': [
        '價值投資注重公司的內在價值，而非市場價格的短期波動。',
        '安全邊際是價值投資的核心概念，只在價格遠低於內在價值時買入。',
        '市場先生的比喻說明了市場情緒的不理性，智慧投資者應利用這點。',
        '防禦性投資者應專注於穩定的股票和債券組合。',
        '積極投資者需要更多時間和專業知識來分析個股。',
      ],
      '窮爸爸富爸爸': [
        '資產是能為你帶來現金流的東西，負債是從你口袋拿走錢的東西。',
        '財務教育比學校教育更重要，要學會如何讓錢為你工作。',
        '富人購買資產，窮人購買負債，中產階級購買他們以為是資產的負債。',
        '建立被動收入是實現財務自由的關鍵。',
        '克服恐懼和貪婪，學會控制自己的情緒。',
      ],
      '股票作手回憶錄': [
        '市場永遠是對的，不要與趨勢作對。',
        '耐心等待絕佳機會，不要頻繁交易。',
        '資金管理比選股技巧更重要。',
        '學會止損，保護資本是第一要務。',
        '研究市場規律，掌握買賣時機。',
      ],
    };

    final bookContents = contents[bookTitle] ?? ['這是一個示例內容。'];
    final contentIndex = (chapter - 1) % bookContents.length;
    return bookContents[contentIndex];
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
      final randomBook = books[random.nextInt(books.length)];
      final unlockedSummaries = randomBook.summaries
          .where((s) => !s.isUnlocked)
          .take(count)
          .toList();

      for (final summary in unlockedSummaries) {
        final summaryIndex = randomBook.summaries.indexOf(summary);
        if (summaryIndex != -1) {
          randomBook.summaries[summaryIndex] = summary.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
        }
      }

      return unlockedSummaries;
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