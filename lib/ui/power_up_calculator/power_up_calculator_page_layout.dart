import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'power_up_list_view.dart';
import 'power_up_result_view.dart';
import 'power_up_calculator_viewmodel.dart';
import '../widget/power_up_buttons.dart';

class PowerUpCalculatorPageLayout extends StatelessWidget {
  const PowerUpCalculatorPageLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vmRead = context.read<PowerUpCalculatorViewmodel>();
    return Center(
      child: SizedBox(
        width: 1200,
        child: LayoutBuilder(
          builder: ((context, constraints) {
            const powerUpListView = PowerUpListView();
            const powerUpResultView = PowerUpResultView();
            final buttonInterface = Row(
              children: [
                Text(vmRead.getVersionInfoString(context)),
                const Spacer(),
                const PowerUpButtons(),
              ],
            );

            if (constraints.maxWidth < 800) {
              return Column(
                children: [
                  buttonInterface,
                  const Expanded(child: powerUpListView),
                  const Expanded(child: powerUpResultView),
                ],
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: 480,
                  child: Column(
                    children: [
                      buttonInterface,
                      const Expanded(child: powerUpListView),
                    ],
                  ),
                ),
                const Expanded(
                  child: powerUpResultView,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
