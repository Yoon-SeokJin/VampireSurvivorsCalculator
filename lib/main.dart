import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import 'package:yaml/yaml.dart';
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
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    const String title = '뱀서 파워업 순서 계산기';
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          analytics.logAppOpen();
          return MaterialApp(
            navigatorObservers: [observer],
            title: title,
            home: const MyHomePage(),
          );
        }
        if (snapshot.hasError) {
          return const MaterialApp(
            title: title,
            home: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: LoadFailed(),
              ),
            ),
          );
        }
        return const MaterialApp(
          title: title,
          home: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(),
            ),
          ),
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
          Text('불러오지 못했습니다.', style: Theme.of(context).textTheme.headline4),
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

  @override
  Widget build(BuildContext context) {
    const String info = '뱀파이어 서바이버에서는 파워업 한 횟수에 따라 10퍼센트의 추가비용이 붙습니다.\n'
        '때문에 같은 스펙의 파워업을 하더라도 파워업의 순서에 따라 총 비용이 달라집니다.\n'
        '이 계산기는 하고자 하는 파워업을 입력하면 가장 저렴한 순서를 계산해줍니다.';
    LocalStorage storage = LocalStorage('PowerUps');
    Future<String> itemInfosRaw = rootBundle.loadString('lib/item_infos.yaml');
    late YamlMap itemInfos;
    itemInfosRaw.then((value) => itemInfos = loadYaml(value));
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('뱀파이어 서바이버 파워업 순서 계산기'),
            const SizedBox(width: 5),
            Tooltip(
              child: const Icon(Icons.info),
              richMessage: TextSpan(
                text: info,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .apply(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
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
                    create: (context) =>
                        PowerUpPool(context.read<PowerUpLocalStorage>()),
                    update: (context, powerUpLocalStorage, _) =>
                        PowerUpPool(powerUpLocalStorage)),
                ChangeNotifierProxyProvider<PowerUpPool, PowerUpCalculator>(
                  create: (context) =>
                      PowerUpCalculator(context.read<PowerUpPool>()),
                  update: (context, powerUpPool, _) =>
                      PowerUpCalculator(powerUpPool),
                ),
              ],
              child: const PowerUpPage(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: LoadFailed(),
              ),
            );
          }
          return const Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
