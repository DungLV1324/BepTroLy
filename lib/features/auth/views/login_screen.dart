import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      print("Lỗi: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.soup_kitchen, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text("BẾP TRỢ LÝ (DEV MODE)", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: _signInAnonymously,
              icon: const Icon(Icons.login),
              label: const Text("Vào Test Nhanh (Không cần Pass)"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}