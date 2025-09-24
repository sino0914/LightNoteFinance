import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/book.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/bottom_navigation_menu.dart';
import '../widgets/top_bar.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBooks();
    });
  }

  Future<void> _loadBooks() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    await bookProvider.initializeBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Consumer2<UserProvider, BookProvider>(
          builder: (context, userProvider, bookProvider, child) {
            if (bookProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final user = userProvider.user;
            final books = bookProvider.books;

            return Column(
              children: [
                // 頂部欄
                TopBar(points: user?.points ?? 0),

                Expanded(
                  child: books.isEmpty
                      ? _buildEmptyState()
                      : _buildBookGrid(books),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomNavigationMenu(
                    currentIndex: 1,
                    onTap: (index) {
                      _handleMenuTap(context, index);
                    },
                    onCollapse: () {},
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookGrid(List<Book> books) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return _buildBookCard(books[index]);
        },
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return GestureDetector(
      onTap: () => _viewBook(book),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF16213E), const Color(0xFF0F3460)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景裝飾
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),

            // 主要內容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 書籍圖標
                  Container(
                    width: 50,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 書名
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 描述
                  Expanded(
                    child: Text(
                      book.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.3,
                      ),
                      maxLines: 3,
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
                          color: book.isUnlocked
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          book.isUnlocked ? '已解鎖' : '未解鎖',
                          style: TextStyle(
                            fontSize: 10,
                            color: book.isUnlocked
                                ? Colors.green.withValues(alpha: 0.9)
                                : Colors.orange.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      if (book.isFavorite)
                        Icon(
                          Icons.favorite,
                          color: Colors.red.withValues(alpha: 0.8),
                          size: 16,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 未解鎖遮罩
            if (!book.isUnlocked)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white, size: 32),
                ),
              ),
          ],
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
            Icons.library_books_outlined,
            size: 60,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '尚無書籍資料',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _viewBook(Book book) {
    if (book.isUnlocked) {
      context.go('${Routes.summary}/${book.id}');
    } else {
      _showUnlockDialog(book);
    }
  }

  void _showUnlockDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('書籍未解鎖', style: TextStyle(color: Colors.white)),
        content: Text(
          '這本書尚未解鎖，您可以使用積分解鎖或等待每日自動解鎖。',
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
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.go(Routes.points);
            },
            child: const Text('前往商店', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  void _handleMenuTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        // 已在書單
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
