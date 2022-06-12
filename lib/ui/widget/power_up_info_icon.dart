import 'package:flutter/material.dart';

class PowerUpInfoIcon extends StatelessWidget {
  const PowerUpInfoIcon({
    Key? key,
    required this.figure,
    required this.order,
    required this.level,
  }) : super(key: key);

  final Widget figure;
  final int? order;
  final int level;

  Widget getOutlinedText(String text) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = Colors.black),
        ),
        Text(text, style: const TextStyle(color: Colors.white))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Stack(
          children: [
            SizedBox(
              width: (Theme.of(context).dataTableTheme.dataRowHeight ?? kMinInteractiveDimension) *
                  1.5,
              height: (Theme.of(context).dataTableTheme.dataRowHeight ?? kMinInteractiveDimension) *
                  1.5,
              child: figure,
            ),
            getOutlinedText((order ?? '').toString())
          ],
        ),
        getOutlinedText('Lv' + level.toString()),
      ],
    );
  }
}
