import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/kos_service.dart';
import '../services/profile_service.dart';
import '../widgets/role_guard.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserProfile?> _profileFuture;
  late Future<List<Map<String, dynamic>>> _kosFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
    _kosFuture = KosService().fetchAll();
  }

  void _refreshKos() {
    setState(() {
      _kosFuture = KosService().fetchAll();
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showAddKosDialog() {
    final nameC = TextEditingController();
    final addressC = TextEditingController();
    final priceC = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Kost'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: 'Nama Kost'),
            ),
            TextField(
              controller: addressC,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: priceC,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              try {
                await KosService().add(
                  name: nameC.text,
                  address: addressC.text,
                  price: int.tryParse(priceC.text) ?? 0,
                );
                _refreshKos();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Kost ditambahkan')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Gagal: $e')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _securityTest(String kosId) async {
    final kos = KosService();
    final updated = await kos.update(kosId, {'name': 'DIUBAH OLEH USER LAIN'});
    debugPrint(updated
        ? '[FAIL] Berhasil mengubah data orang lain!'
        : '[PASS] UPDATE ditolak oleh RLS');

    final deleted = await kos.delete(kosId);
    debugPrint(deleted
        ? '[FAIL] Berhasil menghapus data orang lain!'
        : '[PASS] DELETE ditolak oleh RLS');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cek log debugPrint untuk hasil uji RLS')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, profileSnap) {
        if (profileSnap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final p = profileSnap.data;
        if (profileSnap.hasError || p == null) {
          return const Scaffold(
            body: Center(child: Text('Gagal memuat profil')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Kost Finder (${p.role})'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshKos,
              ),
              IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
            ],
          ),
          body: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(p.name.isEmpty ? p.email : p.name),
                subtitle: Text('${p.email} • ${p.role}'),
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _kosFuture,
                  builder: (context, kosSnap) {
                    if (kosSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (kosSnap.hasError) {
                      return Center(child: Text('Error: ${kosSnap.error}'));
                    }
                    final items = kosSnap.data ?? [];
                    if (items.isEmpty) {
                      return const Center(child: Text('Belum ada data kost.'));
                    }

                    final myId =
                        Supabase.instance.client.auth.currentUser!.id;

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final kos = items[i];
                        final isMine = kos['owner_id'] == myId;

                        return ListTile(
                          title: Text(kos['name'] ?? '-'),
                          subtitle: Text(
                            '${kos['address'] ?? '-'} • Rp ${kos['price'] ?? 0}',
                          ),
                          trailing: isMine || p.isAdmin
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Fitur edit belum diimplementasikan',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        final res = await KosService()
                                            .delete(kos['id']);
                                        if (!res) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Gagal menghapus (RLS menolak)',
                                              ),
                                            ),
                                          );
                                        } else {
                                          _refreshKos();
                                        }
                                      },
                                    ),
                                    if (!isMine)
                                      IconButton(
                                        icon: const Icon(Icons.security,
                                            color: Colors.red),
                                        tooltip: 'Uji RLS (Coba hack data ini)',
                                        onPressed: () =>
                                            _securityTest(kos['id']),
                                      ),
                                  ],
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: RoleGuard(
            role: p.role,
            allowed: const ['pemilik_kost', 'admin'],
            child: FloatingActionButton.extended(
              onPressed: _showAddKosDialog,
              icon: const Icon(Icons.add_home),
              label: const Text('Tambah Kost'),
            ),
          ),
        );
      },
    );
  }
}