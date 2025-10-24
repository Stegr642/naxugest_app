# NaxuGest UI – Maquette Flutter (MVP)

Cette maquette contient les écrans principaux (mobile & web) pour : Stocks, Mouvements, Transferts, Inventaires, Alertes, Marchés/Chantiers, Documents et Factures.

## Démarrage rapide
1. Crée un nouveau projet Flutter :
   ```bash
   flutter create naxugest
   ```
2. Remplace le dossier `lib/` par celui de cette archive.
3. Lance :
   ```bash
   flutter run -d chrome
   ```
   ou
   ```bash
   flutter run
   ```

## À brancher ensuite
- Auth Supabase (email/OTP)
- Rôles (admin, direction, compta, magasinier) → masquer dans `AppDrawer` (déjà prévu)
- Appels aux vues SQL (`documents_v`, `factures_v`) et tables (mouvements, stocks…)
- Génération de PDF (factures, inventaires) via `printing`.

## Notes UI
- Material 3, responsive, listes paginées
- Champs et filtres prêts, validations de base incluses
