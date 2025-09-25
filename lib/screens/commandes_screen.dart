import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CommandesScreen extends StatefulWidget {
  const CommandesScreen({super.key});

  @override
  State<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _produits = [];

  @override
  void initState() {
    super.initState();
    fetchProduits();
  }

  Future<void> fetchProduits() async {
    final data = await supabase.from('produits').select('*').order('nom');
    setState(() {
      _produits = List<Map<String, dynamic>>.from(data as List);
    });
  }

  Future<void> _showCommandeDialog(BuildContext context) async {
    String? selectedChantier;
    String? selectedChef;

    List<Map<String, dynamic>> produitsDisponibles = List.from(_produits);
    List<Map<String, dynamic>> produitsSelectionnes = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.8,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade700, Colors.teal.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Nouvelle Commande',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Produits Disponibles",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: produitsDisponibles.length,
                                      itemBuilder: (context, index) {
                                        final produit =
                                            produitsDisponibles[index];
                                        return GestureDetector(
                                          onDoubleTap: () {
                                            setState(() {
                                              if (!produitsSelectionnes.any(
                                                  (p) =>
                                                      p['id'] ==
                                                      produit['id'])) {
                                                produitsSelectionnes.add({
                                                  ...produit,
                                                  'quantite': 1,
                                                });
                                              }
                                            });
                                          },
                                          child: ListTile(
                                            title: Text(produit['nom']),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[200],
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Produits Sélectionnés",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: produitsSelectionnes.length,
                                      itemBuilder: (context, index) {
                                        final produit =
                                            produitsSelectionnes[index];
                                        return GestureDetector(
                                          onDoubleTap: () {
                                            setState(() {
                                              produitsSelectionnes
                                                  .removeAt(index);
                                            });
                                          },
                                          child: ListTile(
                                            title: Text(produit['nom']),
                                            subtitle: Row(
                                              children: [
                                                const Text("Quantité: "),
                                                SizedBox(
                                                  width: 60,
                                                  child: TextFormField(
                                                    initialValue:
                                                        produit['quantite']
                                                            .toString(),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        produit['quantite'] =
                                                            int.tryParse(val) ??
                                                                1;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Annuler'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          child: const Text('Valider'),
                          onPressed: () {
                            // TODO: sauvegarder la commande
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une commande',
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
          child: Center(
            child: Text(
              'Liste des commandes ici (à implémenter)',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showCommandeDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle Commande'),
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
