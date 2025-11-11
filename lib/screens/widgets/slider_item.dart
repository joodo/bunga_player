import 'package:bunga_player/screens/widgets/text_editing_shortcut_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';

class SliderItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value, min, max;
  final String label;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  const SliderItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    required this.label,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return [
      Icon(icon).iconColor(theme.textTheme.bodyMedium!.color!),
      <Widget>[
        Text(title).textStyle(theme.textTheme.bodyLarge!).padding(top: 12.0),
        Slider(
          min: min,
          max: max,
          value: value,
          label: label,
          onChanged: onChanged,
          onChangeStart: onChangeStart,
          onChangeEnd: onChangeEnd,
        ).controlSliderTheme(context).padding(left: 2.0),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
          .padding(left: 16.0)
          .flexible(),
    ].toRow(crossAxisAlignment: CrossAxisAlignment.center);
  }
}

class SliderItemWithTextInput extends StatefulWidget {
  final IconData icon;
  final String title;

  final double value, min, max;
  // Allow value to exceed min/max when inputting via text field
  final bool allowExceed;

  final String Function(double value) labelFormatter;
  final String? suffix;

  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  const SliderItemWithTextInput({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.allowExceed = false,
    this.labelFormatter = _defaultLabelFormatter,
    this.suffix,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
  });

  static String _defaultLabelFormatter(double value) =>
      value.toStringAsFixed(2);

  @override
  State<SliderItemWithTextInput> createState() =>
      _SliderItemWithTextInputState();
}

class _SliderItemWithTextInputState extends State<SliderItemWithTextInput> {
  late final _controller = TextEditingController(
    text: widget.labelFormatter(widget.value),
  );

  late final _focusNode = FocusNode();
  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final parsed = double.tryParse(_controller.text);

      if (parsed != null &&
          (widget.allowExceed ||
              parsed >= widget.min && parsed <= widget.max)) {
        widget.onChanged?.call(parsed);
      } else {
        // Revert to previous value
        _controller.text = widget.labelFormatter(widget.value);
      }
    }
  }

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return [
      Icon(widget.icon).iconColor(theme.textTheme.bodyMedium!.color!),
      <Widget>[
        [
          Text(widget.title).textStyle(theme.textTheme.bodyLarge!).expanded(),
          TextEditingShortcutWrapper(
            child: IntrinsicWidth(
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 8.0,
                  ),
                  isDense: true,
                  suffixText: widget.suffix,
                ),
                textAlign: TextAlign.center,
                controller: _controller,
                focusNode: _focusNode,
              ).constrained(minWidth: 70.0),
            ),
          ),
        ].toRow().padding(top: 12.0),
        Slider(
          min: widget.min,
          max: widget.max,
          value: widget.value.clamp(widget.min, widget.max),
          onChanged: widget.onChanged,
          onChangeStart: widget.onChangeStart,
          onChangeEnd: widget.onChangeEnd,
        ).controlSliderTheme(context).padding(left: 2.0),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
          .padding(left: 16.0)
          .flexible(),
    ].toRow(crossAxisAlignment: CrossAxisAlignment.center);
  }

  @override
  void didUpdateWidget(covariant SliderItemWithTextInput oldWidget) {
    _controller.text = widget.labelFormatter(widget.value);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);

    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
