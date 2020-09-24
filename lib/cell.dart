import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Cell extends StatefulWidget {
  final int value;
  final VoidCallback onTap;
  final bool isInputMode;
  final bool isFixed;
  final bool hasConflict;
  final Function(String input) onInput;
  final Color backgroundColor;

  const Cell({
    Key key,
    @required this.backgroundColor,
    @required this.hasConflict,
    @required this.isFixed,
    @required this.onInput,
    @required this.isInputMode,
    @required this.onTap,
    @required this.value,
  }) : super(key: key);
  @override
  _CellState createState() => _CellState();
}

class _CellState extends State<Cell> {
  final textController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void didUpdateWidget(Cell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInputMode && !focusNode.hasFocus) {
      focusNode.requestFocus();
    }
    if (!widget.isInputMode) {
      textController.text = '';
    } else {
      if (widget.value != null &&
          textController.text != widget.value.toString()) {
        textController.text = widget.value.toString();
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
            ? Colors.redAccent.withAlpha(40)
            : widget.backgroundColor,
        child: Center(
          child: widget.isInputMode
              ? TextField(
                  onChanged: (input) {
                    widget.onInput(input);
                  },
                  focusNode: focusNode,
                  textAlignVertical: TextAlignVertical.center,
                  controller: textController,
                  decoration: InputDecoration(
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                    height: 1,
                  ),
                )
              : Text(
                  widget.value != null ? widget.value.toString() : '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: widget.isFixed ? Colors.black87 : Colors.blueAccent,
                    height: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
