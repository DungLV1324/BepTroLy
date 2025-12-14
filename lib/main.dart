import 'features/home/viewmodels/splash_view_model.dart';
import 'features/ke_hoach/viewmodels/shopping_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app_routes.dart';
import 'features/goi_y_mon_an/viewmodels/recipe_view_model.dart';
import 'features/home/viewmodels/home_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const BepTroLyApp());
}

class BepTroLyApp extends StatelessWidget {
  const BepTroLyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
        ChangeNotifierProvider(create: (_) => ShoppingListViewModel()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()), // Đã thêm
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
