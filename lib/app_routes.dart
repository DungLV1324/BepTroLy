import 'package:beptroly/shared/layout/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/register_screen.dart';
import 'features/goi_y_mon_an/views/recipe_feed_screen.dart';
import 'features/home/views/home_screen.dart';
import 'features/kho_nguyen_lieu/views/pantry_screen.dart';
import 'features/goi_y_mon_an/views/recipe_detail_screen.dart';
import 'features/goi_y_mon_an/models/recipe_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellHome',
);
final _shellNavigatorPantryKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellPantry',
);
final _shellNavigatorPlannerKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellPlanner',
);
final _shellNavigatorShoppingKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellShopping',
);

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/recipes',
      builder: (context, state) => const RecipeFeedScreen(),
    ),

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
              routes: [
                GoRoute(
                  path: 'recipes',
                  builder: (context, state) => const RecipeFeedScreen(),
                ),
                GoRoute(
                  path: 'recipe_detail',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final recipe = state.extra as RecipeModel;
                    return RecipeDetailScreen(recipe: recipe);
                  },
                ),
              ],
            ),
          ],
        ),

        StatefulShellBranch(
          navigatorKey: _shellNavigatorPantryKey,
          routes: [
            GoRoute(
              path: '/pantry',
              builder: (context, state) => const PantryScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          navigatorKey: _shellNavigatorPlannerKey,
          routes: [
            GoRoute(
              path: '/planner',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text("Màn hình Lên lịch")),
              ),
            ),
          ],
        ),

        StatefulShellBranch(
          navigatorKey: _shellNavigatorShoppingKey,
          routes: [
            GoRoute(
              path: '/shopping',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text("Màn hình Mua sắm"))),
            ),
          ],
        ),
      ],
    ),
  ],
);
