import 'package:flutter/material.dart';

Container StandardTextField(hintText, width, onChanged(value)) {
  return Container(
    width: width,
    height: 30,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
        right: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
        left: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
        bottom: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
      ),
    ),
    child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
            hintStyle: TextStyle(fontSize: 20),
            hintText: hintText,
            contentPadding:
                EdgeInsets.symmetric(vertical: 7, horizontal: 2.0))),
  );
}

class StandaloneText extends StatelessWidget {
  String text;
  Color color;
  FontWeight fontWeight;
  double fontSize;
  StandaloneText(this.text, [this.color, this.fontSize, this.fontWeight]);

  @override
  Widget build(BuildContext context) {
    if (fontSize == null) {
      fontSize = 20;
    }
    print(fontSize);
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Text(text,
          overflow: TextOverflow.visible,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          )),
    );
  }
}
