import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'power_up_calculator_viewmodel.dart';
import '../widget/power_up_info_icon.dart';

class PowerUpResultView extends StatelessWidget {
  const PowerUpResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('result panel rebuilt');
    final vmWatch = context.watch<PowerUpCalculatorViewmodel>();
    final vmRead = context.read<PowerUpCalculatorViewmodel>();
    final resultList = vmWatch.getResult(context);
    late Widget displayResult;
    if (vmWatch.showDetail) {
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
              for (final result in resultList)
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 0.5,
                        style: result.order != null ? BorderStyle.solid : BorderStyle.none,
                      ),
                    ),
                  ),
                  children: [
                    Text((result.order ?? '').toString(),
                        style: Theme.of(context).textTheme.headline6),
                    SizedBox.square(
                      dimension: 48.0,
                      child: result.figure,
                    ),
                    Text(result.level.toString(), style: Theme.of(context).textTheme.headline6),
                    Text(result.name.toString(), style: Theme.of(context).textTheme.headline6),
                    Text(result.cost.toString(), style: Theme.of(context).textTheme.headline6),
                    Text(result.costAcc.toString(), style: Theme.of(context).textTheme.headline6),
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
              for (final result in resultList)
                PowerUpInfoIcon(
                  figure: result.figure,
                  level: result.level,
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
                      ': ${resultList.isNotEmpty ? resultList.last.costAcc : 0}',
                  style: Theme.of(context).textTheme.headline5),
            ),
            const Spacer(),
            Text(AppLocalizations.of(context)!.details),
            Switch(
              value: vmWatch.showDetail,
              onChanged: (bool value) {
                vmRead.setShowDetail(value);
              },
            ),
          ],
        ),
        displayResult,
      ],
    );
  }
}
