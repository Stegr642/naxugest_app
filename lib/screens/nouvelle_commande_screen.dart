import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class NouvelleCommandeScreen extends StatefulWidget {
  const NouvelleCommandeScreen({super.key});

  @override
  State<NouvelleCommandeScreen> createState() => _NouvelleCommandeScreenState();
}

class _NouvelleCommandeScreenState extends State<NouvelleCommandeScreen> {
  final _formKey = GlobalKey<FormState>();

  List<String> _chantiers = [];
  List<String> _chefs = [];
  List<String> _produits = [];

  String? _selectedChantier;
  String? _selectedChef;
  String? _selectedProduit;
  int _quantite = 1;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final chantiersData =
          await supabase.from('chantiers').select('nom') as List<dynamic>;
      final chefsData =
          await supabase.from('chefs').select('nom') as List<dynamic>;
      final produitsData =
          await supabase.from('produits').select('nom') as List<dynamic>;

      setState(() {
        _chantiers =
            List<String>.from(chantiersData.map((e) => e['nom'].toString()));
        _chefs = List<String>.from(chefsData.map((e) => e['nom'].toString()));
        _produits =
            List<String>.from(produitsData.map((e) => e['nom'].toString()));
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des données : $e');
    }
  }

  void _submitCommande() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final payload = {
        'chantier': _selectedChantier,
        'chef': _selectedChef,
        'produit': _selectedProduit,
        'quantite': _quantite,
        'date': DateTime.now().toIso8601String(),
      };

      try {
        await supabase.from('commandes').insert(payload);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Commande ajoutée avec succès')));
        _formKey.currentState!.reset();
        setState(() {
          _selectedChantier = null;
          _selectedChef = null;
          _selectedProduit = null;
          _quantite = 1;
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Commande'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedChantier,
                hint: const Text('Sélectionner chantier'),
                items: _chantiers
                    .map((c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedChantier = value),
                validator: (value) => value == null ? 'Chantier requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedChef,
                hint: const Text('Sélectionner chef'),
                items: _chefs
                    .map((c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedChef = value),
                validator: (value) => value == null ? 'Chef requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedProduit,
                hint: const Text('Sélectionner produit'),
                items: _produits
                    .map((p) => DropdownMenuItem<String>(
                          value: p,
                          child: Text(p),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedProduit = value),
                validator: (value) => value == null ? 'Produit requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _quantite.toString(),
                decoration: const InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final q = int.tryParse(value ?? '');
                  if (q == null || q <= 0) return 'Quantité invalide';
                  return null;
                },
                onSaved: (value) => _quantite = int.parse(value!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitCommande,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Ajouter la commande',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
