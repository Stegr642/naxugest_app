import 'package:flutter/material.dart';
import '../models/bl.dart';

class BlCard extends StatelessWidget {
  final BL bl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BlCard({
    super.key,
    required this.bl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          bl.code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Chantier: ${bl.chantier}\nProduits: ${bl.produits.map((p) => p.name).join(', ')}",
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
