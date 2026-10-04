import 'package:flutter/material.dart';

class MenuLoadingOverlay extends StatelessWidget {
  const MenuLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const AbsorbPointer(
      child: ColoredBox(
        color: Color(0x8C000000),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}
