import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';

class WheelPicker extends StatefulWidget {
  final List<String> items;
  final int initialIndex;
  final ValueChanged<int> onSelectedChanged;
  final double width;
  final Color fadeColor;

  const WheelPicker({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onSelectedChanged,
    this.width = AppTokens.qzdsSpacingGiant,
    this.fadeColor = AppTokens.white100,
  });

  @override
  State<WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker> {
  late FixedExtentScrollController _controller;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _controller = FixedExtentScrollController(initialItem: widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant WheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialIndex != widget.initialIndex &&
        widget.initialIndex != _selectedIndex) {
      _selectedIndex = widget.initialIndex;
      _controller.animateToItem(
        widget.initialIndex,
        duration: AppTokens.motionMedium,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: AppTokens.qzdsPickerItemHeight * 5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListWheelScrollView.useDelegate(
            controller: _controller,
            physics: const FixedExtentScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemExtent: AppTokens.qzdsPickerItemHeight,
            diameterRatio: 1.65,
            perspective: 0.003,
            squeeze: 0.92,
            useMagnifier: true,
            magnification: 1.03,
            overAndUnderCenterOpacity: 0.55,
            onSelectedItemChanged: _handleSelectedItemChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, index) {
                return _WheelPickerItem(
                  text: widget.items[index],
                  selected: index == _selectedIndex,
                );
              },
            ),
          ),
          const _PickerDivider(offset: -AppTokens.qzdsPickerItemHeight / 2),
          const _PickerDivider(offset: AppTokens.qzdsPickerItemHeight / 2),
          _PickerFade(
            alignment: Alignment.topCenter,
            begin: true,
            color: widget.fadeColor,
          ),
          _PickerFade(
            alignment: Alignment.bottomCenter,
            begin: false,
            color: widget.fadeColor,
          ),
        ],
      ),
    );
  }

  void _handleSelectedItemChanged(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
    widget.onSelectedChanged(index);
  }
}

class _WheelPickerItem extends StatelessWidget {
  final String text;
  final bool selected;

  const _WheelPickerItem({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppTokens.qzdsPurple600
        : AppTokens.qzdsPurple600.withValues(alpha: 0.56);
    final style = AppTokens.qzdsWheelNumber.copyWith(
      color: color,
      fontSize: selected ? 32 : 27,
      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
    );

    return Center(
      child: AnimatedScale(
        scale: selected ? 1 : 0.94,
        duration: AppTokens.motionFast,
        curve: Curves.easeOutCubic,
        child: AnimatedDefaultTextStyle(
          duration: AppTokens.motionFast,
          curve: Curves.easeOutCubic,
          style: style,
          child: Text(text),
        ),
      ),
    );
  }
}

class _PickerDivider extends StatelessWidget {
  final double offset;

  const _PickerDivider({required this.offset});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Divider(
        thickness: AppTokens.qzdsSpacingXxxs,
        color: AppTokens.qzdsPurple100,
      ),
    );
  }
}

class _PickerFade extends StatelessWidget {
  final Alignment alignment;
  final bool begin;
  final Color color;

  const _PickerFade({
    required this.alignment,
    required this.begin,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          height: AppTokens.qzdsPickerItemHeight * 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin ? Alignment.topCenter : Alignment.bottomCenter,
              end: begin ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
