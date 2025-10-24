import 'package:flutter/material.dart';

class ModernHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? chipText;
  final List<Widget>? actions;

  const ModernHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.chipText,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    // Couleur de texte calculée pour bon contraste sur le dégradé
    final base = Color.lerp(c.primary, c.secondary, 0.5)!;
    final onGrad = ThemeData.estimateBrightnessForColor(base) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.primary, c.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: DefaultTextStyle(
        style: (t.bodyMedium ?? const TextStyle()).copyWith(color: onGrad),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            // Bloc gauche (icône + titre + sous-titre + chip)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: onGrad.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: onGrad.withOpacity(0.15)),
                    ),
                    child: Icon(icon, color: onGrad, size: 24),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: (t.titleLarge ?? const TextStyle(fontSize: 22))
                          .copyWith(
                        fontWeight: FontWeight.w800,
                        color: onGrad,
                        letterSpacing: .2,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: (t.bodyMedium ?? const TextStyle()).copyWith(
                            color: onGrad.withOpacity(0.9),
                          ),
                        ),
                      ),
                  ],
                ),
                if (chipText != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: onGrad.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: onGrad.withOpacity(0.18)),
                    ),
                    child: Text(
                      chipText!,
                      style: (t.labelLarge ?? const TextStyle(fontSize: 13))
                          .copyWith(
                        color: onGrad,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),

            // Actions à droite (wrap responsive)
            if (actions != null && actions!.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions!,
              ),
          ],
        ),
      ),
    );
  }
}
