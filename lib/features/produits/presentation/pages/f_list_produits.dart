import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/supabase_client.dart';

class Produit {
  final int idProduit;
  final String codeProduit;
  final String? designation;
  final num? qteStock;
  final num? qteMin;
  final num? prixUnitaire;
  final int? idUnite;
  final String? libUnite;
  final int? idCategorie;
  final String? libCategorie;

  Produit({
    required this.idProduit,
    required this.codeProduit,
    this.designation,
    this.qteStock,
    this.qteMin,
    this.prixUnitaire,
    this.idUnite,
    this.libUnite,
    this.idCategorie,
    this.libCategorie,
  });

  factory Produit.fromJson(Map<String, dynamic> m) => Produit(
        idProduit: m['id_produit'] as int,
        codeProduit: m['code_produit'] as String,
        designation: m['designation'] as String?,
        qteStock: m['qte_stock'] as num?,
        qteMin: m['qte_min'] as num?,
        prixUnitaire: m['prix_unitaire'] as num?,
        idUnite: m['id_unite'] as int?,
        libUnite: m['lib_unite'] as String?,
        idCategorie: m['id_categorie'] as int?,
        libCategorie: m['lib_categorie'] as String?,
      );
}

class F_ListProduits extends StatefulWidget {
  const F_ListProduits({super.key});

  @override
  State<F_ListProduits> createState() => _F_ListProduitsState();
}

class _F_ListProduitsState extends State<F_ListProduits> {
  late Future<List<Produit>> _future;
  final _fmtMAD = NumberFormat.currency(locale: 'fr_MA', symbol: 'DH');

  // Recherche
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;
  String _query = '';

  // Filtre alerte (serveur)
  bool _alertOnly = false;

  // Pagination
  int _page = 0;
  // final int _pageSize = 20;
  // final int _pageSize = 50;
  int _pageSize = 50;
  bool _hasMore = false;

  // Scroll horizontal synchronisé
  final ScrollController _hScroll = ScrollController();

  // Largeurs
  static const double _wCode = 140;
  static const double _wDesignation = 320;
  static const double _wUnite = 120;
  static const double _wCategorie = 180;
  static const double _wQte = 110; // Qté Stock
  static const double _wPrix = 120; // Prix U.
  static const double _wActions = 120;

  // Couleur d’alerte (palette #F28F38)
  static const Color _alertBase = Color(0xFFF28F38);

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _hScroll.dispose();
    super.dispose();
  }

  String _sanitizeForIlike(String s) {
    return s.replaceAll('%', r'\%').replaceAll('_', r'\_');
  }

  // Header compact
  Widget _th(String s) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis),
      );

  DataColumn _col(String label, double w, {TextAlign align = TextAlign.left}) {
    return DataColumn(
      label: SizedBox(
        width: w,
        child: Align(
          alignment: align == TextAlign.right
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: _th(label),
        ),
      ),
    );
  }

  Widget _cellText(String? t, double w, {TextAlign align = TextAlign.left}) {
    return SizedBox(
      width: w,
      child: Text(
        t ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
      ),
    );
  }

  MaterialStateProperty<Color?>? _rowAlertColor(bool isAlert) {
    if (!isAlert) return null;
    return MaterialStateProperty.resolveWith<Color?>((states) {
      final hovered = states.contains(MaterialState.hovered) ||
          states.contains(MaterialState.focused);
      return _alertBase.withOpacity(hovered ? 0.26 : 0.18);
    });
  }

  Future<List<Produit>> _load() async {
    final from = _page * _pageSize;
    final to = from + _pageSize - 1;

    var fb = supa.from('v_produits_alert').select();

    final q = _query.trim();
    if (q.isNotEmpty) {
      final like = _sanitizeForIlike(q.toLowerCase());
      fb = fb.filter('search_concat', 'ilike', '%$like%');
    }

    // filtre serveur
    if (_alertOnly) {
      fb = fb.eq('is_alert', true);
    }

    final tb = fb.order('id_produit', ascending: true);

    final dynamic res = await tb.range(from, to);
    final list = (res as List).cast<Map<String, dynamic>>();
    if (mounted) {
      setState(() {
        _hasMore = list.length == _pageSize;
      });
    }
    return list.map((e) => Produit.fromJson(e)).toList();
  }

  Future<void> _reload() async {
    final fut = _load();
    setState(() {
      _future = fut;
    });
    await fut;
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _page = 0;
      _query = v;
      _reload();
      if (mounted && !_searchFocus.hasFocus) _searchFocus.requestFocus();
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _page = 0;
    _query = '';
    _reload();
    _searchFocus.requestFocus();
  }

  void _toggleAlertOnly(bool? v) {
    setState(() {
      _alertOnly = v ?? false;
      _page = 0;
    });
    _reload();
    _searchFocus.requestFocus();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmDelete(Produit p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce produit ?'),
        content: Text(
            '« ${p.designation ?? p.codeProduit} » sera supprimé définitivement.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await supa
            .rpc('produits_delete', params: {'p_id_produit': p.idProduit});
        _showSnack('Supprimé.');
        await _reload();
        if (mounted) _searchFocus.requestFocus();
      } on PostgrestException catch (e) {
        _showSnack('Erreur suppression: ${e.message}');
      } catch (e) {
        _showSnack('Erreur: $e');
      }
    }
  }

  void _onMenu(String key) {
    if (key == 'help') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Aide rapide'),
          content: const Text(
            '• Clic sur une ligne: éditer le produit\n'
            '• Rechercher par désignation/catégorie\n'
            '• Filtrer les alertes via la case à cocher\n'
            '• Supprimer via l’icône Actions',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
          ],
        ),
      );
    } else if (key == 'about') {
      showAboutDialog(
        context: context,
        applicationName: 'NaxuGest',
        applicationVersion: 'v0.1',
        applicationLegalese: '© NAXU SARL AU',
      );
    }
  }

  // ---- Widget: case à cocher homogène (40px) ----
  Widget _alertCheckbox(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.labelLarge;
    final hintStyle = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(color: scheme.onSurfaceVariant);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _toggleAlertOnly(!_alertOnly),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: _alertOnly,
              onChanged: _toggleAlertOnly,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.warning_amber_rounded, size: 18),
            const SizedBox(width: 6),
            Text('Alerte produit(s)', style: titleStyle),
            const SizedBox(width: 8),
            Text('(Qté Stock < Qté Min)', style: hintStyle),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
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
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimary, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        titleSpacing: 8,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NaxuGest — Produits',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text('Gestion des articles & stocks',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Menu',
            onSelected: _onMenu,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'help',
                child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Aide rapide')),
              ),
              PopupMenuItem(
                value: 'about',
                child: ListTile(
                    leading: Icon(Icons.info_outline), title: Text('À propos')),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.surface,
                scheme.surfaceContainerHighest.withOpacity(0.25)
              ],
            ),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Recherche + filtre + bouton (styles homogènes)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 360,
                      child: TextField(
                        focusNode: _searchFocus,
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Rechercher (désignation ou catégorie)',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Effacer',
                                  onPressed: _clearSearch,
                                  icon: const Icon(Icons.close),
                                ),
                        ),
                      ),
                    ),
                    _alertCheckbox(context),
                    SizedBox(
                      height: 40,
                      child: FilledButton.icon(
                        onPressed: () => context.go('/produits/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Nouveau produit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Header figé
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: _hScroll,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth + 12),
                        child: DataTable(
                          columnSpacing: 12,
                          horizontalMargin: 6,
                          showCheckboxColumn: false,
                          columns: [
                            _col('Code', _wCode),
                            _col('Désignation', _wDesignation),
                            _col('Unité', _wUnite),
                            _col('Catégorie', _wCategorie),
                            _col('Qté Stock', _wQte, align: TextAlign.right),
                            _col('Prix U.', _wPrix, align: TextAlign.right),
                            _col('Actions', _wActions),
                          ],
                          rows: const [],
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),

                // Body
                const SizedBox(height: 4),
                Expanded(
                  child: FutureBuilder<List<Produit>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(child: Text('Erreur: ${snap.error}'));
                      }
                      final items = snap.data ?? const [];

                      if (items.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 160),
                            Center(child: Text('Aucun produit.')),
                          ],
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _reload,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SingleChildScrollView(
                                controller: _hScroll,
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth + 12),
                                  child: ClipRect(
                                    child: DataTable(
                                      headingRowHeight: 0,
                                      columnSpacing: 12,
                                      horizontalMargin: 6,
                                      showCheckboxColumn: false,
                                      columns: [
                                        _col('Code', _wCode),
                                        _col('Désignation', _wDesignation),
                                        _col('Unité', _wUnite),
                                        _col('Catégorie', _wCategorie),
                                        _col('Qté Stock', _wQte,
                                            align: TextAlign.right),
                                        _col('Prix U.', _wPrix,
                                            align: TextAlign.right),
                                        _col('Actions', _wActions),
                                      ],
                                      rows: items.map((p) {
                                        final bool isAlert =
                                            (p.qteStock ?? 0) < (p.qteMin ?? 0);
                                        return DataRow(
                                          color: _rowAlertColor(isAlert),
                                          onSelectChanged: (_) => context.go(
                                              '/produits/${p.idProduit}/edit'),
                                          cells: [
                                            DataCell(_cellText(
                                                p.codeProduit, _wCode)),
                                            DataCell(_cellText(
                                                p.designation, _wDesignation)),
                                            DataCell(
                                                _cellText(p.libUnite, _wUnite)),
                                            DataCell(_cellText(
                                                p.libCategorie, _wCategorie)),
                                            DataCell(_cellText(
                                              p.qteStock?.toString(),
                                              _wQte,
                                              align: TextAlign.right,
                                            )),
                                            DataCell(_cellText(
                                              p.prixUnitaire == null
                                                  ? ''
                                                  : _fmtMAD
                                                      .format(p.prixUnitaire),
                                              _wPrix,
                                              align: TextAlign.right,
                                            )),
                                            DataCell(
                                              SizedBox(
                                                width: _wActions,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: IconButton(
                                                    iconSize: 20,
                                                    tooltip: 'Supprimer',
                                                    color: scheme.error,
                                                    icon: const Icon(
                                                        Icons.delete_outline),
                                                    onPressed: () =>
                                                        _confirmDelete(p),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Pagination
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Page ${_page + 1}',
                        style: Theme.of(context).textTheme.labelLarge),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _page == 0
                              ? null
                              : () {
                                  _page = _page - 1;
                                  _reload();
                                  _searchFocus.requestFocus();
                                },
                          icon: const Icon(Icons.chevron_left),
                          label: const Text('Précédent'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: !_hasMore
                              ? null
                              : () {
                                  _page = _page + 1;
                                  _reload();
                                  _searchFocus.requestFocus();
                                },
                          icon: const Icon(Icons.chevron_right),
                          label: const Text('Suivant'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
