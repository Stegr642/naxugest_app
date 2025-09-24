import 'package:flutter/material.dart';

class NouvelleCommandeDialog extends StatefulWidget {
  final List<Map<String, dynamic>> produitsDisponibles;
  final List<Map<String, dynamic>> chantiers;
  final List<Map<String, dynamic>> chefs;
  final Map<String, dynamic>? commandeExistante;

  const NouvelleCommandeDialog({
    super.key,
    required this.produitsDisponibles,
    required this.chantiers,
    required this.chefs,
    this.commandeExistante,
  });

  @override
  State<NouvelleCommandeDialog> createState() => _NouvelleCommandeDialogState();
}

class _NouvelleCommandeDialogState extends State<NouvelleCommandeDialog> {
  List<Map<String, dynamic>> _disponibles = [];
  List<Map<String, dynamic>> _ajoutes = [];
  Map<int, int> _quantites = {}; // id produit -> quantité

  String? _chantierId;
  String? _chefId;

  @override
  void initState() {
    super.initState();
    _disponibles = List.from(widget.produitsDisponibles);

    if (widget.commandeExistante != null) {
      _ajoutes = List<Map<String, dynamic>>.from(
          widget.commandeExistante!['produits']);
      for (var p in _ajoutes) {
        _quantites[p['id']] = p['quantite'] ?? 1;
        _disponibles.removeWhere((d) => d['id'] == p['id']);
      }
      _chantierId = widget.commandeExistante!['chantier_id']?.toString();
      _chefId = widget.commandeExistante!['chef_id']?.toString();
    }
  }

  void _ajouterProduit(Map<String, dynamic> produit) {
    setState(() {
      _disponibles.remove(produit);
      _ajoutes.add(produit);
      _quantites[produit['id']] = 1;
    });
  }

  void _retirerProduit(Map<String, dynamic> produit) {
    setState(() {
      _ajoutes.remove(produit);
      _disponibles.add(produit);
      _quantites.remove(produit['id']);
    });
  }

  Widget _buildProduitCard(Map<String, dynamic> produit,
      {bool isAjoute = false}) {
    final quantite = _quantites[produit['id']] ?? 1;
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(produit['nom'],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Stock dispo: ${produit['stock_disponible']} | Prix: ${produit['prix_unitaire']}'),
        trailing: isAjoute
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.red),
                      onPressed: () {
                        if (_quantites[produit['id']]! > 1) {
                          setState(() => _quantites[produit['id']] =
                              _quantites[produit['id']]! - 1);
                        }
                      }),
                  Text(quantite.toString()),
                  IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.green),
                      onPressed: () {
                        setState(() => _quantites[produit['id']] =
                            _quantites[produit['id']]! + 1);
                      }),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => _retirerProduit(produit)),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: () => _ajouterProduit(produit),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Nouvelle Commande',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _chantierId,
                      decoration: const InputDecoration(labelText: 'Chantier'),
                      items: widget.chantiers
                          .map((c) => DropdownMenuItem(
                              value: c['id'].toString(), child: Text(c['nom'])))
                          .toList(),
                      onChanged: (v) => setState(() => _chantierId = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _chefId,
                      decoration:
                          const InputDecoration(labelText: 'Chef d’équipe'),
                      items: widget.chefs
                          .map((c) => DropdownMenuItem(
                              value: c['id'].toString(), child: Text(c['nom'])))
                          .toList(),
                      onChanged: (v) => setState(() => _chefId = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Produits disponibles',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _disponibles.length,
                              itemBuilder: (_, i) =>
                                  _buildProduitCard(_disponibles[i]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 16, thickness: 2),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Produits ajoutés',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _ajoutes.length,
                              itemBuilder: (_, i) => _buildProduitCard(
                                  _ajoutes[i],
                                  isAjoute: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_chantierId != null &&
                          _chefId != null &&
                          _ajoutes.isNotEmpty) {
                        Navigator.pop(context, {
                          'chantierId': _chantierId,
                          'chefId': _chefId,
                          'produits': _ajoutes.map((p) {
                            return {
                              ...p,
                              'quantite': _quantites[p['id']] ?? 1,
                            };
                          }).toList(),
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Veuillez sélectionner chantier, chef et au moins 1 produit')),
                        );
                      }
                    },
                    child: const Text('Valider'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
