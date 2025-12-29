// Đã sửa: Sử dụng đúng tên package 'beptroly'
import 'package:beptroly/firebase_options.dart';
import 'package:beptroly/features/home/viewmodels/splash_view_model.dart';
import 'package:beptroly/features/ke_hoach/viewmodels/shopping_list_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:beptroly/app_routes.dart';
import 'package:beptroly/features/goi_y_mon_an/viewmodels/recipe_view_model.dart';
import 'package:beptroly/features/home/viewmodels/home_view_model.dart';
import 'package:beptroly/features/auth/viewmodels/login_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BepTroLyApp());
}

class BepTroLyApp extends StatelessWidget {
  const BepTroLyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
        ChangeNotifierProvider(create: (_) => ShoppingListViewModel()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
      ],
      child: MaterialApp.router(
        title: 'Bếp Trợ Lý',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
