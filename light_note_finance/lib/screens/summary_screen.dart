import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/book.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';

class SummaryScreen extends StatefulWidget {
  final String bookId;

  const SummaryScreen({super.key, required this.bookId});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Book? _book;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookData();
    });
  }

  Future<void> _loadBookData() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final book = bookProvider.getBookById(widget.bookId);

    setState(() {
      _book = book;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _book == null
                ? _buildNotFoundState()
                : _buildContent(),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 60,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '找不到此書籍',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: const Text(
              '返回',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _book!.summaries.isEmpty
              ? _buildEmptyState()
              : _buildSummaryList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 導航列
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _book!.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildFavoriteButton(),
            ],
          ),

          const SizedBox(height: 20),

          // 書籍資訊卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 書籍圖標
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.book,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(width: 20),

                // 書籍詳情
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _book!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _book!.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _book!.isUnlocked
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _book!.isUnlocked ? '已解鎖' : '未解鎖',
                              style: TextStyle(
                                fontSize: 12,
                                color: _book!.isUnlocked
                                    ? Colors.green.withValues(alpha: 0.9)
                                    : Colors.orange.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '共 ${_book!.summaries.length} 章',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        return GestureDetector(
          onTap: () => _toggleFavorite(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _book!.isFavorite
                  ? Colors.red.withValues(alpha: 0.2)
                  : const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _book!.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _book!.isFavorite
                  ? Colors.red.withValues(alpha: 0.8)
                  : Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: _book!.summaries.length,
        itemBuilder: (context, index) {
          final summary = _book!.summaries[index];
          return _buildSummaryCard(summary, index);
        },
      ),
    );
  }

  Widget _buildSummaryCard(Summary summary, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _readSummary(summary),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 章節標題
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
                      const Spacer(),
                      if (summary.isRead)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.withValues(alpha: 0.8),
                          size: 16,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),


                  // 摘要內容
                  Text(
                    summary.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
                          color: summary.isUnlocked
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          summary.isUnlocked ? '已解鎖' : '未解鎖',
                          style: TextStyle(
                            fontSize: 10,
                            color: summary.isUnlocked
                                ? Colors.green.withValues(alpha: 0.9)
                                : Colors.orange.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      if (summary.isUnlocked)
                        Text(
                          '點擊閱讀',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // 未解鎖遮罩
              if (!summary.isUnlocked)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 60,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '此書籍暫無摘要',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _readSummary(Summary summary) async {
    if (!summary.isUnlocked) {
      _showUnlockDialog(summary);
      return;
    }

    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    if (!summary.isRead) {
      await bookProvider.markSummaryAsRead(summary.id);
      // 重新載入書籍資料以更新狀態
      _loadBookData();
    }

    // 這裡可以導航到詳細閱讀頁面
    _showReadingDialog(summary);
  }

  void _showUnlockDialog(Summary summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          '摘要未解鎖',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '這個摘要尚未解鎖，您可以使用積分解鎖或等待每日自動解鎖。',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: const Text(
              '取消',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              // 導航到商店頁面
            },
            child: const Text(
              '前往商店',
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  void _showReadingDialog(Summary summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        content: SingleChildScrollView(
          child: Text(
            summary.content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: const Text(
              '關閉',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    await bookProvider.toggleBookFavorite(widget.bookId);
    _loadBookData();
  }
}