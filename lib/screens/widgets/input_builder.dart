import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class InputBuilder extends SingleChildStatefulWidget {
  final Widget Function(
    BuildContext context,
    TextEditingController textEditingController,
    FocusNode focusNode,
    Widget? child,
  ) builder;
  final String? initValue;
  final void Function(TextEditingController controller)? onFocusLose;
  final void Function(TextEditingController controller)? onFocusGot;

  const InputBuilder({
    super.key,
    super.child,
    this.initValue,
    this.onFocusLose,
    this.onFocusGot,
    required this.builder,
  });

  @override
  State<InputBuilder> createState() => _InputBuilderState();
}

class _InputBuilderState extends SingleChildState<InputBuilder> {
  final _editingControl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(_onFocusChange);

    _editingControl.text = widget.initValue ?? '';
  }

  @override
  void dispose() {
    _editingControl.dispose();

    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return widget.builder(
      context,
      _editingControl,
      _focusNode,
      child,
    );
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onFocusLose?.call(_editingControl);
    } else {
      widget.onFocusGot?.call(_editingControl);
    }
  }
}
