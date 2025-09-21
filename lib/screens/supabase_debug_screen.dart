import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDebugScreen extends StatefulWidget {
  const SupabaseDebugScreen({super.key});

  @override
  State<SupabaseDebugScreen> createState() => _SupabaseDebugScreenState();
}

class _SupabaseDebugScreenState extends State<SupabaseDebugScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  String _status = "⚡ Aucun test effectué";
  List<Map<String, dynamic>> _data = [];

  // 👉 liste des tables Supabase à tester
  final List<String> _tables = [
    "produits",
    "commandes",
    "factures",
    "fournisseurs",
    "chantiers",
    "chefs"
  ];

  Future<void> _testConnexion() async {
    try {
      final response = await _client.from('produits').select().limit(1);
      setState(() {
        _status = "✅ Connexion OK (table produits)";
        _data = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      setState(() {
        _status = "❌ Erreur de connexion: $e";
        _data = [];
      });
    }
  }

  Future<void> _dumpTable(String tableName) async {
    try {
      final response = await _client.from(tableName).select().limit(20);
      setState(() {
        _status = "📦 Table: $tableName (${response.length} lignes)";
        _data = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      setState(() {
        _status = "❌ Erreur sur $tableName: $e";
        _data = [];
      });
    }
  }

  Widget _buildTable() {
    if (_data.isEmpty) {
      return const Text("⚠️ Aucun résultat");
    }

    final columns = _data.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
        rows: _data.map((row) {
          return DataRow(
            cells: columns.map((c) {
              final value = row[c];
              return DataCell(Text(value?.toString() ?? ""));
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔍 Supabase Debug")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _testConnexion,
              child: const Text("⚡ Tester connexion (produits)"),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    "Tables disponibles :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tables.map((t) {
                      return ElevatedButton(
                        onPressed: () => _dumpTable(t),
                        child: Text("📦 $t"),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _status,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 400,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: _buildTable(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
