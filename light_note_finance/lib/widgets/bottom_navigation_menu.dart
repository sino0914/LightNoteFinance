import 'package:flutter/material.dart';

class BottomNavigationMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCollapse;

  const BottomNavigationMenu({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // 防止點擊背景時關閉
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 收合按鈕
                GestureDetector(
                  onTap: onCollapse,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 導航按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.home,
                      label: '首頁',
                      index: 0,
                      isSelected: currentIndex == 0,
                    ),
                    _buildNavItem(
                      icon: Icons.library_books,
                      label: '書單',
                      index: 1,
                      isSelected: currentIndex == 1,
                    ),
                    _buildNavItem(
                      icon: Icons.history,
                      label: '歷史紀錄',
                      index: 2,
                      isSelected: currentIndex == 2,
                    ),
                    _buildNavItem(
                      icon: Icons.stars,
                      label: '積分',
                      index: 3,
                      isSelected: currentIndex == 3,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}