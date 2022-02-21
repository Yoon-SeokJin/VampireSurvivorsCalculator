import 'dart:collection';

import 'package:flutter/material.dart';

main() => runApp(const MyApp());

class ItemInfo {
  ItemInfo(
      {required this.price, required this.maxLevel, required this.imagePath});
  final int price;
  final int maxLevel;
  final String imagePath;
  int currentLevel = 0;
}

Map<String, ItemInfo> itemInfo = {
  'Might': ItemInfo(price: 200, maxLevel: 5, imagePath: 'images/Might.png'),
  'Armor': ItemInfo(price: 600, maxLevel: 3, imagePath: 'images/Armor.png'),
  'Max health':
      ItemInfo(price: 200, maxLevel: 3, imagePath: 'images/MaxHealth.png'),
  'Recovery':
      ItemInfo(price: 200, maxLevel: 5, imagePath: 'images/Recovery.png'),
  'Cool down':
      ItemInfo(price: 900, maxLevel: 2, imagePath: 'images/CoolDown.png'),
  'Area': ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/Area.png'),
  'Speed': ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/Speed.png'),
  'Duration':
      ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/Duration.png'),
  'Amount': ItemInfo(price: 5000, maxLevel: 1, imagePath: 'images/Amount.png'),
  'Move speed':
      ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/MoveSpeed.png'),
  'Magnet': ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/Magnet.png'),
  'Luck': ItemInfo(price: 600, maxLevel: 3, imagePath: 'images/Luck.png'),
  'Growth': ItemInfo(price: 900, maxLevel: 5, imagePath: 'images/Growth.png'),
  'Greed': ItemInfo(price: 200, maxLevel: 5, imagePath: 'images/Greed.png'),
  'Curse': ItemInfo(price: 1666, maxLevel: 5, imagePath: 'images/Curse.png'),
  'Revival':
      ItemInfo(price: 10000, maxLevel: 1, imagePath: 'images/Revival.png'),
  'Reroll': ItemInfo(price: 5000, maxLevel: 2, imagePath: 'images/Reroll.png'),
  'Skip': ItemInfo(price: 1000, maxLevel: 1, imagePath: 'images/Skip.png'),
};

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '뱀파이어 서바이버 파워업 순서 계산기',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('뱀파이어 서바이버 파워업 순서 계산기'),
        ),
        body: const ResultPanel(),
      ),
    );
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
      idx += itemInfo[name]!.maxLevel;
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
            int di = getInflation(itemInfo[i]!) * itemInfo[j]!.maxLevel;
            int dj = getInflation(itemInfo[j]!) * itemInfo[i]!.maxLevel;
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
    List<ItemSliderTile> itemSliderTileList = <ItemSliderTile>[];
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
                  )
                ],
              ),
              Expanded(child: ListView(children: itemSliderTileList)),
            ],
          ),
        ),
        const SizedBox(
          width: 100,
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
  final GlobalKey<_ItemSliderTileState> _itemSliderTileState =
      GlobalKey<_ItemSliderTileState>();
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
