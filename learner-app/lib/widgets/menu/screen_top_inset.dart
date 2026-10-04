import 'package:flutter/material.dart';

class ScreenTopInset extends StatelessWidget {
  const ScreenTopInset({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox(height: topInset > 0 ? topInset : 37);
  }
}
