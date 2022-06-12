import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'add_power_up_dialog.dart';
import '../power_up_calculator/power_up_calculator_viewmodel.dart';

class PowerUpButtons extends StatelessWidget {
  const PowerUpButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vmRead = context.read<PowerUpCalculatorViewmodel>();
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AddPowerUpDialog(
              addPowerUpExtraCallBack: vmRead.addPowerUpExtra,
            ),
          ),
          child: Text(AppLocalizations.of(context)!.powerUpButtonAdd),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          child: Text(AppLocalizations.of(context)!.powerUpButtonMin),
          onPressed: () {
            vmRead.setPowerUpLevelAllMin();
            vmRead.savePowerUpLevel();
          },
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          child: Text(AppLocalizations.of(context)!.powerUpButtonMax),
          onPressed: () {
            vmRead.setPowerUpLevelAllMax();
            vmRead.savePowerUpLevel();
          },
        ),
      ],
    );
  }
}
