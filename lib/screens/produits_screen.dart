import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ProduitsScreen extends StatefulWidget {
  const ProduitsScreen({Key? key}) : super(key: key);

  @override
  State<ProduitsScreen> createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends State<ProduitsScreen> {
  late Future<List<Map<String, dynamic>>> _produitsFuture;
  List<Map<String, dynamic>> _produits = [];
  String _searchQuery = '';

  final List<String> _defaultUnitOptions = ['m', 'm²', 'pièce', 'kg', 'litre'];
  late List<String> _unitOptions;

  @override
  void initState() {
    super.initState();
    _unitOptions = List.from(_defaultUnitOptions);
    _produitsFuture = fetchProduits();
  }

  Future<List<Map<String, dynamic>>> fetchProduits() async {
    try {
      final data = await supabase
          .from('produits')
          .select('nom, reference, unite, prix_unitaire, stock_minimum')
          .order('nom', ascending: true);

      _produits = List<Map<String, dynamic>>.from(data as List<dynamic>);

      // Ajouter toutes les unités existantes à _unitOptions
      for (var p in _produits) {
        final u = p['unite']?.toString();
        if (u != null && !_unitOptions.contains(u)) {
          _unitOptions.add(u);
        }
      }

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
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer')),
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
    final _formKey = GlobalKey<FormState>();
    String nom = produit?['nom'] ?? '';
    String reference = produit?['reference'] ?? '';
    String unite = produit?['unite'] ?? _unitOptions.first;
    String prixUnitaire = produit?['prix_unitaire']?.toString() ?? '';
    String stockMinimum = produit?['stock_minimum']?.toString() ?? '';

    if (!_unitOptions.contains(unite)) {
      _unitOptions.add(unite);
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
            produit == null ? 'Ajouter un produit' : 'Modifier le produit'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            child: Text(produit == null ? 'Ajouter' : 'Modifier'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final payload = {
                  'nom': nom,
                  'reference': reference.isEmpty ? null : reference,
                  'unite': unite,
                  'prix_unitaire': double.tryParse(prixUnitaire) ?? 0,
                  'stock_minimum': int.tryParse(stockMinimum) ?? 0,
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
                    if (index != -1)
                      _produits[index] = {...produit, ...payload};
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
    final stock = produit['stock_minimum'] ?? 0;
    Color rowColor;

    if (stock <= 0) {
      rowColor = Colors.red.shade100;
    } else if (stock <= 5) {
      rowColor = Colors.orange.shade100;
    } else {
      rowColor = Colors.white;
    }

    return Card(
      color: rowColor,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(produit['nom'].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Réf: ${produit['reference'] ?? '-'}'),
            Text('Unité: ${produit['unite'] ?? '-'}'),
            Text('Prix Unitaire: ${produit['prix_unitaire'] ?? '0'}'),
            Text('Stock Minimum: $stock'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addProduit),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _produitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun produit trouvé.'));
          }

          final isWide = MediaQuery.of(context).size.width >= 600;
          final produitsList = filteredProduits;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Rechercher par nom ou référence',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Expanded(
                child: isWide
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                              MaterialStateProperty.all(Colors.teal.shade100),
                          columns: const [
                            DataColumn(label: Text('Nom')),
                            DataColumn(label: Text('Référence')),
                            DataColumn(label: Text('Unité')),
                            DataColumn(label: Text('Prix Unitaire')),
                            DataColumn(label: Text('Stock Minimum')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: produitsList.map((p) {
                            final stock = p['stock_minimum'] ?? 0;
                            Color rowColor;
                            if (stock <= 0) {
                              rowColor = Colors.red.shade100;
                            } else if (stock <= 5) {
                              rowColor = Colors.orange.shade100;
                            } else {
                              rowColor = Colors.white;
                            }
                            return DataRow(
                              color: MaterialStateProperty.all(rowColor),
                              cells: [
                                DataCell(Text(p['nom'].toString())),
                                DataCell(
                                    Text(p['reference']?.toString() ?? '-')),
                                DataCell(Text(p['unite']?.toString() ?? '-')),
                                DataCell(Text(
                                    p['prix_unitaire']?.toString() ?? '0')),
                                DataCell(Text(stock.toString())),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => _editProduit(p),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteProduit(p['nom']),
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      )
                    : ListView.builder(
                        itemCount: produitsList.length,
                        itemBuilder: (_, index) =>
                            buildRow(produitsList[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
