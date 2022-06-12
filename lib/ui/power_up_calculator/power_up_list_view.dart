import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'power_up_calculator_viewmodel.dart';
import '../widget/evenly_divided_slider.dart';
import '../../data/model/power_up.dart';

class PowerUpListView extends StatelessWidget {
  const PowerUpListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('item slider list rebuilt');
    final vmRead = context.read<PowerUpCalculatorViewmodel>();
    final vmWatch = context.watch<PowerUpCalculatorViewmodel>();
    List<TableRow> itemSliderTileList = [
      for (var e in vmWatch.powerUpList)
        TableRow(
          children: [
            SizedBox.fromSize(
              size: const Size.square(48.0),
              child: e.figure,
            ),
            Padding(
              child: Text(e.getName(context), style: Theme.of(context).textTheme.headline6),
              padding: const EdgeInsets.only(left: 8.0),
            ),
            EvenlyDividedSlider(
              value: context
                  .select<PowerUpCalculatorViewmodel, int?>((value) => value.powerUpLevel[e.id])!,
              max: e.maxLevel,
              divisions: e.maxLevel > 5 ? e.maxLevel : 5,
              onChanged: (value) => vmRead.setPowerUpLevel(e.id, value),
              onChangedEnd: (value) => vmRead.savePowerUpLevel(),
            ),
            if (e is PowerUpExtra)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => vmRead.removePowerUpExtra(e.id),
              )
            else
              const SizedBox.shrink(),
          ],
        )
    ];

    ScrollController _scrollController = ScrollController();
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth(),
                3: IntrinsicColumnWidth(),
              },
              children: itemSliderTileList,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            ),
          ),
        ),
      ],
    );
  }
}
