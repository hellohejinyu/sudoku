import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Cell extends StatefulWidget {
  final int? value;
  final VoidCallback onTap;
  final bool? isInputMode;
  final bool? isFixed;
  final bool hasConflict;
  final Function(String input) onInput;
  final Color? backgroundColor;

  const Cell({
    super.key,
    this.backgroundColor,
    required this.hasConflict,
    this.isFixed,
    required this.onInput,
    this.isInputMode,
    required this.onTap,
    this.value,
  });

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  final textController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void didUpdateWidget(Cell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInputMode == true && !focusNode.hasFocus) {
      focusNode.requestFocus();
    }
    if (widget.isInputMode != true) {
      textController.text = '';
    } else {
      if (textController.text != (widget.value ?? '').toString()) {
        textController.text = (widget.value ?? '').toString();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        color: widget.hasConflict
            ? Colors.red.withAlpha(64)
            : widget.backgroundColor ?? Colors.grey.withAlpha(64),
        child: Center(
          child: widget.isInputMode == true
              ? TextField(
                  onChanged: (input) {
                    widget.onInput(input);
                  },
                  focusNode: focusNode,
                  textAlignVertical: TextAlignVertical.center,
                  controller: textController,
                  decoration: const InputDecoration(
                    counterText: '',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[1-9]')),
                  ],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                    height: 1,
                  ),
                )
              : Text(
                  (widget.value ?? '').toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: widget.isFixed == true
                        ? Colors.black87
                        : Colors.blueAccent,
                    height: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
