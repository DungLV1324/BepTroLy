import 'package:beptroly/shared/layout/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/views/home_screen.dart';
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorPantryKey = GlobalKey<NavigatorState>(debugLabel: 'shellPantry');
final _shellNavigatorPlannerKey = GlobalKey<NavigatorState>(debugLabel: 'shellPlanner');
final _shellNavigatorShoppingKey = GlobalKey<NavigatorState>(debugLabel: 'shellShopping');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          navigatorKey: _shellNavigatorPantryKey,
          routes: [
            GoRoute(
              path: '/pantry',
              builder: (context, state) => const Scaffold(body: Center(child: Text("Màn hình Tủ lạnh"))),
            ),
          ],
        ),

        StatefulShellBranch(
          navigatorKey: _shellNavigatorPlannerKey,
          routes: [
            GoRoute(
              path: '/planner',
              builder: (context, state) => const Scaffold(body: Center(child: Text("Màn hình Lên lịch"))),
            ),
          ],
        ),

        StatefulShellBranch(
          navigatorKey: _shellNavigatorShoppingKey,
          routes: [
            GoRoute(
              path: '/shopping',
              builder: (context, state) => const Scaffold(body: Center(child: Text("Màn hình Mua sắm"))),
            ),
          ],
        ),
      ],
    ),
  ],
);