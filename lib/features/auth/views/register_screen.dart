import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<RegisterViewModel>();
    final success = await viewModel.signUp(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (success && context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1D26)),
            onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
          ),
        ),
        body: Consumer<RegisterViewModel>(
          builder: (context, viewModel, child) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                // Đã thêm: Bọc trong widget Form
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Register a New Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Create an account to get started.', style: TextStyle(color: Color(0xFF6C707A), fontSize: 14)),
                      const SizedBox(height: 32),

                      // Đã sửa: Sử dụng TextFormField với validation
                      _buildLabel('Full name'),
                      TextFormField(
                        controller: _nameController,
                        decoration: _buildInputDecoration(hintText: 'Your name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first and last name..';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Email'),
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration(hintText: 'bantroly@email.com'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address..';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Invalid email.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Password'),
                      TextFormField(
                        controller: _passwordController,
                        decoration: _buildInputDecoration(hintText: '••••••••', isPassword: true),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the password.';
                          }
                          if (value.length < 6) {
                            return 'Invalid Password.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Hiển thị lỗi từ Firebase
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(viewModel.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          // Đã sửa: Gọi hàm _handleSignUp
                          onPressed: viewModel.isLoading ? null : () => _handleSignUp(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: viewModel.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget Helper
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, bool isPassword = false}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFA0A4A8), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: isPassword ? const Icon(Icons.visibility_off_outlined, color: Colors.grey) : null,
    );
  }
}