import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  ResultsPage(this.resultPage);
  List<Widget> resultPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: resultPage,
      ),
    );
  }
}
