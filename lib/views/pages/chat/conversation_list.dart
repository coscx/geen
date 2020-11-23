import 'package:flt_im_plugin/flt_im_plugin.dart';
import 'package:flt_im_plugin/value_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:badges/badges.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flt_im_plugin/flt_im_plugin.dart';
import 'package:flt_im_plugin/conversion.dart';
class NativeResponse {
  int code;
  String message;
  var data;
  NativeResponse.fromMap(Map json) {
    code = ValueUtil.toInt(json['code']);
    message = ValueUtil.toStr(json['messsage']);
    data = json['data'];
  }
}
/*
 * 聊天了列表界面，目前是只加载最新的20条，有下拉刷新。 
 */
class ImConversationListPage extends StatefulWidget {
  final String title;
  ImConversationListPage({this.title = '最近联系人列表'});
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ImConversationListPage> {
  //List<ImConversation> _conversations = [];
  List<Conversion> conversions = [];
  FltImPlugin im = FltImPlugin();
  String tfSender;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int _offset = 0;
  int _limit = 10; //一次加载10条数据,不建议加载太多。

  //只有下拉刷新，上拉加载leancloud有些问题
  void _onRefresh() async {
    _offset = 0;
    //FlutterLcIm.queryHistoryConversations(_limit, _offset);
  }

  Widget imRefreshHeader() {
    return ClassicHeader(
      refreshingText: "加载中...",
      idleText: "加载最新会话",
      completeText: '加载完成',
      releaseText: '松开刷新数据',
      failedIcon: null,
      failedText: '刷新失败，请重试。',
    );
  }

  @override
  void initState() {
    super.initState();
    tfSender = ValueUtil.toStr(1);
    login(success: () {

    });

    listenNative();
    loadConversions();
    //FlutterLcIm.queryHistoryConversations(_limit, _offset);
  }

  login({void Function() success}) async {
    if (tfSender == null || tfSender.length == 0) {
      print('发送用户id 必须填写');
      return;
    }
    final res = await FltImPlugin().login(uid: tfSender);
    print(res);
    int code = ValueUtil.toInt(res['code']);
    if (code == 0) {
      success?.call();
      tfSender = null;

    } else {
      String message = ValueUtil.toStr(res['message']);
      print(message);
    }
  }
  loadConversions() async {
    Map response = await im.getConversations();
    print(response);
    conversions = ValueUtil.toArr(response["data"]).map((e) => Conversion.fromMap(ValueUtil.toMap(e))).toList();
    setState(() {

    });
  }

  deleteConversion(String cid) async {
    Map res = await im.deleteConversation(cid: cid);
    conversions.removeWhere((element) => element.cid == cid);

  }

  listenNative() {
    im.onBroadcast.listen((event) {
      NativeResponse response = NativeResponse.fromMap(event);
      Map data = response.data;
      String type = ValueUtil.toStr(data['type']);
      var result = data['result'];
      if (response.code == 0) {
        if (type == 'onPeerMessageACK') {
          int error = ValueUtil.toInt(data['error']);
        } else if (type == 'onNewMessage') {
          // 有新的消息
          loadConversions();
        } else if (type == 'onSystemMessage') {
          loadConversions();
        } else if (type == 'onPeerMessageACK') {
          loadConversions();
        } else {
          print(result);
        }
      } else {
        print(response.message);
      }
    });
  }

  addConversion(String receiverId, BuildContext context) {
    if (receiverId == null || receiverId.length == 0) {
      return;
    }
    Navigator.of(context).pushNamed('peer_page', arguments: {
      'currentUID': tfSender,
      'peerUID': receiverId,
    });
  }
  // void _loadData(List<ImConversation> conversations) {
  //   setState(() {
  //     if (conversations.length == 1) {
  //       //是否是更新未读消息的数据
  //       bool isUpdateUnreadMessage = false;
  //       for (var conversation in _conversations) {
  //         if (conversations[0].conversationId == conversation.conversationId) {
  //           conversation.unreadMessagesCount =
  //               conversations[0].unreadMessagesCount;
  //           conversation.lastMessage = conversations[0].lastMessage;
  //           isUpdateUnreadMessage = true;
  //           break;
  //         }
  //       }
  //       if (!isUpdateUnreadMessage) {
  //        // _conversations = conversations;
  //       }
  //     } else {
  //       //_conversations = conversations;
  //     }
  //     _refreshController.refreshCompleted();
  //   });
  //
  //   //根据用户id到自己的服务器上获取头像，然后更新UI
  //   List peerIds = List();
  //   for (var item in _conversations) {
  //     peerIds.add(item.peerId);
  //     // http request
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: conversions.length == 0
          ? SizedBox()
          : SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: imRefreshHeader(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: conversions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () {

                        },
                        child: _buildListItem(conversions[index]));
                  }),
            ),
    );
  }

  Widget _buildListItem(Conversion conversation) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              conversation.newMsgCount == 0
                  ? Container(
                      margin: EdgeInsets.only(left: 20, top: 7),
                      padding: EdgeInsets.all(10),
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6.0),
                        // image url 去要到自己的服务器上去请求回来再赋值，这里使用一张默认值即可
                        image: DecorationImage(
                            image: NetworkImage(conversation.avatarURL)),
                      ),
                    )
                  : Badge(
                      badgeContent: Text(
                        '${conversation.newMsgCount}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 20, top: 7),
                        padding: EdgeInsets.all(10),
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6.0),
                          // image url 去要到自己的服务器上去请求回来再赋值，这里使用一张默认值即可
                          image: DecorationImage(
                              image: NetworkImage(conversation.avatarURL)),
                        ),
                      ),
                    ),
              Container(
                margin: EdgeInsets.only(left: 6, top: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Text(
                        conversation.detail,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(maxWidth: 280),
                      margin: EdgeInsets.only(top: 8),
                      child: Text(conversation.message.rawContent,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(right: 14, bottom: 18),
            child: Text(conversation.timestamp.toString(),
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          )
        ],
      ),
    );
  }
}
