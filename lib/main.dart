import 'features/auth/viewmodels/login_view_model.dart';
import 'features/home/viewmodels/splash_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:beptroly/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app_routes.dart';
import 'features/goi_y_mon_an/viewmodels/recipe_view_model.dart';
import 'features/home/viewmodels/home_view_model.dart';
import 'features/shopping/viewmodels/shopping_list_view_model.dart';
import 'features/thongbao/services/notification_service.dart';
import 'features/setting/viewmodels/setting_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  await dotenv.load(fileName: ".env");
  runApp(const BepTroLyApp());
}

class BepTroLyApp extends StatelessWidget {
  const BepTroLyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingViewModel()..fetchUserSettings(),),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
        ChangeNotifierProvider(create: (_) => ShoppingListViewModel()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
      ],
      child: Consumer<SettingViewModel>(
        builder: (context, settingVM, child) {
          return MaterialApp.router(
            title: 'Bếp Trợ Lý',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepOrange,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF9F9F9),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepOrange,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
            ),
            themeMode: settingVM.isDarkModeOn
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}