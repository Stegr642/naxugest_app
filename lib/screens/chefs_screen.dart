import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ChefsScreen extends StatefulWidget {
  const ChefsScreen({super.key});

  @override
  State<ChefsScreen> createState() => _ChefsScreenState();
}

class _ChefsScreenState extends State<ChefsScreen> {
  late Future<List<Map<String, dynamic>>> _chefsFuture;
  List<Map<String, dynamic>> _chefs = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _chefsFuture = fetchChefs();
  }

  Future<List<Map<String, dynamic>>> fetchChefs() async {
    try {
      final data = await supabase
          .from('chefs_equipe')
          .select()
          .order('nom', ascending: true);
      _chefs = List<Map<String, dynamic>>.from(data as List<dynamic>);
      return _chefs;
    } catch (e) {
      throw Exception("Erreur lors de la récupération des chefs d'équipe : $e");
    }
  }

  List<Map<String, dynamic>> get filteredChefs {
    if (_searchQuery.isEmpty) return _chefs;
    return _chefs.where((c) {
      final nom = c['nom']?.toString().toLowerCase() ?? '';
      return nom.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _deleteChef(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le chef'),
        content:
            const Text('Voulez-vous vraiment supprimer ce chef d\'équipe ?'),
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
      await supabase.from('chefs_equipe').delete().eq('id', id);
      setState(() {
        _chefs.removeWhere((c) => c['id'] == id);
      });
    }
  }

  void _editChef(Map<String, dynamic> chef) {
    showChefForm(chef: chef);
  }

  void _addChef() {
    showChefForm();
  }

  Future<void> showChefForm({Map<String, dynamic>? chef}) async {
    final formKey = GlobalKey<FormState>();
    String name = chef?['nom'] ?? '';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(chef == null ? 'Ajouter un chef' : 'Modifier le chef'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: name,
            decoration: const InputDecoration(labelText: 'Nom du chef'),
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
            child: Text(chef == null ? 'Ajouter' : 'Modifier'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final payload = {'nom': name};

                if (chef == null) {
                  final inserted = await supabase
                      .from('chefs_equipe')
                      .insert(payload)
                      .select();
                  setState(() => _chefs.add(inserted.first));
                } else {
                  await supabase
                      .from('chefs_equipe')
                      .update(payload)
                      .eq('id', chef['id']);
                  setState(() {
                    final index =
                        _chefs.indexWhere((c) => c['id'] == chef['id']);
                    if (index != -1) _chefs[index] = {...chef, ...payload};
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
                onPressed: () => _editChef(c)),
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteChef(c['id'])),
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
            hintText: 'Rechercher un chef d\'équipe',
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
            onPressed: _addChef,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chefsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun chef trouvé.'));
          }
          final list = filteredChefs;
          return ListView.builder(
              itemCount: list.length, itemBuilder: (_, i) => buildRow(list[i]));
        },
      ),
    );
  }
}
