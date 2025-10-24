import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../features/produits/presentation/pages/f_list_produits.dart';
import '../features/produits/presentation/pages/f_edit_produit.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/produits',
  routes: <GoRoute>[
    GoRoute(
      path: '/produits',
      name: 'produits_list',
      builder: (BuildContext context, GoRouterState state) =>
          const F_ListProduits(),
    ),
    GoRoute(
      path: '/produits/new',
      name: 'produit_new',
      builder: (context, state) => const F_EditProduit(),
    ),
    GoRoute(
      path: '/produits/:id/edit',
      name: 'produit_edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return F_EditProduit(idProduit: id);
      },
    ),
  ],
);
