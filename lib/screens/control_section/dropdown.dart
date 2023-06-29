import 'package:bunga_player/mocks/dropdown.dart' as mock;
import 'package:flutter/material.dart';

class ControlDropdown extends StatelessWidget {
  final List<mock.DropdownMenuItem<String>> items;
  final String? value;
  final ValueSetter<String?> onChanged;

  const ControlDropdown({
    super.key,
    required this.items,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 4),
        border: OutlineInputBorder(),
      ),
      child: mock.DropdownButtonHideUnderline(
        child: mock.MyDropdownButton<String>(
          items: items,
          value: value,
          onChanged: onChanged,
          useRootOverlay: true,
          padding: const EdgeInsets.only(
            left: 12,
            right: 4,
            top: 8,
            bottom: 8,
          ),
          borderRadius: BorderRadius.circular(4),
          style: Theme.of(context).textTheme.bodyMedium,
          isExpanded: true,
          isDense: true,
          itemHeight: null,
          focusColor: Colors.transparent,
          selectedItemBuilder: (context) => items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.value,
                  child: Text(
                    (e.child as Text).data!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
