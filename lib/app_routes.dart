import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:beptroly/shared/layout/main_scaffold.dart';

// --- IMPORT CÁC MÀN HÌNH ---
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/register_screen.dart';
import 'features/home/views/home_screen.dart';
// Import Pantry, Planner, Shopping
import 'features/kho_nguyen_lieu/views/pantry_screen.dart';
import 'features/ke_hoach/views/meal_planner_screen.dart';
import 'features/ke_hoach/views/shopping_list_screen.dart';

// --- IMPORT CÁC FILE ---
import 'features/goi_y_mon_an/views/recipe_feed_screen.dart';
import 'features/goi_y_mon_an/views/recipe_detail_screen.dart'; // Mới
import 'features/goi_y_mon_an/models/recipe_model.dart'; // Mới
import 'features/setting/views/setting_screen.dart'; // Mới
import 'features/setting/views/edit_profile_screen.dart';

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
    // --- 1. CÁC ROUTE CỦA NHÁNH CHÍNH (GIỮ NGUYÊN) ---
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Route Gợi ý món ăn (Code cũ của bạn để ở ngoài Shell -> Giữ nguyên)
    GoRoute(
      path: '/recipes',
      builder: (context, state) => const RecipeFeedScreen(),
    ),

    // --- 2. CÁC ROUTE CẦN THÊM ĐỂ APP CHẠY ĐƯỢC ---

    //  Route Chi tiết món ăn (Để khi ấn vào món không bị lỗi)
    GoRoute(
      path: '/recipe_detail',
      builder: (context, state) {
        final recipe = state.extra as RecipeModel;
        return RecipeDetailScreen(recipe: recipe);
      },
    ),

    // Route Cài đặt
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingScreen(),
    ),
    GoRoute(
      path: '/edit_profile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    // --- 3. SHELL ROUTE (BOTTOM NAVIGATION - GIỮ NGUYÊN) ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Nhánh Home
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Nhánh Tủ lạnh
        StatefulShellBranch(
          navigatorKey: _shellNavigatorPantryKey,
          routes: [
            GoRoute(
              path: '/pantry',
              builder: (context, state) => const PantryScreen(),
            ),
          ],
        ),
        // Nhánh Lên lịch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorPlannerKey,
          routes: [
            GoRoute(
              path: '/planner',
              builder: (context, state) => const MealPlannerScreen(),
            ),
          ],
        ),
        // Nhánh Mua sắm
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
  ],
);
