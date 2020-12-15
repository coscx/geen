
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomSheet extends StatefulWidget {
  @override
  _BottomSheetState createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: Container(

        ),
        onTap: (){
          showBottomPop(context);
        },
      ),
    );
  }
}
 showBottomPop(BuildContext context) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true, //可滚动 解除showModalBottomSheet最大显示屏幕一半的限制
      shape: RoundedRectangleBorder(
        //圆角
        //borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return AnimatedPadding(
          //showModalBottomSheet 键盘弹出时自适应
          padding: MediaQuery.of(context).viewInsets, //边距（必要）
          duration: const Duration(milliseconds: 100), //时常 （必要）
          child: Container(
             height: 1080,
            constraints: BoxConstraints(
              minHeight: 90, //设置最小高度（必要）
              maxHeight: MediaQuery.of(context).size.height / 1, //设置最大高度（必要）
            ),
            padding: EdgeInsets.only(top: 34, bottom: 48),
            decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(30)), color: Colors.white), //圆角
            child:

                ListView(
                  shrinkWrap: true, //防止状态溢出 自适应大小
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: <Widget>[
                        //widget组件
                        Container(
                          height: 50,
                          child: Text("123"),
                        ),

                        Container(
                          height: 50,
                          child: Text("456"),
                        ),
                        Container(
                          height: 50,
                          child: Text("789"),
                        ),

                        ListView(
                          shrinkWrap: true, //防止状态溢出 自适应大小
                          children: <Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: <Widget>[
                                //widget组件
                                Container(
                                  height: 50,
                                  child: Text("1111"),
                                ),

                                Container(
                                  height: 50,
                                  child: Text("2222"),
                                ),
                                Container(
                                  height: 50,
                                  child: Text("3333"),
                                ),
                                Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ), Container(
                                  height: 50,
                                  child: Text("2222"),
                                ),

                              ],
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),


          ),
        );
      });
}