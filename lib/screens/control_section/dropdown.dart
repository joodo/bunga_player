import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ControlDropdown extends StatelessWidget {
  final List<DropdownMenuItem<String>> items;
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
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        items: items,
        value: value,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyMedium,
        isExpanded: true,
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        dropdownStyleData: const DropdownStyleData(
          useRootNavigator: true,
          // HACK: https://github.com/AhmedLSayed9/dropdown_button2/issues/157
          isFullScreen: null,
          isOverButton: true,
        ),
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
    );
  }
}
