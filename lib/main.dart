import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'power_up_page.dart';
import 'power_up_pool.dart';
import 'power_up_calculator.dart';
import 'power_up_local_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    const String title = 'vampire survivors calculator';

    const Widget loadFailed = Center(
      child: SizedBox.square(
        dimension: 400,
        child: LoadFailed(),
      ),
    );

    const Widget progressIndicator = Center(
      child: SizedBox.square(
        dimension: 100,
        child: CircularProgressIndicator(),
      ),
    );

    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        Widget home = progressIndicator;
        List<NavigatorObserver> navigatorObservers = [];
        if (snapshot.connectionState == ConnectionState.done) {
          home = const MyHomePage();
          navigatorObservers.add(observer);
          analytics.logAppOpen();
        } else if (snapshot.hasError) {
          home = loadFailed;
        }
        return MaterialApp(
          navigatorObservers: navigatorObservers,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          //locale: const Locale('en'),
          title: title,
          home: home,
        );
      },
    );
  }
}

class LoadFailed extends StatelessWidget {
  const LoadFailed({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        children: [
          const Icon(Icons.sms_failed_outlined, size: 100),
          Text(AppLocalizations.of(context)!.loadFailed,
              style: Theme.of(context).textTheme.headline4),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  Future<YamlMap> loadItemInfo() async {
    String itemInfosRaw = await rootBundle.loadString('lib/item_infos.yaml');
    return loadYaml(itemInfosRaw);
  }

  @override
  Widget build(BuildContext context) {
    print(Localizations.localeOf(context));

    const Widget loadFailed = Center(
      child: SizedBox.square(
        dimension: 400,
        child: LoadFailed(),
      ),
    );

    const Widget progressIndicator = Center(
      child: SizedBox.square(
        dimension: 100,
        child: CircularProgressIndicator(),
      ),
    );

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
        ],
      ),
    );

    LocalStorage storage = LocalStorage('PowerUps');
    Future<String> itemInfosRaw = rootBundle.loadString('lib/item_infos.yaml');
    late YamlMap itemInfos;
    itemInfosRaw.then((value) => itemInfos = loadYaml(value));
    return Scaffold(
      appBar: appBar,
      body: FutureBuilder(
        future: Future.wait([
          storage.ready,
          itemInfosRaw,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<PowerUpLocalStorage>(
                    create: (_) => PowerUpLocalStorage(storage, itemInfos)),
                ChangeNotifierProxyProvider<PowerUpLocalStorage, PowerUpPool>(
                    create: (context) => PowerUpPool(context.read<PowerUpLocalStorage>()),
                    update: (context, powerUpLocalStorage, _) => PowerUpPool(powerUpLocalStorage)),
                ChangeNotifierProxyProvider<PowerUpPool, PowerUpCalculator>(
                  create: (context) => PowerUpCalculator(context.read<PowerUpPool>()),
                  update: (context, powerUpPool, _) => PowerUpCalculator(powerUpPool),
                ),
              ],
              child: const PowerUpPage(),
            );
          }
          if (snapshot.hasError) {
            return loadFailed;
          }
          return progressIndicator;
        },
      ),
    );
  }
}
