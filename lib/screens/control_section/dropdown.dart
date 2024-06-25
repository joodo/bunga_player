import 'package:bunga_player/mocks/dropdown.dart' as mock;
import 'package:bunga_player/screens/widgets/loading_text.dart';
import 'package:flutter/material.dart';

class ControlDropdown<T> extends StatelessWidget {
  final List<mock.DropdownMenuItem<T>> items;
  final T? value;
  final ValueSetter<T?> onChanged;
  final bool enabled;

  const ControlDropdown({
    super.key,
    required this.items,
    this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(0),
        border: const OutlineInputBorder(),
        enabled: this.enabled,
      ),
      child: mock.DropdownButtonHideUnderline(
        child: mock.MyDropdownButton<T>(
          items: items,
          value: value,
          onChanged: this.enabled ? onChanged : null,
          useRootOverlay: true,
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          borderRadius: BorderRadius.circular(4),
          style: Theme.of(context).textTheme.bodyMedium,
          isExpanded: true,
          isDense: true,
          itemHeight: null,
          focusColor: Colors.transparent,
          selectedItemBuilder: (context) => items.map(
            (e) {
              if (e.child is! Text) return const SizedBox.shrink();
              return DropdownMenuItem<T>(
                value: e.value,
                child: enabled
                    ? Text(
                        (e.child as Text).data!,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const LoadingText('载入中'),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
