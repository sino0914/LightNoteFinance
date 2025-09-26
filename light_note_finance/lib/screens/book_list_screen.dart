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

            return Stack(
              children: [
                // 主要內容
                Column(
                  children: [
                    // 頂部欄
                    TopBar(points: user?.points ?? 0),

                    Expanded(
                      child: books.isEmpty
                          ? _buildEmptyState()
                          : _buildBookGrid(books),
                    ),
                  ],
                ),

                // 底部選單
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
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
                  // 書籍圖片
                  Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: book.imageUrl.isNotEmpty
                        ? Image.asset(
                            _convertImageUrlToAssetPath(book.imageUrl),
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 30,
                              );
                            },
                          )
                        : const Icon(
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final hasEnoughPoints = user != null && user.points >= AppConstants.bookUnlockCost;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            const Text('解鎖書籍', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.description,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '解鎖需要 ${AppConstants.bookUnlockCost} 積分',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '您目前擁有 ${user?.points ?? 0} 積分',
              style: TextStyle(
                color: hasEnoughPoints ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
          if (hasEnoughPoints)
            ElevatedButton(
              onPressed: () => _purchaseBook(book),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('花費 ${AppConstants.bookUnlockCost} 積分解鎖'),
            )
          else
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

  Future<void> _purchaseBook(Book book) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    try {
      // 扣除積分
      await userProvider.spendPoints(AppConstants.bookUnlockCost);

      // 解鎖書籍
      await bookProvider.unlockBook(book.id);

      if (context.mounted) {
        context.pop(); // 關閉對話框

        // 顯示成功訊息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功解鎖《${book.title}》！'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // 顯示錯誤訊息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('解鎖失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
