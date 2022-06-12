import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GithubButton extends StatelessWidget {
  const GithubButton({Key? key}) : super(key: key);

  void _launchGithubUrl() async {
    Uri url = Uri.parse('https://github.com/Yoon-SeokJin/VampireSurvivorsCalculator');
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset('images/GitHub-Mark-32px.png'),
      onPressed: _launchGithubUrl,
    );
  }
}
