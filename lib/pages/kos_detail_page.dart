import 'package:flutter/material.dart';
import '../services/kos_service.dart';

class KosDetailPage extends StatefulWidget {
  final String kosId;

  const KosDetailPage({super.key, required this.kosId});

  @override
  State<KosDetailPage> createState() => _KosDetailPageState();
}

class _KosDetailPageState extends State<KosDetailPage> {
  late final Future<Map<String, dynamic>?> _kosFuture;

  @override
  void initState() {
    super.initState();
    _kosFuture = KosService().fetchById(widget.kosId);
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Rp -';
    final int p = int.tryParse(price.toString()) ?? 0;
    return 'Rp ${p.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kost')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _kosFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(child: Text('Data kost tidak ditemukan.'));
          }

          final kos = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_work, size: 80, color: Colors.indigo),
              ),
              const SizedBox(height: 24),
              Text(
                kos['name'] ?? '-',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kos['address'] ?? '-',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _formatPrice(kos['price']),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const Text('per bulan'),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur hubungi pemilik belum tersedia.')),
                  );
                },
                icon: const Icon(Icons.chat),
                label: const Text('Hubungi Pemilik'),
              ),
            ],
          );
        },
      ),
    );
  }
}