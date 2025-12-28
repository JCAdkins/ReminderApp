import 'package:flutter/material.dart';

class TypeSelectorDropdown extends StatelessWidget {
  final List<String> types;
  final String selectedType;
  final ValueChanged<String> onChanged;
  final String label;

  const TypeSelectorDropdown({
    super.key,
    required this.types,
    required this.selectedType,
    required this.onChanged,
    this.label = 'Type',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: types.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  type[0].toUpperCase() + type.substring(1),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              if (selectedType == type)
                const Icon(Icons.radio_button_checked, color: Colors.blue)
              else
                const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            ],
          ),
        );
      }).toList(),
      // Only show text in closed state
      selectedItemBuilder: (context) {
        return types.map((type) {
          return Text(
            type[0].toUpperCase() + type.substring(1),
            style: const TextStyle(color: Colors.black),
          );
        }).toList();
      },
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      dropdownColor: Colors.white,
      iconEnabledColor: Colors.black,
    );
  }
}
