import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'power_up_local_storage.dart';
import 'power_up_pool.dart';
import 'power_up_calculator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultPanel extends StatelessWidget {
  const ResultPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Result> results = context.watch<PowerUpCalculator>().getResult;
    var itemInfos = context.watch<PowerUpLocalStorage>().itemInfos;
    late Widget displayResult;

    if (context.watch<PowerUpPool>().showDetail) {
      displayResult = Flexible(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: DataTable(
              columns: [
                DataColumn(
                    label: Text(AppLocalizations.of(context)!.dataTableOrder),
                    numeric: true),
                DataColumn(
                    label: Text(AppLocalizations.of(context)!.dataTableIcon)),
                DataColumn(
                    label: Text(AppLocalizations.of(context)!.dataTableLevel),
                    numeric: true),
                DataColumn(
                    label: Text(AppLocalizations.of(context)!.dataTableName)),
                DataColumn(
                    label: Text(AppLocalizations.of(context)!.dataTableCost),
                    numeric: true),
                DataColumn(
                    label:
                        Text(AppLocalizations.of(context)!.dataTableAccumulate),
                    numeric: true),
              ],
              rows: [
                for (Result result in results)
                  DataRow(
                    cells: [
                      DataCell(
                        Text((result.order ?? '').toString(),
                            style: Theme.of(context).textTheme.headline6),
                      ),
                      DataCell(
                        SizedBox(
                          width:
                              Theme.of(context).dataTableTheme.dataRowHeight ??
                                  kMinInteractiveDimension,
                          height:
                              Theme.of(context).dataTableTheme.dataRowHeight ??
                                  kMinInteractiveDimension,
                          child: context
                              .watch<PowerUpLocalStorage>()
                              .itemInfos[result.name]!
                              .figure,
                        ),
                      ),
                      DataCell(
                        Text(
                            context
                                .watch<PowerUpPool>()
                                .powerUps[result.name]!
                                .toString(),
                            style: Theme.of(context).textTheme.headline6),
                      ),
                      DataCell(
                        Text(
                            itemInfos[result.name] is ItemInfo
                                ? AppLocalizations.of(context)!.powerUpName(
                                    (itemInfos[result.name] as ItemInfo).id)
                                : result.name,
                            style: Theme.of(context).textTheme.headline6),
                      ),
                      DataCell(
                        Text(result.cost.toString(),
                            style: Theme.of(context).textTheme.headline6),
                      ),
                      DataCell(
                        Text(result.costAccumulate.toString(),
                            style: Theme.of(context).textTheme.headline6),
                      ),
                    ],
                  )
              ],
            ),
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
                  figure: context
                      .watch<PowerUpLocalStorage>()
                      .itemInfos[result.name]!
                      .figure,
                  level: context.watch<PowerUpPool>().powerUps[result.name]!,
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
              value: context.watch<PowerUpPool>().showDetail,
              onChanged: (bool newValue) {
                context.read<PowerUpPool>().showDetail = newValue;
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
              width: (Theme.of(context).dataTableTheme.dataRowHeight ??
                      kMinInteractiveDimension) *
                  1.5,
              height: (Theme.of(context).dataTableTheme.dataRowHeight ??
                      kMinInteractiveDimension) *
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
