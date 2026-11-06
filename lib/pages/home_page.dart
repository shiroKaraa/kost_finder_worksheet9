import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/role_guard.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final p = snap.data;
        if (snap.hasError || p == null) {
          return const Scaffold(
            body: Center(child: Text('Gagal memuat profil')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Kost Finder (${p.role})'),
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(p.name.isEmpty ? p.email : p.name),
                subtitle: Text('${p.email} • ${p.role}'),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.list),
                title: Text('Daftar Kost'),
              ),
              if (p.isPemilikKost || p.isAdmin)
                const ListTile(
                  leading: Icon(Icons.home_work),
                  title: Text('Kost Saya'),
                ),
              if (p.isAdmin)
                const ListTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('Kelola Data (Admin)'),
                ),
            ],
          ),
          floatingActionButton: RoleGuard(
            role: p.role,
            allowed: const ['pemilik_kost', 'admin'],
            child: FloatingActionButton.extended(
              onPressed: () {
                // TODO: Buka halaman Add Kost (akan dibuat di Tahap Selanjutnya)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Tambah Kost segera hadir')),
                );
              },
              icon: const Icon(Icons.add_home),
              label: const Text('Tambah Kost'),
            ),
          ),
        );
      },
    );
  }
}