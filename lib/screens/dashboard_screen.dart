import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard NaxuGest')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(
                context, 'Produits', AppRoutes.products, Icons.inventory),
            _buildCard(
                context, 'Chantiers', AppRoutes.chantiers, Icons.business),
            _buildCard(context, 'Fournisseurs', AppRoutes.fournisseurs,
                Icons.local_shipping),
            _buildCard(context, 'Chefs', AppRoutes.chefs, Icons.person),
            _buildCard(
                context, 'Commandes', AppRoutes.commandes, Icons.assignment),
            _buildCard(context, 'BL', AppRoutes.bl, Icons.receipt),
            _buildCard(context, 'Factures', AppRoutes.factures, Icons.payment),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, String route, IconData icon) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
