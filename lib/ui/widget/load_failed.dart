import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
