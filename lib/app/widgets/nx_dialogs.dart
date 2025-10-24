import 'package:flutter/material.dart';

Future<bool> showNxConfirmDelete({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Supprimer',
}) async {
  final scheme = Theme.of(context).colorScheme;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      title: Row(
        children: [
          Icon(Icons.delete_outline, color: scheme.error),
          const SizedBox(width: 8),
          Flexible(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}
