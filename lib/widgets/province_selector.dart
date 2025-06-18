import 'package:flutter/material.dart';

class ProvinceSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String?> onChanged;
  
  const ProvinceSelector({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  static const List<String> provinces = [
    'Maputo Cidade',
    'Maputo Provincia',
    'Gaza',
    'Inhambane',
    'Manica',
    'Sofala',
    'Tete',
    'Zambézia',
    'Nampula',
    'Cabo Delgado',
    'Niassa'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: selected,
        items: provinces.map((String province) {
          return DropdownMenuItem<String>(
            value: province,
            child: Text(province),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
