import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

/// 6-digit verification input with auto-advance and themed borders.
class VerificationCodeInput extends StatefulWidget {
  const VerificationCodeInput({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.controllers,
    this.fieldSize = 51,
    this.gap = 16,
    this.autofocus = false,
    this.error = false,
    this.inactiveBorderColor,
    this.focusedBorderColor,
    this.filled = true,
    this.fillColor,
  })  : assert(length > 0, 'length must be positive.'),
        assert(controllers == null || controllers.length == length,
            'controllers length must match the configured length.');

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final List<TextEditingController>? controllers;
  final double fieldSize;
  final double gap;
  final bool autofocus;
  final bool error;
  final Color? inactiveBorderColor;
  final Color? focusedBorderColor;
  final bool filled;
  final Color? fillColor;

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final bool _ownsControllers;
  bool _skipNextOnChanged = false;

  @override
  void initState() {
    super.initState();
    final provided = widget.controllers;
    if (provided != null) {
      _controllers = provided;
      _ownsControllers = false;
    } else {
      _controllers =
          List.generate(widget.length, (_) => TextEditingController());
      _ownsControllers = true;
    }
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    if (_ownsControllers) {
      for (final controller in _controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    final inactiveBorderColor = widget.inactiveBorderColor ??
        theme.colorScheme.primary.withValues(alpha: 0.75);
    final activeBorderColor = widget.focusedBorderColor ?? theme.colorScheme.primary;
    final fillColor = widget.fillColor ?? tokens.cardSurface;
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: inactiveBorderColor, width: 1),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: activeBorderColor, width: 1.5),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const minField = 44.0;
        final length = widget.length;
        final gap = widget.gap;
        final available = constraints.maxWidth;
        final gapsWidth = gap * (length - 1);
        final usableWidth = available.isFinite ? available - gapsWidth : double.infinity;
        var desired = usableWidth.isFinite ? usableWidth / length : widget.fieldSize;
        if (!desired.isFinite) {
          desired = widget.fieldSize;
        }
        final fieldSize = desired.clamp(minField, widget.fieldSize).toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < length; i++) ...[
              Semantics(
                label: 'Ziffer ${i + 1} von $length',
                textField: true,
                child: SizedBox(
                  width: fieldSize,
                  height: fieldSize,
                  child: Focus(
                    focusNode: _focusNodes[i],
                    onKeyEvent: (node, event) => _handleKeyEvent(i, event),
                    child: TextField(
                      controller: _controllers[i],
                      autofocus: widget.autofocus && i == 0,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        height: 32 / 24,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      textInputAction: i == length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      autofillHints:
                          i == 0 ? const [AutofillHints.oneTimeCode] : null,
                      inputFormatters: [
                        if (i == 0)
                          _OtpPasteFormatter(
                            length: length,
                            onPaste: _handlePaste,
                          ),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: widget.filled,
                        fillColor: fillColor,
                        border: baseBorder,
                        enabledBorder: baseBorder,
                        focusedBorder:
                            widget.error ? errorBorder : focusedBorder,
                        errorBorder: errorBorder,
                        focusedErrorBorder: errorBorder,
                      ),
                      cursorColor: theme.colorScheme.onSurface,
                      onChanged: (value) => _handleChanged(i, value),
                      onTap: () => _controllers[i].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _controllers[i].text.length,
                      ),
                    ),
                  ),
                ),
              ),
              if (i != length - 1) SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }

  void _handlePaste(String digits) {
    final sanitized = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitized.isEmpty) {
      return;
    }
    _skipNextOnChanged = true;
    _applyPaste(0, sanitized);
    _notifyChange();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _skipNextOnChanged = false;
    });
    Future.microtask(() {
      if (!mounted) {
        return;
      }
      _skipNextOnChanged = false;
    });
  }

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isNotEmpty) {
        _setText(index, '');
        _notifyChange();
        return KeyEventResult.handled;
      }
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
        _setText(index - 1, '');
        _notifyChange();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleChanged(int index, String value) {
    if (_skipNextOnChanged) {
      _skipNextOnChanged = false;
      return;
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 1) {
      _applyPaste(index, digits);
    } else if (digits.isNotEmpty) {
      _setText(index, digits);
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      _setText(index, '');
    }
    _notifyChange();
  }

  void _applyPaste(int startIndex, String digits) {
    var cursor = startIndex;
    for (final char in digits.split('')) {
      if (cursor >= widget.length) {
        break;
      }
      _setText(cursor, char);
      cursor++;
    }
    if (cursor < widget.length) {
      _focusNodes[cursor].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }
  }

  void _setText(int index, String text) {
    _controllers[index].value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _notifyChange() {
    final code = _controllers.map((controller) => controller.text).join();
    widget.onChanged(code);
    if (widget.onCompleted != null &&
        _controllers.every((controller) => controller.text.isNotEmpty)) {
      widget.onCompleted!(code);
    }
  }
}

class _OtpPasteFormatter extends TextInputFormatter {
  _OtpPasteFormatter({
    required this.length,
    required this.onPaste,
  }) : assert(length > 0);

  final int length;
  final ValueChanged<String> onPaste;
  static final _digitRegex = RegExp(r'[0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 1) {
      final buffer = StringBuffer();
      for (var i = 0; i < digits.length && i < length; i++) {
        final char = digits[i];
        if (_digitRegex.hasMatch(char)) {
          buffer.write(char);
        }
      }
      final sanitized = buffer.toString();
      if (sanitized.isNotEmpty) {
        onPaste(sanitized);
      }
      final firstChar = sanitized.isNotEmpty ? sanitized[0] : '';
      return TextEditingValue(
        text: firstChar,
        selection: TextSelection.collapsed(offset: firstChar.isEmpty ? 0 : 1),
      );
    }

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final char = digits[0];
    return TextEditingValue(
      text: char,
      selection: const TextSelection.collapsed(offset: 1),
    );
  }
}
