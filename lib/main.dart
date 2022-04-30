import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'power_up_page.dart';
import 'power_up_pool.dart';
import 'power_up_calculator.dart';
import 'power_up_local_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
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
          home = const MyHomePage();
          navigatorObservers.add(observer);
          analytics.logAppOpen();
        } else if (snapshot.hasError) {
          home = const LoadFailed(dimension: 400);
        }
        return MaterialApp(
          navigatorObservers: navigatorObservers,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: title,
          home: home ?? const ProgressIndicator(dimension: 100),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  void _launchGithubUrl() async {
    Uri url = Uri.parse('https://github.com/Yoon-SeokJin/VampireSurvivorsCalculator');
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

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
          IconButton(
            icon: Image.asset('images/GitHub-Mark-32px.png'),
            onPressed: _launchGithubUrl,
          ),
        ],
      ),
    );

    LocalStorage storage = LocalStorage('PowerUps');
    Future<String> itemInfosYaml = rootBundle.loadString('lib/item_infos.yaml');
    late YamlList itemInfos;
    itemInfosYaml.then((value) => itemInfos = loadYaml(value));
    return Scaffold(
      appBar: appBar,
      body: FutureBuilder(
        future: Future.wait([
          storage.ready,
          itemInfosYaml,
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
            return const LoadFailed(dimension: 400);
          }
          return const ProgressIndicator(dimension: 100);
        },
      ),
    );
  }
}

class LoadFailed extends StatelessWidget {
  const LoadFailed({Key? key, this.dimension}) : super(key: key);

  final double? dimension;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: dimension,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Column(
            children: [
              const Icon(Icons.sms_failed_outlined, size: 100),
              Text(AppLocalizations.of(context)!.loadFailed,
                  style: Theme.of(context).textTheme.headline4),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator({
    Key? key,
    this.dimension,
  }) : super(key: key);

  final double? dimension;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: dimension,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
