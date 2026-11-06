import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Kost Finder')),
      body: Center(
        child: Text('Login sebagai: ${user?.email ?? '-'}'),
      ),
    );
  }
}