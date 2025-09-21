import 'package:flutter/material.dart';
import '../models/chantier.dart';

class ChantierCard extends StatelessWidget {
  final Chantier chantier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ChantierCard({
    super.key,
    required this.chantier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          chantier.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Chef: ${chantier.chefEquipe}\nAdresse: ${chantier.adresse}",
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
