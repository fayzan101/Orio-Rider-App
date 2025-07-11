import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonType { primary, secondary, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isExpanded;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isExpanded = true,
    this.icon,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.poppins(
      color: type == ButtonType.primary ? Colors.white : (type == ButtonType.danger ? Colors.red : Colors.black),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
    final btnChild = icon == null
        ? Text(text, style: style)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [icon!, const SizedBox(width: 8), Text(text, style: style)],
          );
    final btnPadding = padding ?? const EdgeInsets.symmetric(vertical: 14);

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF18136E),
              shape: shape,
              padding: btnPadding,
              elevation: 0,
            ),
            onPressed: onPressed,
            child: btnChild,
          ),
        );
      case ButtonType.secondary:
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF3F3F3),
              side: BorderSide.none,
              shape: shape,
              padding: btnPadding,
            ),
            onPressed: onPressed,
            child: btnChild,
          ),
        );
      case ButtonType.danger:
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
              foregroundColor: Colors.red,
              shape: shape,
              padding: btnPadding,
              elevation: 0,
            ),
            onPressed: onPressed,
            child: btnChild,
          ),
        );
    }
  }
} 