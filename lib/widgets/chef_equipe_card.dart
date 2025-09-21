import 'package:flutter/material.dart';
import '../models/chef.dart';

class ChefEquipeCard extends StatelessWidget {
  final ChefEquipe chef;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ChefEquipeCard({
    super.key,
    required this.chef,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          chef.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Chantiers: ${chef.chantiers.join(', ')}"),
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
