import 'package:flutter/material.dart';

/// create by GUGU Team on 2020/4/30
/// contact me by email 1981462002@qq.com
/// 说明: 

//    {
//      "widgetId": 94,
//      "name": 'Flex水平方向顺序',
//      "priority": 5,
//      "subtitle":
//          "【textDirection】 : 水平方向顺序   【TextDirection】",
//    }
class TextDirectionFlex extends StatelessWidget {

  final  redBox= Container(
    color: Colors.red,
    height: 30,
    width: 40,
  );

  final blueBox= Container(
    color: Colors.blue,
    height: 20,
    width: 30,
  );

  final greenBox= Container(
    color: Colors.green,
    height: 20,
    width: 20,
  );

  @override
  Widget build(BuildContext context) {
    return Wrap(
        runSpacing: 5,
        children: TextDirection.values
            .map((mode) => Column(children: <Widget>[
          Container(
              margin: EdgeInsets.all(5),
              width: 160,
              height: 80,
              color: Colors.grey.withAlpha(33),
              child: _buildItem(mode)),
          Text(mode.toString().split('.')[1])
        ]))
            .toList());
  }

  _buildItem(mode) => Flex(
    direction: Axis.horizontal,
    textDirection: mode,
    children: <Widget>[
      blueBox, redBox, greenBox
    ],
  );
}