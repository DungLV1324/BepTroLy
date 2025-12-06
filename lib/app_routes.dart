import 'package:beptroly/shared/layout/main_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'features/auth/views/auth_gate.dart';
import 'features/auth/views/login_screen.dart';
import 'features/goi_y_mon_an/views/recipe_feed_screen.dart';
import 'features/ke_hoach/views/meal_planner_screen.dart';
import 'features/ke_hoach/views/shopping_list_screen.dart';
import 'features/kho_nguyen_lieu/views/pantry_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorRecipeKey = GlobalKey<NavigatorState>(debugLabel: 'shellRecipe');
final _shellNavigatorPantryKey = GlobalKey<NavigatorState>(debugLabel: 'shellPantry');
final _shellNavigatorShoppingKey = GlobalKey<NavigatorState>(debugLabel: 'shellShopping');
final _shellNavigatorPlannerKey = GlobalKey<NavigatorState>(debugLabel: 'shellPlanner');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorRecipeKey,
          routes: [
            GoRoute(
              path: '/recipe',
              builder: (context, state) => const RecipeFeedScreen(),
            ),
          ],
        ),

        // Nhánh 1: Kho (Pantry)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorPantryKey,
          routes: [
            GoRoute(
              path: '/pantry',
              builder: (context, state) => const PantryScreen(),
            ),
          ],
        ),

        // Nhánh 2: Mua sắm
        StatefulShellBranch(
          navigatorKey: _shellNavigatorShoppingKey,
          routes: [
            GoRoute(
              path: '/shopping',
              builder: (context, state) => const ShoppingListScreen(),
            ),
          ],
        ),

        // Nhánh 3: Lịch ăn
        StatefulShellBranch(
          navigatorKey: _shellNavigatorPlannerKey,
          routes: [
            GoRoute(
              path: '/planner',
              builder: (context, state) => const MealPlannerScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

