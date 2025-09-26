import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';
import '../widgets/daily_summary_banner.dart';
import '../widgets/bottom_navigation_menu.dart';
import '../constants/app_constants.dart';
import '../widgets/top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMenuExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadDailySummaries();
  }

  Future<void> _loadDailySummaries() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user != null) {
      // 檢查是否為初次登入
      if (userProvider.user!.isFirstLogin) {
        // 初次登入：檢查今天是否已經解鎖過
        final today = DateTime.now();
        final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        if (!userProvider.user!.dailyUnlockHistory.containsKey(todayKey)) {
          // 今天還沒解鎖，執行解鎖邏輯
          await bookProvider.unlockDailySummaries(
            userProvider.user!.settings.dailySummaryCount
          );
        }
      } else {
        // 非初次登入：顯示隨機已解鎖摘要
        await _loadRandomUnlockedSummaries();
      }

      await userProvider.updateWeeklyActivity();
    }
  }

  Future<void> _loadRandomUnlockedSummaries() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user != null && bookProvider.books.isNotEmpty) {
      // 獲取已解鎖的書籍
      final unlockedBooks = bookProvider.books.where((book) => book.isUnlocked).toList();

      if (unlockedBooks.isNotEmpty) {
        // 隨機選擇一本已解鎖的書
        final random = Random();
        final randomBook = unlockedBooks[random.nextInt(unlockedBooks.length)];

        // 獲取該書籍的已解鎖摘要
        final unlockedSummaries = randomBook.summaries.where((summary) => summary.isUnlocked).toList();

        if (unlockedSummaries.isNotEmpty) {
          // 隨機打亂摘要順序，然後取最多10則
          unlockedSummaries.shuffle(random);
          final randomSummaries = unlockedSummaries.take(10).toList();

          // 設置為今日摘要顯示
          bookProvider.setTodaySummaries(randomSummaries);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Consumer2<UserProvider, BookProvider>(
          builder: (context, userProvider, bookProvider, child) {
            if (userProvider.isLoading || bookProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final user = userProvider.user;
            final todaySummaries = bookProvider.todaySummaries;

            return Stack(
              children: [
                // 主要內容
                Column(
                  children: [
                    // 頂部欄
                    TopBar(points:user?.points ?? 0),

                    // 主要內容區域
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // 今日摘要Banner
                            if (todaySummaries.isNotEmpty)
                              DailySummaryBanner(summaries: todaySummaries)
                            else
                              _buildEmptyState(),

                            const SizedBox(height: 40),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 底部選單（收合狀態）
                if (!_isMenuExpanded)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(child: _buildCollapsedMenu()),
                  ),

                // 底部選單（展開狀態）
                if (_isMenuExpanded)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BottomNavigationMenu(
                      currentIndex: 0,
                      onTap: (index) {
                        _handleMenuTap(context, index);
                      },
                      onCollapse: () {
                        setState(() {
                          _isMenuExpanded = false;
                        });
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.book_outlined,
            size: 60,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '今日暫無新摘要',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '明天再來看看吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCollapsedMenu() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMenuExpanded = true;
        });
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.keyboard_arrow_up,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _handleMenuTap(BuildContext context, int index) {
    setState(() {
      _isMenuExpanded = false;
    });

    switch (index) {
      case 0:
        // 已在首頁
        break;
      case 1:
        context.go(Routes.bookList);
        break;
      case 2:
        context.go(Routes.history);
        break;
      case 3:
        context.go(Routes.points);
        break;
    }
  }
}