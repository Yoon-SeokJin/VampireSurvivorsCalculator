import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'power_up_calculator_page_layout.dart';
import 'power_up_calculator_viewmodel.dart';
import '../widget/github_button.dart';
import '../widget/load_failed.dart';
import '../widget/loading.dart';

class PowerUpCalculatorPage extends StatelessWidget {
  const PowerUpCalculatorPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint(Localizations.localeOf(context).toString());

    PreferredSizeWidget appBar = AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.appBarTitle),
          const SizedBox(width: 5),
          Tooltip(
            child: const Icon(Icons.info),
            richMessage: TextSpan(
              text: AppLocalizations.of(context)!.calculatorInfo,
              style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.white),
            ),
          ),
          const GithubButton(),
        ],
      ),
    );

    final powerUpListViewmodel = PowerUpCalculatorViewmodel();
    return Scaffold(
      appBar: appBar,
      body: FutureBuilder(
        future: Future.wait([powerUpListViewmodel.ready]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ChangeNotifierProvider.value(
              value: powerUpListViewmodel,
              child: const PowerUpCalculatorPageLayout(),
            );
          }
          if (snapshot.hasError) {
            return const LoadFailed(dimension: 400);
          }
          return const Loading(dimension: 100);
        },
      ),
    );
  }
}
