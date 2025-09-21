import 'package:flutter/material.dart';
import '../models/facture.dart';

class FactureCard extends StatelessWidget {
  final Facture facture;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FactureCard({
    super.key,
    required this.facture,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          facture.code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Fournisseur: ${facture.fournisseur}\nTotal: ${facture.total} MAD\nProduits: ${facture.produits.map((p) => p.name).join(', ')}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }
}
