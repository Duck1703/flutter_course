import 'package:flutter/material.dart';

class ScreenBottomInset extends StatelessWidget {
  const ScreenBottomInset({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SizedBox(height: bottomInset > 0 ? bottomInset : 34);
  }
}
