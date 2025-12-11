import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        indicatorColor: const Color(0xFF4CAF50).withOpacity(0.2),

        // --- LOGIC QUAN TRỌNG Ở ĐÂY ---
        onDestinationSelected: (index) {
          // Hàm goBranch có sẵn tính năng:
          // Nếu initialLocation là true -> Nó sẽ POP hết các màn hình con để về gốc
          navigationShell.goBranch(
            index,
            // Nếu ấn vào Tab đang đứng (index == currentIndex) -> Thì Reset về gốc (true)
            // Nếu ấn sang Tab khác -> Thì chỉ chuyển Tab thôi (false)
            initialLocation: index == navigationShell.currentIndex,
          );
        },

        // -----------------------------
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.green),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen,color: Colors.green),
            label: 'Tủ lạnh',
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month,color: Colors.green),
            label: 'Lên lịch',
          ),

          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart,color: Colors.green),
            label: 'Mua sắm',
          ),
        ],
      ),
    );
  }
}