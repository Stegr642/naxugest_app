import 'package:flutter/material.dart';
import 'produits_screen.dart';
import 'commandes_screen.dart';
import 'chefs_screen.dart';
import 'fournisseurs_screen.dart';
import 'factures_screen.dart';

class HomeScreenTabBar extends StatefulWidget {
  const HomeScreenTabBar({super.key});

  @override
  State<HomeScreenTabBar> createState() => _HomeScreenTabBarState();
}

class _HomeScreenTabBarState extends State<HomeScreenTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _screens.length, vsync: this);
  }

  void _onSelectScreen(int index) {
    _tabController.index = index;
    Navigator.pop(context); // fermer drawer
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tabController.index]),
        backgroundColor: Colors.teal,
        bottom: isWide
            ? TabBar(
                controller: _tabController,
                tabs: _titles.map((t) => Tab(text: t)).toList(),
                isScrollable: true,
              )
            : null,
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
            for (int i = 0; i < _titles.length; i++)
              ListTile(
                leading: Icon(
                  i == 0
                      ? Icons.inventory
                      : i == 1
                          ? Icons.list_alt
                          : i == 2
                              ? Icons.group
                              : i == 3
                                  ? Icons.local_shipping
                                  : Icons.receipt,
                ),
                title: Text(_titles[i]),
                selected: _tabController.index == i,
                onTap: () => _onSelectScreen(i),
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _screens,
      ),
    );
  }
}
