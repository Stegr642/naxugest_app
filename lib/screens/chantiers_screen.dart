import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ChantiersScreen extends StatefulWidget {
  const ChantiersScreen({super.key});

  @override
  State<ChantiersScreen> createState() => _ChantiersScreenState();
}

class _ChantiersScreenState extends State<ChantiersScreen> {
  late Future<List<Map<String, dynamic>>> _chantiersFuture;
  List<Map<String, dynamic>> _chantiers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _chantiersFuture = fetchChantiers();
  }

  Future<List<Map<String, dynamic>>> fetchChantiers() async {
    try {
      final data = await supabase
          .from('chantiers')
          .select()
          .order('nom', ascending: true);
      _chantiers = List<Map<String, dynamic>>.from(data as List<dynamic>);
      return _chantiers;
    } catch (e) {
      throw Exception("Erreur lors de la récupération des chantiers : $e");
    }
  }

  List<Map<String, dynamic>> get filteredChantiers {
    if (_searchQuery.isEmpty) return _chantiers;
    return _chantiers.where((c) {
      final nom = c['nom']?.toString().toLowerCase() ?? '';
      return nom.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _deleteChantier(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le chantier'),
        content: const Text('Voulez-vous vraiment supprimer ce chantier ?'),
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
      await supabase.from('chantiers').delete().eq('id', id);
      setState(() {
        _chantiers.removeWhere((c) => c['id'] == id);
      });
    }
  }

  void _editChantier(Map<String, dynamic> chantier) {
    showChantierForm(chantier: chantier);
  }

  void _addChantier() {
    showChantierForm();
  }

  Future<void> showChantierForm({Map<String, dynamic>? chantier}) async {
    final formKey = GlobalKey<FormState>();
    String name = chantier?['nom'] ?? '';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
            chantier == null ? 'Ajouter un chantier' : 'Modifier le chantier'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: name,
            decoration: const InputDecoration(labelText: 'Nom du chantier'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Nom requis' : null,
            onSaved: (value) => name = value!,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text(chantier == null ? 'Ajouter' : 'Modifier'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final payload = {'nom': name};

                if (chantier == null) {
                  final inserted =
                      await supabase.from('chantiers').insert(payload).select();
                  setState(() => _chantiers.add(inserted.first));
                } else {
                  await supabase
                      .from('chantiers')
                      .update(payload)
                      .eq('id', chantier['id']);
                  setState(() {
                    final index =
                        _chantiers.indexWhere((c) => c['id'] == chantier['id']);
                    if (index != -1) {
                      _chantiers[index] = {...chantier, ...payload};
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

  Widget buildRow(Map<String, dynamic> c) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(c['nom'] ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("ID: ${c['id']}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editChantier(c)),
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteChantier(c['id'])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Rechercher un chantier',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        backgroundColor: Colors.teal,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade400),
            onPressed: _addChantier,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chantiersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun chantier trouvé.'));
          }
          final list = filteredChantiers;
          return ListView.builder(
              itemCount: list.length, itemBuilder: (_, i) => buildRow(list[i]));
        },
      ),
    );
  }
}
