import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/book.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/top_bar.dart';
import '../widgets/bottom_navigation_menu.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Summary> _viewHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadViewHistory();
    });
  }

  Future<void> _loadViewHistory() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    if (userProvider.user != null) {
      final history = await bookProvider.getUserViewHistory(
        userProvider.user!.id,
      );
      setState(() {
        _viewHistory = history;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Consumer2<UserProvider, BookProvider>(
          builder: (context, userProvider, bookProvider, child) {
            final user = userProvider.user;
            return Column(
              children: [
                TopBar(points: user?.points ?? 0),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _viewHistory.isEmpty
                      ? _buildEmptyState()
                      : _buildHistoryList(),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BottomNavigationMenu(
                      currentIndex: 2,
                      onTap: (index) {
                        _handleMenuTap(context, index);
                      },
                      onCollapse: () {
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

  Widget _buildHistoryList() {
    // 按日期分組
    final groupedHistory = _groupHistoryByDate();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        final date = groupedHistory.keys.elementAt(index);
        final summaries = groupedHistory[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期標題
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),

            // 該日期的摘要列表
            ...summaries.map((summary) => _buildHistoryCard(summary)).toList(),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(Summary summary) {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        final book = bookProvider.getBookById(summary.bookId);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _viewSummary(summary),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF16213E), const Color(0xFF0F3460)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 書籍和章節資訊
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '第${summary.order}章',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          book?.title ?? '未知書籍',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(summary.readAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),


                  // 摘要內容預覽
                  Text(
                    summary.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // 底部操作
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.withValues(alpha: 0.8),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 60,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '尚無閱讀歷史',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '開始閱讀摘要來建立您的歷史記錄',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<Summary>> _groupHistoryByDate() {
    final Map<DateTime, List<Summary>> grouped = {};

    for (final summary in _viewHistory) {
      if (summary.readAt != null) {
        final date = DateTime(
          summary.readAt!.year,
          summary.readAt!.month,
          summary.readAt!.day,
        );

        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(summary);
      }
    }

    // 按日期倒序排列
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final Map<DateTime, List<Summary>> sortedGrouped = {};
    for (final key in sortedKeys) {
      // 同一天內按閱讀時間倒序排列
      grouped[key]!.sort((a, b) => b.readAt!.compareTo(a.readAt!));
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return '今天';
    } else if (date == yesterday) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _viewSummary(Summary summary) {
    context.go('${Routes.summary}/${summary.bookId}');
  }

  void _handleMenuTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.bookList);
        break;
      case 2:
        // 已在歷史紀錄
        break;
      case 3:
        context.go(Routes.points);
        break;
    }
  }
}
