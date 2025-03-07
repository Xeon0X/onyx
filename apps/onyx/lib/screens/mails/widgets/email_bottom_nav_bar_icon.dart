import 'package:flutter/material.dart';

class MailBottomNavBarIcon extends StatelessWidget {
  const MailBottomNavBarIcon({super.key, required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Icon(
        Icons.email_rounded,
        color: selected
            ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
            : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      ),
    );
  }
}
