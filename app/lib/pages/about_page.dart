import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: ListView(
            children: [
              Text('Flutter TCP Demo'),
              Text('created by Julian Aßmann (julianassmann.de)'),
              Text('created with Flutter')
            ],
          ),
        ),
      ),
    );
  }
}