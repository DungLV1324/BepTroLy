import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashViewModel with ChangeNotifier {
  void startTimer(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      GoRouter.of(context).go('/login');
    });
  }
}
