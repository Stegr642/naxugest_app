import 'package:flutter/material.dart';
import 'produits_screen.dart';
import 'commandes_screen.dart';
import 'chefs_screen.dart';
import 'fournisseurs_screen.dart';
import 'factures_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ProduitsScreen(),
    CommandesScreen(),
    ChefsScreen(),
    FournisseursScreen(),
    FacturesScreen(),
  ];

  final List<String> _titles = [
    'Produits',
    'Commandes',
    'Chefs d’équipe',
    'Fournisseurs',
    'Factures',
  ];

  void _onSelectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // fermer le drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NaxuGest',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Gestion de stock et chantiers',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Produits'),
              selected: _selectedIndex == 0,
              onTap: () => _onSelectScreen(0),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Commandes'),
              selected: _selectedIndex == 1,
              onTap: () => _onSelectScreen(1),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Chefs d’équipe'),
              selected: _selectedIndex == 2,
              onTap: () => _onSelectScreen(2),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Fournisseurs'),
              selected: _selectedIndex == 3,
              onTap: () => _onSelectScreen(3),
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Factures'),
              selected: _selectedIndex == 4,
              onTap: () => _onSelectScreen(4),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
