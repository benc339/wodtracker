import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'dart:io';

class NetworkHelper {
  NetworkHelper(this.url);

  final String url;

  Future getData() async {
    final response = await http.Client().get(Uri.parse(url));
    //print(response.body);
    print('before chemical');
    if (url.contains('chemicalcitycrossfit')) {
      print('chemical');

      var data = parse(response.body)
          .getElementsByClassName('wp-block-table is-style-stripes');

      String wodString;
      //print(wodString);
      wodString = data[0].innerHtml;

      var dataList = [];
      String strength;
      strength = wodString
          .split('Gross Strength</strong></td></tr><tr><td>')[1]
          .split('</td></tr><tr><td>')[0]
          .replaceAll('&nbsp;', " ");
      dataList.add('Gross Strength:');
      //strength = strength.replaceAll('&nbsp;', " ");
      dataList.add(strength);
      //print(strength);

      String wod = wodString
          .split('WOD&nbsp;</strong></td></tr><tr><td>')[1]
          .split('</td></tr></tbody></table>')[0];
      dataList.add('\nWOD:');
      for (String line in wod.split('<br>')) {
        //print(line);
        String editedLine = line.replaceAll('&nbsp;', ' ');
        dataList.add(editedLine);
      }

      return dataList;
    } else {
      print('cross');
      if (response.statusCode == 200) {
        var data = parse(response.body).getElementsByTagName("p");
        var dataList = [];
        for (var element in data) {
          //print(element.text);
          dataList.add(element.text);
          //print(dataList[0]);
        }
        return dataList;
      } else {
        print(response.statusCode);
      }
    }
  }
}
