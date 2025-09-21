import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mouvement.dart';
import '../providers/mouvement_provider.dart';

class BlScreen extends ConsumerWidget {
  const BlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mouvements = ref.watch(mouvementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bons de livraison')),
      body: ListView.builder(
        itemCount: mouvements.length,
        itemBuilder: (context, index) {
          final m = mouvements[index];
          return ListTile(
            title: Text('Produit ID: ${m.productId}'),
            subtitle:
                Text('Chantier ID: ${m.chantierId} | Quantité: ${m.quantity}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddMouvementDialog(context, ref),
      ),
    );
  }

  void _showAddMouvementDialog(BuildContext context, WidgetRef ref) {
    final productController = TextEditingController();
    final chantierController = TextEditingController();
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajouter un mouvement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: productController,
                decoration: const InputDecoration(labelText: 'Produit ID')),
            TextField(
                controller: chantierController,
                decoration: const InputDecoration(labelText: 'Chantier ID')),
            TextField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final m = Mouvement(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                productId: productController.text,
                chantierId: chantierController.text,
                quantity: int.tryParse(qtyController.text) ?? 0,
                date: DateTime.now(),
              );
              ref.read(mouvementProvider.notifier).addMouvement(m);
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
