import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/book_list_screen.dart';
import '../screens/summary_screen.dart';
import '../screens/history_screen.dart';
import '../screens/points_screen.dart';
import '../providers/user_provider.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static final Map<String, int> _routeIndexMap = {
    Routes.home: 0,
    Routes.bookList: 1,
    Routes.history: 2,
    Routes.points: 3,
  };

  static int? _previousIndex;

  static int? _getRouteIndex(String path) {
    return _routeIndexMap[path];
  }

  static Page<void> _createAnimatedPage(Widget child, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final currentIndex = _getRouteIndex(state.matchedLocation);
        Offset begin = const Offset(1.0, 0.0); // 預設從右滑入

        if (currentIndex != null && _previousIndex != null) {
          if (currentIndex < _previousIndex!) {
            begin = const Offset(-1.0, 0.0); // 索引減少時從左滑入
          }
        }

        _previousIndex = currentIndex;

        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: Routes.onboarding,
      redirect: (BuildContext context, GoRouterState state) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final isFirstLogin = userProvider.user?.isFirstLogin ?? true;

        if (isFirstLogin && state.uri.toString() != Routes.onboarding) {
          return Routes.onboarding;
        }

        if (!isFirstLogin && state.uri.toString() == Routes.onboarding) {
          return Routes.home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: Routes.onboarding,
          name: 'onboarding',
          pageBuilder: (context, state) => _createAnimatedPage(
            const OnboardingScreen(),
            state,
          ),
        ),
        GoRoute(
          path: Routes.home,
          name: 'home',
          pageBuilder: (context, state) => _createAnimatedPage(
            const HomeScreen(),
            state,
          ),
        ),
        GoRoute(
          path: Routes.bookList,
          name: 'book-list',
          pageBuilder: (context, state) => _createAnimatedPage(
            const BookListScreen(),
            state,
          ),
        ),
        GoRoute(
          path: '${Routes.summary}/:bookId',
          name: 'summary',
          pageBuilder: (context, state) {
            final bookId = state.pathParameters['bookId']!;
            return _createAnimatedPage(
              SummaryScreen(bookId: bookId),
              state,
            );
          },
        ),
        GoRoute(
          path: Routes.history,
          name: 'history',
          pageBuilder: (context, state) => _createAnimatedPage(
            const HistoryScreen(),
            state,
          ),
        ),
        GoRoute(
          path: Routes.points,
          name: 'points',
          pageBuilder: (context, state) => _createAnimatedPage(
            const PointsScreen(),
            state,
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Page not found: ${state.uri.toString()}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}