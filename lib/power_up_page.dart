import 'package:flutter/material.dart';
import 'power_up_pool.dart';
import 'item_slider_list.dart';
import 'result_panel.dart';
import 'package:provider/provider.dart';

class PowerUpPage extends StatelessWidget {
  const PowerUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 1200,
        child: LayoutBuilder(builder: ((context, constraints) {
          const itemSliderList = ItemSliderList();
          const resultPanel = ResultPanel();

          if (constraints.maxWidth < 800) {
            return Column(
              children: const [
                Expanded(child: itemSliderList),
                Expanded(child: resultPanel),
              ],
            );
          }
          context.watch<PowerUpPool>();
          return Row(
            children: const [
              SizedBox(width: 450, child: itemSliderList),
              Expanded(child: resultPanel),
            ],
          );
        })),
      ),
    );
  }
}
