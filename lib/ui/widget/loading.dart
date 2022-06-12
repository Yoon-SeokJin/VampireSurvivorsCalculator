import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({
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
