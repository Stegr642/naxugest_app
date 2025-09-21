import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class FournisseursScreen extends StatefulWidget {
  const FournisseursScreen({super.key});

  @override
  State<FournisseursScreen> createState() => _FournisseursScreenState();
}

class _FournisseursScreenState extends State<FournisseursScreen> {
  late Future<List<Map<String, dynamic>>> _fournisseursFuture;
  List<Map<String, dynamic>> _fournisseurs = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fournisseursFuture = fetchFournisseurs();
  }

  Future<List<Map<String, dynamic>>> fetchFournisseurs() async {
    try {
      final data = await supabase
          .from('fournisseurs')
          .select()
          .order('nom', ascending: true);
      _fournisseurs = List<Map<String, dynamic>>.from(data as List<dynamic>);
      return _fournisseurs;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des fournisseurs : $e');
    }
  }

  List<Map<String, dynamic>> get filteredFournisseurs {
    if (_searchQuery.isEmpty) return _fournisseurs;
    final query = _searchQuery.toLowerCase();
    return _fournisseurs.where((f) {
      final nom = (f['nom'] ?? '').toString().toLowerCase();
      final contact = (f['contact'] ?? '').toString().toLowerCase();
      final email = (f['email'] ?? '').toString().toLowerCase();
      return nom.contains(query) ||
          contact.contains(query) ||
          email.contains(query);
    }).toList();
  }

  void _deleteFournisseur(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le fournisseur'),
        content: const Text('Voulez-vous vraiment supprimer ce fournisseur ?'),
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
      await supabase.from('fournisseurs').delete().eq('id', id);
      setState(() {
        _fournisseurs.removeWhere((f) => f['id'] == id);
      });
    }
  }

  void _editFournisseur(Map<String, dynamic> fournisseur) {
    showFournisseurForm(fournisseur: fournisseur);
  }

  void _addFournisseur() {
    showFournisseurForm();
  }

  Future<void> showFournisseurForm({Map<String, dynamic>? fournisseur}) async {
    final formKey = GlobalKey<FormState>();
    String nom = fournisseur?['nom']?.toString() ?? '';
    String contact = fournisseur?['contact']?.toString() ?? '';
    String email = fournisseur?['email']?.toString() ?? '';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(fournisseur == null
            ? 'Ajouter un fournisseur'
            : 'Modifier le fournisseur'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: nom,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nom requis' : null,
                onSaved: (value) => nom = value!,
              ),
              TextFormField(
                initialValue: contact,
                decoration: const InputDecoration(labelText: 'Contact'),
                onSaved: (value) => contact = value ?? '',
              ),
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) => email = value ?? '',
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
            child: Text(fournisseur == null ? 'Ajouter' : 'Modifier'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final payload = {
                  'nom': nom,
                  'contact': contact,
                  'email': email
                };

                if (fournisseur == null) {
                  final inserted = await supabase
                      .from('fournisseurs')
                      .insert(payload)
                      .select();
                  setState(() => _fournisseurs.add(inserted.first));
                } else {
                  await supabase
                      .from('fournisseurs')
                      .update(payload)
                      .eq('id', fournisseur['id']);
                  setState(() {
                    final index = _fournisseurs
                        .indexWhere((f) => f['id'] == fournisseur['id']);
                    if (index != -1) {
                      _fournisseurs[index] = {...fournisseur, ...payload};
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
        title: Text(f['nom'] ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Contact: ${f['contact'] ?? '-'}\nEmail: ${f['email'] ?? '-'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editFournisseur(f)),
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteFournisseur(f['id'])),
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
            hintText: 'Rechercher par nom, contact ou email',
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
            onPressed: _addFournisseur,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fournisseursFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun fournisseur trouvé.'));
          }
          final list = filteredFournisseurs;
          return ListView.builder(
              itemCount: list.length, itemBuilder: (_, i) => buildRow(list[i]));
        },
      ),
    );
  }
}
