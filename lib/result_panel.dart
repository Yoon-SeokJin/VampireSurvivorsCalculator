import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'power_up_pool.dart';
import 'power_up_calculator.dart';

class ResultPanel extends StatelessWidget {
  const ResultPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('result panel rebuilt');
    List<Result> results = context.watch<PowerUpCalculator>().getResult;
    late Widget displayResult;
    if (context.watch<PowerUpPool>().showDetails) {
      displayResult = Expanded(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: IntrinsicColumnWidth(),
              2: IntrinsicColumnWidth(),
            },
            children: [
              TableRow(
                children: [
                  Text(AppLocalizations.of(context)!.dataTableOrder),
                  Text(AppLocalizations.of(context)!.dataTableIcon),
                  Text(AppLocalizations.of(context)!.dataTableLevel),
                  Text(AppLocalizations.of(context)!.dataTableName),
                  Text(AppLocalizations.of(context)!.dataTableCost),
                  Text(AppLocalizations.of(context)!.dataTableAccumulate),
                ]
                    .map((e) => Padding(
                          child: e,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        ))
                    .toList(),
              ),
              for (Result result in results)
                TableRow(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              width: 0.5,
                              style: result.order != null ? BorderStyle.solid : BorderStyle.none))),
                  children: [
                    Text((result.order ?? '').toString(),
                        style: Theme.of(context).textTheme.headline6),
                    SizedBox.square(
                      dimension: 48.0,
                      child: result.itemInfo.figure,
                    ),
                    Text(context.watch<PowerUpPool>().powerUps[result.itemInfo.id]!.toString(),
                        style: Theme.of(context).textTheme.headline6),
                    Text(result.itemInfo.getName(context),
                        style: Theme.of(context).textTheme.headline6),
                    Text(result.cost.toString(), style: Theme.of(context).textTheme.headline6),
                    Text(result.costAccumulate.toString(),
                        style: Theme.of(context).textTheme.headline6),
                  ]
                      .map((e) => Padding(
                            child: e,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      );
    } else {
      displayResult = Expanded(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Wrap(
            runSpacing: 30,
            children: [
              for (Result result in results)
                ItemInfoIcon(
                  figure: result.itemInfo.figure,
                  level: context.watch<PowerUpPool>().powerUps[result.itemInfo.id]!,
                  order: result.order,
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  AppLocalizations.of(context)!.totalCost +
                      ': ${results.isNotEmpty ? results.last.costAccumulate : 0}',
                  style: Theme.of(context).textTheme.headline5),
            ),
            const Spacer(),
            Text(AppLocalizations.of(context)!.details),
            Switch(
              value: context.watch<PowerUpPool>().showDetails,
              onChanged: (bool newValue) {
                context.read<PowerUpPool>().showDetails = newValue;
              },
            ),
          ],
        ),
        displayResult,
      ],
    );
  }
}

class ItemInfoIcon extends StatelessWidget {
  const ItemInfoIcon({
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
        Text(text,
            style: TextStyle(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Colors.black)),
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
