// lib/utils/auth_utils.dart
import 'package:flutter/material.dart';

bool isLoggedIn = false; // Variable para simular el estado de login

void checkAuth(BuildContext context) {
  if (!isLoggedIn) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}