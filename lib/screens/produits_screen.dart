import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ProduitsScreen extends StatefulWidget {
  const ProduitsScreen({super.key});

  @override
  State<ProduitsScreen> createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends State<ProduitsScreen> {
  late Future<List<Map<String, dynamic>>> _produitsFuture;
  List<Map<String, dynamic>> _produits = [];
  String _searchQuery = '';

  final List<String> _unitOptions = ['U', 'ml', 'Jeu', 'm²', 'm3', 'kg', 'TO'];

  @override
  void initState() {
    super.initState();
    _produitsFuture = fetchProduits();
  }

  Future<List<Map<String, dynamic>>> fetchProduits() async {
    try {
      final data = await supabase
          .from('produits')
          .select(
              'nom, reference, unite, prix_unitaire, stock_minimum, stock_disponible')
          .order('nom', ascending: true);

      _produits = List<Map<String, dynamic>>.from(data as List<dynamic>);
      return _produits;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits : $e');
    }
  }

  List<Map<String, dynamic>> get filteredProduits {
    if (_searchQuery.isEmpty) return _produits;
    return _produits.where((p) {
      final nom = p['nom']?.toString().toLowerCase() ?? '';
      final reference = p['reference']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return nom.contains(query) || reference.contains(query);
    }).toList();
  }

  void _deleteProduit(String nom) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Voulez-vous vraiment supprimer "$nom" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await supabase.from('produits').delete().eq('nom', nom);
      setState(() {
        _produits.removeWhere((p) => p['nom'] == nom);
      });
    }
  }

  void _editProduit(Map<String, dynamic> produit) {
    showProduitForm(produit: produit);
  }

  void _addProduit() {
    showProduitForm();
  }

  Future<void> showProduitForm({Map<String, dynamic>? produit}) async {
    final formKey = GlobalKey<FormState>();
    String nom = produit?['nom'] ?? '';
    String reference = produit?['reference'] ?? '';
    String unite = produit?['unite'] ?? _unitOptions.first;
    String prixUnitaire = produit?['prix_unitaire']?.toString() ?? '';
    String stockMinimum = produit?['stock_minimum']?.toString() ?? '';
    String stockDisponible = produit?['stock_disponible']?.toString() ?? '0';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
            produit == null ? 'Ajouter un produit' : 'Modifier le produit'),
        content: SingleChildScrollView(
          child: Form(
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
                  initialValue: reference,
                  decoration: const InputDecoration(labelText: 'Référence'),
                  onSaved: (value) => reference = value ?? '',
                ),
                DropdownButtonFormField<String>(
                  value:
                      _unitOptions.contains(unite) ? unite : _unitOptions.first,
                  decoration: const InputDecoration(labelText: 'Unité'),
                  items: _unitOptions
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) => unite = value ?? _unitOptions.first,
                  onSaved: (value) => unite = value ?? _unitOptions.first,
                ),
                TextFormField(
                  initialValue: prixUnitaire,
                  decoration: const InputDecoration(labelText: 'Prix Unitaire'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => prixUnitaire = value ?? '0',
                ),
                TextFormField(
                  initialValue: stockMinimum,
                  decoration: const InputDecoration(labelText: 'Stock Minimum'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => stockMinimum = value ?? '0',
                ),
                TextFormField(
                  initialValue: stockDisponible,
                  decoration:
                      const InputDecoration(labelText: 'Stock Disponible'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => stockDisponible = value ?? '0',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(produit == null ? 'Ajouter' : 'Modifier'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                final payload = {
                  'nom': nom,
                  'reference': reference.isEmpty ? null : reference,
                  'unite': unite,
                  'prix_unitaire': double.tryParse(prixUnitaire) ?? 0,
                  'stock_minimum': int.tryParse(stockMinimum) ?? 0,
                  'stock_disponible': int.tryParse(stockDisponible) ?? 0,
                };

                if (produit == null) {
                  final inserted =
                      await supabase.from('produits').insert(payload).select();
                  setState(() {
                    _produits.add(inserted.first);
                  });
                } else {
                  await supabase
                      .from('produits')
                      .update(payload)
                      .eq('nom', produit['nom']);
                  setState(() {
                    final index =
                        _produits.indexWhere((p) => p['nom'] == produit['nom']);
                    if (index != -1) {
                      _produits[index] = {...produit, ...payload};
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

  Widget buildRow(Map<String, dynamic> produit) {
    final stockDispo = produit['stock_disponible'] ?? 0;
    final stockMin = produit['stock_minimum'] ?? 0;

    Color rowColor;
    bool isLowStock = false;

    if (stockDispo <= 0) {
      rowColor = Colors.red.shade100;
      isLowStock = true;
    } else if (stockDispo <= stockMin) {
      rowColor = Colors.orange.shade100;
      isLowStock = true;
    } else {
      rowColor = Colors.white;
    }

    return Card(
      color: rowColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(produit['nom'].toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            if (isLowStock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Stock faible',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Réf: ${produit['reference'] ?? '-'}'),
            Text('Unité: ${produit['unite'] ?? '-'}'),
            Text('Prix Unitaire: ${produit['prix_unitaire'] ?? '0'}'),
            Text('Stock Disponible: $stockDispo'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editProduit(produit),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProduit(produit['nom']),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou référence',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _produitsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Aucun produit trouvé.'));
              }

              final produitsList = filteredProduits;

              if (isWide) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        MaterialStateProperty.all(Colors.teal.shade100),
                    columns: const [
                      DataColumn(label: Text('Nom')),
                      DataColumn(label: Text('Référence')),
                      DataColumn(label: Text('Unité')),
                      DataColumn(label: Text('Prix Unitaire')),
                      DataColumn(label: Text('Stock Disponible')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: produitsList.map((p) {
                      final stockDispo = p['stock_disponible'] ?? 0;
                      final stockMin = p['stock_minimum'] ?? 0;
                      Color rowColor;
                      if (stockDispo <= 0) {
                        rowColor = Colors.red.shade100;
                      } else if (stockDispo <= stockMin) {
                        rowColor = Colors.orange.shade100;
                      } else {
                        rowColor = Colors.white;
                      }
                      return DataRow(
                        color: MaterialStateProperty.all(rowColor),
                        cells: [
                          DataCell(Text(p['nom'].toString())),
                          DataCell(Text(p['reference']?.toString() ?? '-')),
                          DataCell(Text(p['unite']?.toString() ?? '-')),
                          DataCell(Text(p['prix_unitaire']?.toString() ?? '0')),
                          DataCell(Text(stockDispo.toString())),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editProduit(p),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProduit(p['nom']),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: produitsList.length,
                  itemBuilder: (_, index) => buildRow(produitsList[index]),
                );
              }
            },
          ),
        ),
        ElevatedButton.icon(
          onPressed: _addProduit,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter Produit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
