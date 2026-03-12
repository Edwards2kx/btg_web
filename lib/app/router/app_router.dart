import 'package:btg_web/features/transactions/ui/pages/history_page.dart';
import 'package:btg_web/features/transactions/ui/pages/invest_page.dart';
import 'package:btg_web/features/portfolio/ui/pages/portfolio_page.dart';
import 'package:btg_web/features/portfolio/ui/pages/profile_page.dart';
import 'package:btg_web/features/shared/ui/layouts/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorDashboardKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellDashboard');
final GlobalKey<NavigatorState> _shellNavigatorInvestKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellInvest');
final GlobalKey<NavigatorState> _shellNavigatorHistoryKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHistory');
final GlobalKey<NavigatorState> _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDashboardKey,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const PortfolioPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorInvestKey,
          routes: [
            GoRoute(
              path: '/invest',
              builder: (context, state) => const InvestPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHistoryKey,
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
