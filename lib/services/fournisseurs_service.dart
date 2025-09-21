import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fournisseur.dart';

class FournisseursService {
  static const _key = "naxugest_fournisseurs";

  Future<List<Fournisseur>> loadFournisseurs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Fournisseur.fromJson(e)).toList();
  }

  Future<void> saveFournisseurs(List<Fournisseur> fournisseurs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(fournisseurs.map((f) => f.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  String nextCode(List<Fournisseur> fournisseurs) {
    int max = 0;
    for (var f in fournisseurs) {
      final m = RegExp(r"FO-(\d+)").firstMatch(f.code);
      final n = m != null ? int.parse(m.group(1)!) : 0;
      if (n > max) max = n;
    }
    return "FO-${(max + 1).toString().padLeft(4, "0")}";
  }
}
