import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CommandesScreen extends StatefulWidget {
  const CommandesScreen({Key? key}) : super(key: key);

  @override
  State<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  List<Map<String, dynamic>> _commandes = [];
  List<Map<String, dynamic>> _chantiers = [];
  List<Map<String, dynamic>> _chefs = [];

  String? _searchQuery;
  String? _editingCommandeId;
  String? selectedChantier;
  String? selectedChef;
  List<Map<String, dynamic>> lignes = [];

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    try {
      final commandesData = await supabase
          .from('commandes')
          .select('*, chantier:chantier_id(nom), chef:chef_equipe_id(nom)')
          .order('created_at', ascending: false);
      final chantiersData = await supabase.from('chantiers').select();
      final chefsData = await supabase.from('chefs_equipe').select();

      setState(() {
        _commandes = List<Map<String, dynamic>>.from(commandesData);
        _chantiers = List<Map<String, dynamic>>.from(chantiersData);
        _chefs = List<Map<String, dynamic>>.from(chefsData);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération : $e')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredCommandes {
    if (_searchQuery == null || _searchQuery!.isEmpty) return _commandes;
    final q = _searchQuery!.toLowerCase();
    return _commandes.where((c) {
      final chantierNom = c['chantier']?['nom']?.toString().toLowerCase() ?? '';
      final chefNom = c['chef']?['nom']?.toString().toLowerCase() ?? '';
      return chantierNom.contains(q) || chefNom.contains(q);
    }).toList();
  }

  void _deleteCommande(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la commande'),
        content: const Text('Voulez-vous vraiment supprimer cette commande ?'),
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
      await supabase.from('commandes').delete().eq('id', id);
      setState(() {
        _commandes.removeWhere((c) => c['id'] == id);
      });
    }
  }

  void _editCommande(Map<String, dynamic> commande) {
    setState(() {
      _editingCommandeId = commande['id'];
      selectedChantier = commande['chantier_id']?.toString();
      selectedChef = commande['chef_equipe_id']?.toString();
      lignes = List<Map<String, dynamic>>.from(commande['lignes'] ?? []);
    });
    _showCommandeDialog();
  }

  void _addCommande() {
    setState(() {
      _editingCommandeId = null;
      selectedChantier = null;
      selectedChef = null;
      lignes = [];
    });
    _showCommandeDialog();
  }

  Future<void> _showCommandeDialog() async {
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_editingCommandeId == null
            ? 'Nouvelle commande'
            : 'Modifier commande'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedChantier,
                    decoration: const InputDecoration(labelText: 'Chantier'),
                    items: _chantiers
                        .map((c) => DropdownMenuItem(
                              value: c['id'].toString(),
                              child: Text(c['nom']),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedChantier = v),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Chantier requis' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedChef,
                    decoration:
                        const InputDecoration(labelText: 'Chef d\'équipe'),
                    items: _chefs
                        .map((c) => DropdownMenuItem(
                              value: c['id'].toString(),
                              child: Text(c['nom']),
                            ))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedChef = v),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Chef requis' : null,
                  ),
                  const SizedBox(height: 12),
                  // Lignes produits à compléter ici (bouton + liste)
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      // TODO: Ajouter ligne produit
                    },
                    child: const Text('Ajouter une ligne de produit'),
                  ),
                  const SizedBox(height: 12),
                  if (lignes.isNotEmpty)
                    ...lignes.map((l) => ListTile(
                          title: Text('Produit: ${l['produit_nom'] ?? '-'}'),
                          subtitle: Text('Quantité: ${l['quantite']}'),
                        )),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text(_editingCommandeId == null ? 'Ajouter' : 'Modifier'),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              if (lignes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'La commande doit contenir au moins un produit.')),
                );
                return;
              }

              final payload = {
                'chantier_id': selectedChantier,
                'chef_equipe_id': selectedChef,
                'lignes': lignes
                    .map((l) => {
                          'produit_id': l['produit'],
                          'quantite': l['quantite'],
                        })
                    .toList(),
              };

              try {
                if (_editingCommandeId != null) {
                  await supabase
                      .from('commandes')
                      .update(payload)
                      .eq('id', _editingCommandeId!);
                  final index = _commandes
                      .indexWhere((c) => c['id'] == _editingCommandeId);
                  if (index != -1)
                    _commandes[index] = {..._commandes[index], ...payload};
                } else {
                  final inserted =
                      await supabase.from('commandes').insert(payload).select();
                  if (inserted.isNotEmpty) _commandes.add(inserted.first);
                }

                setState(() {
                  _editingCommandeId = null;
                  selectedChantier = null;
                  selectedChef = null;
                  lignes = [];
                });
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Erreur : $e')));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> c) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        title: Text(
          'Chantier: ${c['chantier']?['nom'] ?? '-'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Chef: ${c['chef']?['nom'] ?? '-'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editCommande(c)),
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCommande(c['id'])),
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
            hintText: 'Rechercher par chantier ou chef',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        backgroundColor: Colors.teal,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade400),
            onPressed: _addCommande,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _commandes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredCommandes.length,
              itemBuilder: (_, i) => _buildRow(filteredCommandes[i]),
            ),
    );
  }
}
