import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'power_up_local_storage.dart';
import 'power_up_pool.dart';

class ItemSliderList extends StatelessWidget {
  const ItemSliderList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var powerUpPool = context.read<PowerUpPool>();
    double titleWidth = powerUpPool.getTextWidthMax(context);
    List<Widget> itemSliderTileList = [];
    var basicItemList = context.watch<PowerUpLocalStorage>().itemInfosRaw.keys;
    context.watch<PowerUpLocalStorage>().itemInfos.forEach(
      (key, value) {
        itemSliderTileList.add(
          ItemSliderTile(
            itemName: key,
            titleWidth: titleWidth,
            removable: !basicItemList.contains(key),
          ),
        );
      },
    );

    ScrollController _scrollController = ScrollController();

    return Column(
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('뱀파이어 서바이버 0.3.1h 기준 (22.03.22.)'),
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('최소'),
              onPressed: () {
                powerUpPool.setMinAll();
                powerUpPool.saveSliderValue();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: const Text('최대'),
                onPressed: () {
                  powerUpPool.setMaxAll();
                  powerUpPool.saveSliderValue();
                },
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: itemSliderTileList,
          ),
        ),
        SizedBox(
          height: 50,
          child: FractionallySizedBox(
            widthFactor: 1,
            child: OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AddPowerUpDialog(ancestorContext: context),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}

class ItemSliderTile extends StatelessWidget {
  const ItemSliderTile(
      {Key? key,
      required this.itemName,
      required this.titleWidth,
      this.removable = false})
      : super(key: key);
  final String itemName;
  final double titleWidth;
  final bool removable;

  @override
  Widget build(BuildContext context) {
    SliderComponentShape trackShape =
        SliderTheme.of(context).overlayShape ?? const RoundSliderOverlayShape();
    Size iconSize = trackShape.getPreferredSize(true, true);
    var itemInfo = context.watch<PowerUpLocalStorage>().itemInfos[itemName]!;
    return Row(
      children: [
        SizedBox.fromSize(
          size: iconSize,
          child: itemInfo.figure,
        ),
        const SizedBox(width: 8.0),
        SizedBox(
          width: titleWidth,
          child: Text(itemName, style: Theme.of(context).textTheme.headline6),
        ),
        Expanded(
          child: EvenlyDividedSlider(
            value: context
                .select<PowerUpPool, int>((value) => value.powerUps[itemName]!),
            max: itemInfo.maxLevel,
            divisions: max(5, itemInfo.maxLevel),
            onChanged: (value) =>
                context.read<PowerUpPool>().setValue(itemName, value),
            onChangedEnd: (value) =>
                context.read<PowerUpPool>().saveSliderValue(),
          ),
        ),
        if (removable)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                context.read<PowerUpPool>().removeExtraPowerUp(itemName),
          )
      ],
    );
  }
}

class EvenlyDividedSlider extends StatelessWidget {
  const EvenlyDividedSlider({
    Key? key,
    required this.value,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.onChangedEnd,
  })  : assert(max <= divisions),
        super(key: key);
  final int value;
  final int max;
  final int divisions;
  final void Function(int)? onChanged;
  final void Function(int)? onChangedEnd;

  @override
  Widget build(BuildContext context) {
    SliderComponentShape trackShape =
        SliderTheme.of(context).overlayShape ?? const RoundSliderOverlayShape();
    double trackShapeRadiusWidth =
        trackShape.getPreferredSize(true, true).width;
    return LayoutBuilder(builder: (context, constraints) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width:
              (constraints.maxWidth - trackShapeRadiusWidth) * max / divisions +
                  trackShapeRadiusWidth,
          child: Slider(
            label: value.toString(),
            value: value.toDouble(),
            max: max.toDouble(),
            divisions: max,
            onChanged: onChanged != null
                ? (double value) => onChanged!(value.toInt())
                : null,
            onChangeEnd: onChangedEnd != null
                ? (double value) => onChangedEnd!(value.toInt())
                : null,
          ),
        ),
      );
    });
  }
}

class AddPowerUpDialog extends StatefulWidget {
  const AddPowerUpDialog({Key? key, required this.ancestorContext})
      : super(key: key);
  final BuildContext ancestorContext;

  @override
  State<AddPowerUpDialog> createState() => _AddPowerUpDialogState();
}

class _AddPowerUpDialogState extends State<AddPowerUpDialog> {
  final formKey = GlobalKey<FormState>();
  String itemName = '';
  int itemPrice = 0;
  int itemMaxLevel = 0;

  @override
  Widget build(BuildContext context) {
    int randomNumber = Random().nextInt(0x1FD3);
    late int codePoint;
    if (randomNumber < 0x1900) {
      codePoint = 0xe000 + randomNumber;
    } else {
      codePoint = 0xf0000 + randomNumber - 0x1900;
    }
    IconData iconData = IconData(codePoint, fontFamily: 'MaterialIcons');
    int extraNum = 1;
    while (widget.ancestorContext
            .read<PowerUpLocalStorage>()
            .itemInfos['Extra' + extraNum.toString()] !=
        null) {
      ++extraNum;
    }
    return AlertDialog(
      title: const Text('파워업 추가'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(child: Text('찾는 파워업이 없는 경우 직접 추가하여 계산할 수 있습니다.')),
          Flexible(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.abc),
                        labelText: '파워업 이름',
                      ),
                      initialValue: 'Extra' + extraNum.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력하세요.';
                        }
                        if (widget.ancestorContext
                                .read<PowerUpLocalStorage>()
                                .itemInfos[value] !=
                            null) {
                          return '이미 사용 중입니다.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        itemName = value!;
                      },
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.attach_money),
                        hintText: '모든 파워업을 환불한 기준 가격',
                        labelText: '파워업 가격 *',
                      ),
                      controller: TextEditingController(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '값을 입력하세요.';
                        }
                        int? num = int.tryParse(value, radix: 10);
                        if (num == null || num <= 0) {
                          return '0보다 큰 수를 입력하세요.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        itemPrice = int.parse(value!, radix: 10);
                      },
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.upgrade),
                        labelText: '최대 레벨 *',
                      ),
                      controller: TextEditingController(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '값을 입력하세요.';
                        }
                        int? num = int.tryParse(value, radix: 10);
                        if (num == null || num <= 0) {
                          return '0보다 큰 수를 입력하세요.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        itemMaxLevel = int.parse(value!, radix: 10);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            final isValid = formKey.currentState!.validate();
            if (isValid) {
              formKey.currentState!.save();
              ExtraItemInfo value = ExtraItemInfo(
                price: itemPrice,
                maxLevel: itemMaxLevel,
                icon: iconData,
              );
              widget.ancestorContext
                  .read<PowerUpLocalStorage>()
                  .addItemInfos(itemName, value);
              widget.ancestorContext
                  .read<PowerUpLocalStorage>()
                  .saveItemInfos();
              Navigator.pop(context);
            }
          },
          child: const Text('추가'),
        ),
      ],
    );
  }
}
