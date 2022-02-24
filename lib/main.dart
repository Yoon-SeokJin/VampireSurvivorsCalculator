import 'dart:collection';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'item_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '뱀서 파워업 순서 계산기',
      home: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const MyHomePage();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('뱀파이어 서바이버 파워업 순서 계산기'),
      ),
      body: const PowerUpPage(),
    );
  }
}

class PowerUpPage extends StatefulWidget {
  const PowerUpPage({Key? key}) : super(key: key);

  @override
  _PowerUpPageState createState() => _PowerUpPageState();
}

class _PowerUpPageState extends State<PowerUpPage> {
  @override
  Widget build(BuildContext context) {
    return const ResultPanel();
  }
}

class ResultPanel extends StatefulWidget {
  const ResultPanel({
    Key? key,
  }) : super(key: key);
  @override
  State<ResultPanel> createState() => _ResultPanelState();
}

class _ResultPanelState extends State<ResultPanel> {
  int getPriceOneItem(ItemInfo item, {int idx = 0}) {
    int price = 0;
    for (int i = 0; i < item.currentLevel; ++i) {
      price += item.price * (i + 1) * (idx + 10) ~/ 10;
      ++idx;
    }
    return price;
  }

  int getPrice(List<String> order) {
    int price = 0, idx = 0;
    for (String name in order) {
      price += getPriceOneItem(itemInfo[name]!, idx: idx);
      idx += itemInfo[name]!.currentLevel;
    }
    return price;
  }

  int getInflation(ItemInfo item) {
    return item.price * item.currentLevel * (item.currentLevel + 1) ~/ 20;
  }

  int cost = 0;
  List<String> order = [];

  void _calculateOrder() {
    setState(() {
      List<String> itemNames = [
        for (String e in itemInfo.keys)
          if (itemInfo[e]!.currentLevel > 0) e
      ];
      Map<String, List<String>> topology = {for (String e in itemNames) e: []};
      Map<String, int> indegree = {for (String e in itemNames) e: 0};
      for (String i in itemNames) {
        for (String j in itemNames) {
          if (i != j &&
              itemInfo[i]!.currentLevel > 0 &&
              itemInfo[j]!.currentLevel > 0) {
            int di = getInflation(itemInfo[i]!) * itemInfo[j]!.currentLevel;
            int dj = getInflation(itemInfo[j]!) * itemInfo[i]!.currentLevel;
            if (di > dj) {
              topology[i]!.add(j);
              indegree[j] = indegree[j]! + 1;
            }
          }
        }
      }
      order = [];
      Queue<String> q = Queue();
      for (String key in itemNames) {
        if (indegree[key]! == 0) {
          q.add(key);
        }
      }
      while (q.isNotEmpty) {
        String e = q.first;
        q.removeFirst();
        order.add(e);
        for (String i in topology[e]!) {
          indegree[i] = indegree[i]! - 1;
          if (indegree[i]! == 0) {
            q.add(i);
          }
        }
      }
      cost = getPrice(order);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> itemSliderTileList = <Widget>[];
    itemInfo.forEach((key, _) {
      itemSliderTileList.add(ItemSliderTile(
        itemName: key,
        callBack: _calculateOrder,
      ));
    });
    return Row(
      children: [
        SizedBox(
          width: 600,
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 5),
                  Text('원하는 파워업', style: Theme.of(context).textTheme.headline5),
                  Expanded(child: Container()),
                  OutlinedButton(
                    child: const Text('최소'),
                    onPressed: () {
                      setState(() {
                        itemInfo.forEach((key, value) {
                          value.currentLevel = 0;
                        });
                        _calculateOrder();
                      });
                    },
                  ),
                  const SizedBox(width: 5),
                  OutlinedButton(
                    child: const Text('최대'),
                    onPressed: () {
                      setState(() {
                        itemInfo.forEach((key, value) {
                          value.currentLevel = value.maxLevel;
                        });
                        _calculateOrder();
                      });
                    },
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              Expanded(child: ListView(children: itemSliderTileList)),
            ],
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Column(
            children: [
              Text('총 비용: $cost', style: Theme.of(context).textTheme.headline5),
              Text('파워업 순서', style: Theme.of(context).textTheme.headline5),
              Expanded(
                child: Wrap(
                  children: [
                    for (int i = 0; i < order.length; ++i)
                      Stack(
                        children: [
                          Image.asset(itemInfo[order[i]]!.imagePath,
                              filterQuality: FilterQuality.none, scale: 1 / 4),
                          Text((i + 1).toString(),
                              style: TextStyle(
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 3
                                    ..color = Colors.black)),
                          Text((i + 1).toString(),
                              style: const TextStyle(color: Colors.white))
                        ],
                      )
                  ],
                ),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ],
    );
  }
}

class ItemSliderTile extends StatefulWidget {
  const ItemSliderTile(
      {Key? key, required this.itemName, required this.callBack})
      : super(key: key);
  final String itemName;
  final Function callBack;

  @override
  _ItemSliderTileState createState() => _ItemSliderTileState();
}

class _ItemSliderTileState extends State<ItemSliderTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(
        itemInfo[widget.itemName]!.imagePath,
        filterQuality: FilterQuality.none,
        scale: 0.1,
      ),
      title:
          Text(widget.itemName, style: Theme.of(context).textTheme.headline6),
      trailing: SizedBox(
        width: 300,
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: itemInfo[widget.itemName]!.currentLevel.toDouble(),
                max: itemInfo[widget.itemName]!.maxLevel.toDouble(),
                divisions: itemInfo[widget.itemName]!.maxLevel,
                onChanged: (double value) {
                  setState(() {
                    itemInfo[widget.itemName]!.currentLevel = value.toInt();
                  });
                  widget.callBack();
                },
              ),
            ),
            Text(itemInfo[widget.itemName]!.currentLevel.toString(),
                style: Theme.of(context).textTheme.headline6)
          ],
        ),
      ),
    );
  }
}
