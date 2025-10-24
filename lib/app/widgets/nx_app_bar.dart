import 'package:flutter/material.dart';

AppBar buildNxAppBar(
  BuildContext context, {
  required String title,
  String? subtitle,
  List<Widget>? actions,
}) {
  final scheme = Theme.of(context).colorScheme;

  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: scheme.surface,
    centerTitle: false,
    toolbarHeight: 72,
    leadingWidth: 56,
    leading: Padding(
      padding: const EdgeInsets.only(left: 12),
      child: CircleAvatar(
        backgroundColor: scheme.primary,
        child: Text(
          'NAXU',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w800),
        ),
      ),
    ),
    titleSpacing: 8,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
      ],
    ),
    actions: [
      ...(actions ?? const []),
      const SizedBox(width: 6),
    ],
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surface,
            // Si votre SDK n’a pas surfaceContainerHighest, remplacez par surfaceVariant
            scheme.surfaceContainerHighest.withOpacity(0.25),
          ],
        ),
      ),
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, thickness: 1),
    ),
  );
}
