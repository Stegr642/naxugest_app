import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/depots_provider.dart';

class DepotsScreen extends ConsumerStatefulWidget {
  const DepotsScreen({super.key});

  @override
  ConsumerState<DepotsScreen> createState() => _DepotsScreenState();
}

class _DepotsScreenState extends ConsumerState<DepotsScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(depotsProvider.notifier).fetchAll();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addDepot() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    try {
      await ref.read(depotsProvider.notifier).add({'name': name});
      _nameController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’ajout: $e')),
      );
    }
  }

  Future<void> _deleteDepot(int id) async {
    try {
      await ref.read(depotsProvider.notifier).remove(id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final depots = ref.watch(depotsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dépôts')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nom du dépôt'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: _addDepot,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: depots.isEmpty
                  ? const Center(child: Text('Aucun dépôt'))
                  : ListView.builder(
                      itemCount: depots.length,
                      itemBuilder: (context, index) {
                        final depot = depots[index];
                        return ListTile(
                          title: Text(depot['name']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDepot(depot['id']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
