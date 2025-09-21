import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final String hint;
  final String? filterLabel;
  final List<String>? filterOptions;
  final String? selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?>? onFilterChanged;

  const SearchFilterBar({
    super.key,
    required this.hint,
    required this.onSearchChanged,
    this.filterLabel,
    this.filterOptions,
    this.selectedFilter,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: onSearchChanged,
        ),
        if (filterOptions != null && filterOptions!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Text(filterLabel ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: filterOptions!
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: onFilterChanged,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
