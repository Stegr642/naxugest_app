import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class FacturesScreen extends StatefulWidget {
  const FacturesScreen({super.key});

  @override
  State<FacturesScreen> createState() => _FacturesScreenState();
}

class _FacturesScreenState extends State<FacturesScreen> {
  late Future<List<Map<String, dynamic>>> _facturesFuture;
  List<Map<String, dynamic>> _factures = [];
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _facturesFuture = fetchFactures();
  }

  Future<List<Map<String, dynamic>>> fetchFactures() async {
    try {
      final data = await supabase
          .from('factures')
          .select('id, numero_facture, fournisseur, date_facture, total')
          .order('date_facture', ascending: false);
      _factures = List<Map<String, dynamic>>.from(data as List<dynamic>);
      return _factures;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des factures : $e');
    }
  }

  List<Map<String, dynamic>> get filteredFactures {
    if (_searchQuery.isEmpty) return _factures;
    return _factures.where((f) {
      final numero = f['numero_facture']?.toString().toLowerCase() ?? '';
      final fournisseur = f['fournisseur']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return numero.contains(query) || fournisseur.contains(query);
    }).toList();
  }

  void _deleteFacture(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la facture'),
        content: const Text('Voulez-vous vraiment supprimer cette facture ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await supabase.from('factures').delete().eq('id', id);
      setState(() {
        _factures.removeWhere((f) => f['id'] == id);
      });
    }
  }

  void _editFacture(Map<String, dynamic> facture) {
    showFactureForm(facture: facture);
  }

  void _addFacture() {
    showFactureForm();
  }

  Future<void> showFactureForm({Map<String, dynamic>? facture}) async {
    final formKey = GlobalKey<FormState>();
    String numero = facture?['numero_facture'] ?? '';
    String fournisseur = facture?['fournisseur'] ?? '';
    String total = facture?['total']?.toString() ?? '';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
            facture == null ? 'Ajouter une facture' : 'Modifier la facture'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: numero,
                decoration: const InputDecoration(labelText: 'Numéro facture'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Numéro requis' : null,
                onSaved: (value) => numero = value!,
              ),
              TextFormField(
                initialValue: fournisseur,
                decoration: const InputDecoration(labelText: 'Fournisseur'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Fournisseur requis'
                    : null,
                onSaved: (value) => fournisseur = value!,
              ),
              TextFormField(
                initialValue: total,
                decoration: const InputDecoration(labelText: 'Total'),
                keyboardType: TextInputType.number,
                onSaved: (value) => total = value ?? '0',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text(facture == null ? 'Ajouter' : 'Modifier'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final payload = {
                  'numero_facture': numero,
                  'fournisseur': fournisseur,
                  'total': double.tryParse(total) ?? 0,
                  'date_facture': DateTime.now().toIso8601String(),
                };
                if (facture == null) {
                  final inserted =
                      await supabase.from('factures').insert(payload).select();
                  setState(() => _factures.add(inserted.first));
                } else {
                  await supabase
                      .from('factures')
                      .update(payload)
                      .eq('id', facture['id']);
                  setState(() {
                    final index =
                        _factures.indexWhere((f) => f['id'] == facture['id']);
                    if (index != -1) {
                      _factures[index] = {...facture, ...payload};
                    }
                  });
                }
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildRow(Map<String, dynamic> f) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text('${f['numero_facture']} - ${f['fournisseur']}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Total: ${f['total'] ?? 0}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editFacture(f)),
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteFacture(f['id'])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factures'),
        backgroundColor: Colors.teal,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade400),
            onPressed: _addFacture,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _facturesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune facture trouvée.'));
          }
          final list = filteredFactures;
          return ListView.builder(
              itemCount: list.length, itemBuilder: (_, i) => buildRow(list[i]));
        },
      ),
    );
  }
}
