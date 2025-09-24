import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/book.dart';
import '../models/purchase_item.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/bottom_navigation_menu.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  final List<PurchaseItem> _storeItems = [
    PurchaseItem(
      id: 'unlock_book',
      title: '解鎖一本書',
      description: '立即解鎖任意一本書籍，包含所有章節摘要',
      price: 100,
      type: PurchaseItemType.chooseBooks,
    ),
    PurchaseItem(
      id: 'unlock_chapter',
      title: '解鎖一章摘要',
      description: '解鎖指定書籍的一個章節摘要',
      price: 20,
      type: PurchaseItemType.extraDailySummary,
    ),
    PurchaseItem(
      id: 'daily_boost',
      title: '每日摘要加速',
      description: '今日額外獲得3篇摘要解鎖',
      price: 50,
      type: PurchaseItemType.watchAd,
    ),
    PurchaseItem(
      id: 'weekly_boost',
      title: '週度摘要增強',
      description: '本週每日摘要數量+1（共7天）',
      price: 200,
      type: PurchaseItemType.bookmarkFeature,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;
            final points = user?.points ?? 0;

            return Column(
              children: [
                const SizedBox(height: 20),
                _buildPointsCard(points),
                const SizedBox(height: 20),
                _buildStoreSection(),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomNavigationMenu(
                    currentIndex: 3,
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

  Widget _buildPointsCard(int points) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: 0.2),
            Colors.orange.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.stars,
              color: Colors.amber,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '我的積分',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$points',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '每日閱讀可獲得積分',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _storeItems.length,
              itemBuilder: (context, index) {
                return _buildStoreItem(_storeItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItem(PurchaseItem item) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userPoints = userProvider.user?.points ?? 0;
        final canAfford = userPoints >= item.price;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
            child: Row(
              children: [
                // 商品圖標
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getItemIconColor(item.type).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getItemIcon(item.type),
                    color: _getItemIconColor(item.type),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // 商品資訊
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 購買按鈕
                GestureDetector(
                  onTap: canAfford ? () => _purchaseItem(item) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: canAfford
                          ? Colors.amber
                          : Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      canAfford ? '購買' : '積分不足',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canAfford
                            ? Colors.black
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getItemIcon(PurchaseItemType type) {
    switch (type) {
      case PurchaseItemType.chooseBooks:
        return Icons.book;
      case PurchaseItemType.extraDailySummary:
        return Icons.article;
      case PurchaseItemType.bookmarkFeature:
        return Icons.bookmark;
      case PurchaseItemType.highlightFeature:
        return Icons.highlight;
      case PurchaseItemType.watchAd:
        return Icons.play_circle;
    }
  }

  Color _getItemIconColor(PurchaseItemType type) {
    switch (type) {
      case PurchaseItemType.chooseBooks:
        return Colors.blue;
      case PurchaseItemType.extraDailySummary:
        return Colors.green;
      case PurchaseItemType.bookmarkFeature:
        return Colors.purple;
      case PurchaseItemType.highlightFeature:
        return Colors.yellow;
      case PurchaseItemType.watchAd:
        return Colors.orange;
    }
  }

  Future<void> _purchaseItem(PurchaseItem item) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    switch (item.type) {
      case PurchaseItemType.chooseBooks:
        _showBookSelectionDialog();
        break;
      case PurchaseItemType.extraDailySummary:
        _showSummarySelectionDialog();
        break;
      case PurchaseItemType.bookmarkFeature:
      case PurchaseItemType.highlightFeature:
      case PurchaseItemType.watchAd:
        _showPurchaseConfirmation(item, () async {
          if (item.id == 'daily_boost') {
            // 今日額外解鎖3篇摘要
            await bookProvider.unlockDailySummaries(3);
          } else if (item.id == 'weekly_boost') {
            // 週度增強功能
            await userProvider.activateWeeklyBoost();
          }
          await userProvider.spendPoints(item.price);
        });
        break;
    }
  }

  void _showBookSelectionDialog() {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final availableBooks = bookProvider.books.where((book) => !book.isUnlocked).toList();

    if (availableBooks.isEmpty) {
      _showInfoDialog('提示', '所有書籍都已解鎖！');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          '選擇要解鎖的書籍',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: availableBooks.length,
            itemBuilder: (context, index) {
              final book = availableBooks[index];
              return ListTile(
                title: Text(
                  book.title,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  book.description,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  context.pop();
                  _confirmBookPurchase(book);
                },
              );
            },
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
              '取消',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSummarySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          '選擇摘要解鎖',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '此功能需要在特定書籍頁面中使用。',
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
              '知道了',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBookPurchase(Book book) {
    _showPurchaseConfirmation(
      _storeItems.firstWhere((item) => item.type == PurchaseItemType.chooseBooks),
      () async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final bookProvider = Provider.of<BookProvider>(context, listen: false);

        await bookProvider.unlockBook(book.id);
        await userProvider.spendPoints(100);
      },
      extraInfo: '將解鎖書籍：${book.title}',
    );
  }

  void _showPurchaseConfirmation(PurchaseItem item, VoidCallback onConfirm, {String? extraInfo}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          '確認購買',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '商品：${item.title}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '費用：${item.price} 積分',
              style: const TextStyle(color: Colors.amber),
            ),
            if (extraInfo != null) ...[
              const SizedBox(height: 8),
              Text(
                extraInfo,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ],
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
              onConfirm();
              _showSuccessDialog();
            },
            child: const Text(
              '確認購買',
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          '購買成功',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '您的購買已完成！',
          style: TextStyle(color: Colors.white),
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
              '確定',
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
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
              '確定',
              style: TextStyle(color: Colors.white),
            ),
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
        context.go(Routes.bookList);
        break;
      case 2:
        context.go(Routes.history);
        break;
      case 3:
        // 已在積分
        break;
    }
  }
}