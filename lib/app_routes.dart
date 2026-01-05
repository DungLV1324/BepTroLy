import 'features/goi_y_mon_an/models/recipe_model.dart';
import 'features/goi_y_mon_an/views/recipe_detail_screen.dart';
import 'package:beptroly/features/home/views/splash_screen.dart';
import 'features/ke_hoach/views/meal_planner_add.dart';
import 'features/ke_hoach/views/meal_planner_screen.dart';
import 'features/Shopping/views/shopping_list_screen.dart';
import 'package:beptroly/shared/layout/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/login_email.dart' as login_email;
import 'features/auth/views/register_screen.dart';
import 'features/goi_y_mon_an/views/recipe_feed_screen.dart';
import 'features/home/views/home_screen.dart';
import 'features/kho_nguyen_lieu/views/pantry_screen.dart';
import 'features/setting/views/edit_profile_screen.dart';
import 'features/setting/views/setting_screen.dart';


final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorPantryKey = GlobalKey<NavigatorState>(debugLabel: 'shellPantry');
final _shellNavigatorPlannerKey = GlobalKey<NavigatorState>(debugLabel: 'shellPlanner');
final _shellNavigatorShoppingKey = GlobalKey<NavigatorState>(debugLabel: 'shellShopping');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
      routes: [
        GoRoute(
          path: 'email',
          builder: (context, state) => const login_email.LoginScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/recipes',
      builder: (context, state) => const RecipeFeedScreen(),
    ),

    GoRoute(
      path: '/recipe_detail',
      parentNavigatorKey: _rootNavigatorKey, // Che BottomBar
      builder: (context, state) {
        final recipe = state.extra as RecipeModel;
        return RecipeDetailScreen(recipe: recipe);
      },
    ),

    GoRoute(
      path: '/edit_profile',
      builder: (context, state) => const EditProfileScreen(),
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
                  parentNavigatorKey:
                      _rootNavigatorKey, // Che BottomBar khi xem chi tiết (Tùy chọn)
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
              builder: (context, state) => const WeeklyMealPlannerScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const MealPlannerScreen(),
                ),
              ],
            ),
          ],
        ),

        StatefulShellBranch(
          navigatorKey: _shellNavigatorShoppingKey,
          routes: [
            GoRoute(
              path: '/shopping',
              builder: (context, state) => const ShoppingListScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingScreen(),
    ),
  ],
);