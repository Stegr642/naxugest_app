import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/supabase_client.dart';

class F_EditProduit extends StatefulWidget {
  final int? idProduit; // null => création
  const F_EditProduit({super.key, this.idProduit});

  @override
  State<F_EditProduit> createState() => _F_EditProduitState();
}

class _F_EditProduitState extends State<F_EditProduit> {
  final _formKey = GlobalKey<FormState>();

  final _designationCtrl = TextEditingController();
  final _qteStockCtrl = TextEditingController();
  final _qteMinCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();

  int? _idUnite;
  int? _idCategorie;

  bool _loading = true;
  bool _saving = false;

  List<Map<String, dynamic>> _unites = [];
  List<Map<String, dynamic>> _categories = [];

  final _numInputFmt = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
  ];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _designationCtrl.dispose();
    _qteStockCtrl.dispose();
    _qteMinCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final futUnites = supa.from('v_unites').select('id_unite, lib_unite');
      final futCats = supa.from('v_categories').select('*');

      final results = await Future.wait([futUnites, futCats]);
      _unites = (results[0] as List).cast<Map<String, dynamic>>();
      _categories = (results[1] as List).cast<Map<String, dynamic>>();

      if (widget.idProduit != null) {
        final row = await supa
            .from('v_produits')
            .select(
                'id_produit, designation, qte_stock, qte_min, prix_unitaire, id_unite, id_categorie')
            .eq('id_produit', widget.idProduit!)
            .single();

        _designationCtrl.text = (row['designation'] ?? '') as String;
        _qteStockCtrl.text = _numToText(row['qte_stock']);
        _qteMinCtrl.text = _numToText(row['qte_min']);
        _prixCtrl.text = _numToText(row['prix_unitaire']);
        _idUnite = row['id_unite'] as int?;
        _idCategorie = row['id_categorie'] as int?;
      }
    } on PostgrestException catch (e) {
      _showSnack('Erreur chargement: ${e.message}');
    } catch (e) {
      _showSnack('Erreur: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _numToText(dynamic v) => v == null ? '' : '$v';

  num? _parseNum(String s) {
    final t = s.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (t.isEmpty) return null;
    return num.tryParse(t);
  }

  String _catLabel(Map<String, dynamic> m) {
    final label = m['lib_categorie'] ??
        m['libelle'] ??
        m['nom'] ??
        m['name'] ??
        m['code'] ??
        '';
    return label.toString();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final payload = {
        'p_id_produit': widget.idProduit, // null en création
        'p_designation': _designationCtrl.text.trim().isEmpty
            ? null
            : _designationCtrl.text.trim(),
        'p_qte_stock': _parseNum(_qteStockCtrl.text),
        'p_qte_min': _parseNum(_qteMinCtrl.text),
        'p_prix_unitaire': _parseNum(_prixCtrl.text),
        'p_id_unite': _idUnite,
        'p_id_categorie': _idCategorie,
      };

      await supa.rpc('produits_upsert', params: payload);

      if (!mounted) return;
      _showSnack('Enregistré avec succès.');
      context.go('/produits');
    } on PostgrestException catch (e) {
      final code = (e.code ?? '').toUpperCase();
      final msg = (e.message ?? '').toLowerCase();

      if (code == '23505' ||
          msg.contains('désignation') ||
          msg.contains('unique') ||
          msg.contains('produits_designation_uniq')) {
        _showSnack(
            'La désignation existe déjà. Merci d’utiliser une autre désignation.');
      } else if (code == '23514' || msg.contains('obligatoire')) {
        _showSnack('La désignation est obligatoire.');
      } else {
        _showSnack('Erreur enregistrement: ${e.message}');
      }
    } catch (e) {
      _showSnack('Erreur: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.idProduit == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le produit ?'),
        content: const Text('Cette action est définitive.'),
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
    if (ok != true) return;

    try {
      await supa
          .rpc('produits_delete', params: {'p_id_produit': widget.idProduit!});
      if (!mounted) return;
      _showSnack('Supprimé.');
      context.go('/produits');
    } on PostgrestException catch (e) {
      _showSnack('Erreur suppression: ${e.message}');
    } catch (e) {
      _showSnack('Erreur: $e');
    }
  }

  void _cancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/produits');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.idProduit != null;

    return WillPopScope(
      onWillPop: () async {
        if (context.canPop()) return true;
        context.go('/produits');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Modifier le produit' : 'Nouveau produit'),
          actions: [
            if (isEdit)
              IconButton(
                tooltip: 'Supprimer',
                onPressed: _saving ? null : _delete,
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isEdit
                                          ? 'Fiche produit'
                                          : 'Création de produit',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _designationCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Désignation',
                                    hintText: 'ex: Cable U1000R2V 4G16',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'La désignation est obligatoire';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<int>(
                                  value: _idUnite,
                                  isExpanded: true,
                                  items: _unites.map((u) {
                                    return DropdownMenuItem<int>(
                                      value: u['id_unite'] as int,
                                      child: Text(
                                          (u['lib_unite'] ?? '').toString()),
                                    );
                                  }).toList(),
                                  onChanged: (v) =>
                                      setState(() => _idUnite = v),
                                  decoration:
                                      const InputDecoration(labelText: 'Unité'),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<int>(
                                  value: _idCategorie,
                                  isExpanded: true,
                                  items: _categories.map((c) {
                                    return DropdownMenuItem<int>(
                                      value: c['id_categorie'] as int,
                                      child: Text(_catLabel(c)),
                                    );
                                  }).toList(),
                                  onChanged: (v) =>
                                      setState(() => _idCategorie = v),
                                  decoration: const InputDecoration(
                                      labelText: 'Catégorie'),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _qteStockCtrl,
                                        decoration: const InputDecoration(
                                            labelText: 'Qté Stock'),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: _numInputFmt,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _qteMinCtrl,
                                        decoration: const InputDecoration(
                                            labelText: 'Qté Min'),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: _numInputFmt,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _prixCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Prix Unitaire',
                                    helperText:
                                        'Le code produit est généré automatiquement côté DB',
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: _numInputFmt,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: _saving ? null : _save,
                                        icon: const Icon(Icons.save),
                                        label: Text(_saving
                                            ? 'Enregistrement...'
                                            : 'Enregistrer'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _saving ? null : _cancel,
                                        icon: const Icon(Icons.close),
                                        label: const Text('Annuler'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
