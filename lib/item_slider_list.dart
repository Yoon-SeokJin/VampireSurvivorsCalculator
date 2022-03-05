import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'power_up_pool.dart';

class ItemSliderList extends StatelessWidget {
  const ItemSliderList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double titleWidth = context.watch<PowerUpPool>().getTextWidthMax(context);
    List<Widget> itemSliderTileList = [];
    context.watch<PowerUpPool>().itemInfos.forEach((key, _) {
      itemSliderTileList.add(ChangeNotifierProvider.value(
        value: context.read<PowerUpPool>().powerUps[key],
        child: ItemSliderTile(
          itemName: key,
          titleWidth: titleWidth,
        ),
      ));
    });

    return Column(
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('뱀파이어 서바이버 0.3.0 기준 (22.03.06.)'),
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('최소'),
              onPressed: context.read<PowerUpPool>().setMinAll,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: const Text('최대'),
                onPressed: context.read<PowerUpPool>().setMaxAll,
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            controller: ScrollController(),
            children: itemSliderTileList,
          ),
        ),
      ],
    );
  }
}

class ItemSliderTile extends StatelessWidget {
  const ItemSliderTile(
      {Key? key, required this.itemName, required this.titleWidth})
      : super(key: key);
  final String itemName;
  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    SliderComponentShape trackShape =
        SliderTheme.of(context).overlayShape ?? const RoundSliderOverlayShape();

    Size iconSize = trackShape.getPreferredSize(true, true);
    return Row(
      children: [
        SizedBox.fromSize(
          size: iconSize,
          child: Image.asset(
              context.watch<PowerUpPool>().itemInfos[itemName]!.imagePath,
              filterQuality: FilterQuality.none,
              fit: BoxFit.fill),
        ),
        const SizedBox(width: 8.0),
        SizedBox(
          width: titleWidth,
          child: Text(itemName, style: Theme.of(context).textTheme.headline6),
        ),
        Expanded(
          child: EvenlyDividedSlider(
            value: context.watch<PowerUpPool>().powerUps[itemName]!.value,
            max: context.watch<PowerUpPool>().itemInfos[itemName]!.maxLevel,
            divisions: 5,
            onChanged: (double value) {
              context.read<PowerUpPool>().powerUps[itemName]!.value =
                  value.toInt();
            },
          ),
        ),
      ],
    );
  }
}

class EvenlyDividedSlider extends StatelessWidget {
  const EvenlyDividedSlider({
    Key? key,
    required this.value,
    required this.max,
    required this.divisions,
    required this.onChanged,
  })  : assert(max <= divisions),
        super(key: key);
  final int value;
  final int max;
  final int divisions;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    SliderComponentShape trackShape =
        SliderTheme.of(context).overlayShape ?? const RoundSliderOverlayShape();
    double trackShapeRadiusWidth =
        trackShape.getPreferredSize(true, true).width;
    return LayoutBuilder(builder: (context, constraints) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width:
              (constraints.maxWidth - trackShapeRadiusWidth) * max / divisions +
                  trackShapeRadiusWidth,
          child: Slider(
            label: value.toString(),
            value: value.toDouble(),
            max: max.toDouble(),
            divisions: max,
            onChanged: onChanged,
          ),
        ),
      );
    });
  }
}
