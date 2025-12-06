import 'package:flutter/material.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lưu ý: Dùng Scaffold con bên trong Scaffold cha (MainLayout) hoàn toàn ổn
    // Giúp mỗi màn hình có AppBar và FloatingActionButton riêng biệt
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho Nguyên Liệu'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: const Center(
        child: Text('Danh sách nguyên liệu sẽ hiện ở đây'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Điều hướng sang màn hình thêm đồ
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}