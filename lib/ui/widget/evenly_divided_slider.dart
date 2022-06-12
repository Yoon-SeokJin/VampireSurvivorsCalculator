import 'package:flutter/material.dart';

class EvenlyDividedSlider extends StatelessWidget {
  const EvenlyDividedSlider({
    Key? key,
    required this.value,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.onChangedEnd,
  })  : assert(max <= divisions),
        super(key: key);
  final int value;
  final int max;
  final int divisions;
  final void Function(int)? onChanged;
  final void Function(int)? onChangedEnd;

  @override
  Widget build(BuildContext context) {
    SliderComponentShape trackShape =
        SliderTheme.of(context).overlayShape ?? const RoundSliderOverlayShape();
    double trackShapeRadiusWidth = trackShape.getPreferredSize(true, true).width;
    return LayoutBuilder(builder: (context, constraints) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: (constraints.maxWidth - trackShapeRadiusWidth) * max / divisions +
              trackShapeRadiusWidth,
          child: Slider(
            label: value.toString(),
            value: value.toDouble(),
            max: max.toDouble(),
            divisions: max,
            onChanged: onChanged != null ? (double value) => onChanged!(value.toInt()) : null,
            onChangeEnd:
                onChangedEnd != null ? (double value) => onChangedEnd!(value.toInt()) : null,
          ),
        ),
      );
    });
  }
}
