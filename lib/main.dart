import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vampire_survivors_calculator/ui/power_up_calculator/power_up_calculator_page.dart';
import 'package:vampire_survivors_calculator/ui/widget/load_failed.dart';
import 'package:vampire_survivors_calculator/ui/widget/loading.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    const String title = 'vampire survivors calculator';
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        Widget? home;
        List<NavigatorObserver> navigatorObservers = [];
        if (snapshot.connectionState == ConnectionState.done) {
          home = const PowerUpCalculatorPage();
          navigatorObservers.add(observer);
          analytics.logAppOpen();
        } else if (snapshot.hasError) {
          home = const LoadFailed(dimension: 400);
        }
        return MaterialApp(
          //locale: const Locale('en'),
          navigatorObservers: navigatorObservers,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: title,
          home: home ?? const Loading(dimension: 100),
        );
      },
    );
  }
}
