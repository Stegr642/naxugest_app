import 'package:flutter/material.dart';
import '../models/fournisseur.dart';

class FournisseurCard extends StatelessWidget {
  final Fournisseur fournisseur;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FournisseurCard({
    super.key,
    required this.fournisseur,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          fournisseur.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Contact: ${fournisseur.contact}"),
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
