import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommandesScreen extends StatefulWidget {
  const CommandesScreen({super.key});

  @override
  State<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _commandesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _commandesFuture = _fetchCommandes();
  }

  Future<List<Map<String, dynamic>>> _fetchCommandes() async {
    final response = await supabase
        .from('commandes')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => e as Map<String, dynamic>).toList();
  }

  void _refresh() {
    setState(() {
      _commandesFuture = _fetchCommandes();
    });
  }

  void _addCommande() {
    _showCommandeDialog();
  }

  void _editCommande(Map<String, dynamic> commande) {
    _showCommandeDialog(commande: commande);
  }

  Future<void> _deleteCommande(String id) async {
    await supabase.from('commandes').delete().eq('id', id);
    _refresh();
  }

  Future<void> _showCommandeDialog({Map<String, dynamic>? commande}) async {
    final TextEditingController descriptionController =
        TextEditingController(text: commande?['description'] ?? '');
    final TextEditingController chantierController =
        TextEditingController(text: commande?['chantier'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            Text(commande == null ? 'Nouvelle Commande' : 'Modifier Commande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: chantierController,
              decoration: const InputDecoration(
                labelText: 'Chantier',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text(commande == null ? 'Ajouter' : 'Mettre à jour'),
            onPressed: () async {
              if (commande == null) {
                await supabase.from('commandes').insert({
                  'description': descriptionController.text,
                  'chantier': chantierController.text,
                });
              } else {
                await supabase.from('commandes').update({
                  'description': descriptionController.text,
                  'chantier': chantierController.text,
                }).eq('id', commande['id']);
              }
              if (context.mounted) Navigator.pop(context);
              _refresh();
            },
          ),
        ],
      ),
    );
  }

  Widget buildRow(Map<String, dynamic> commande) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        title: Text(
          commande['description'] ?? 'Commande',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Chantier : ${commande['chantier'] ?? '-'}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editCommande(commande),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCommande(commande['id']),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header moderne
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.tealAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Commandes',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _addCommande,
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvelle'),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Rechercher une commande...',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // Liste
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _commandesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune commande trouvée.'));
                }

                final commandesList = snapshot.data!
                    .where((c) =>
                        c['description']
                            ?.toString()
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ??
                        false)
                    .toList();

                if (isWide) {
                  // Vue DataTable Desktop
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(Colors.teal.shade200),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      columns: const [
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Chantier')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: commandesList.map((c) {
                        return DataRow(
                          cells: [
                            DataCell(Text(c['description'] ?? '')),
                            DataCell(Text(c['chantier'] ?? '-')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _editCommande(c),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteCommande(c['id']),
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  // Vue Mobile ListView
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: commandesList.length,
                    itemBuilder: (_, index) => buildRow(commandesList[index]),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
