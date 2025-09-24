import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../constants/app_constants.dart';

class DailySummaryBanner extends StatefulWidget {
  final List<Summary> summaries;

  const DailySummaryBanner({
    super.key,
    required this.summaries,
  });

  @override
  State<DailySummaryBanner> createState() => _DailySummaryBannerState();
}

class _DailySummaryBannerState extends State<DailySummaryBanner> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Banner滑動區域
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.summaries.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final summary = widget.summaries[index];
              return _buildSummaryCard(summary);
            },
          ),
        ),

        const SizedBox(height: 16),

        // 頁面指示器
        if (widget.summaries.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.summaries.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentIndex
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

        const SizedBox(height: 20),

        // 書名和操作
        _buildBookInfo(widget.summaries[_currentIndex]),
      ],
    );
  }

  Widget _buildSummaryCard(Summary summary) {
    return GestureDetector(
      onTap: () => _readSummary(context, summary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景裝飾
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),

            // 內容
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 內容
                  Expanded(
                    child: Text(
                      summary.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 底部資訊
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '第${summary.order}章',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (summary.isRead)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.withValues(alpha: 0.8),
                              size: 20,
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfo(Summary summary) {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        final book = bookProvider.getBookById(summary.bookId);
        if (book == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => _viewBook(context, book),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // 書籍圖標
                  Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 書籍詳情
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // 箭頭圖標提示可點擊
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _readSummary(BuildContext context, Summary summary) async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    if (!summary.isRead) {
      await bookProvider.markSummaryAsRead(summary.id);
    }

    if (context.mounted) {
      context.go('${Routes.summary}/${summary.bookId}');
    }
  }

  void _viewBook(BuildContext context, Book book) {
    context.go('${Routes.summary}/${book.id}');
  }
}