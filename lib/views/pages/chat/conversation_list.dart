import 'package:flt_im_plugin/flt_im_plugin.dart';
import 'package:flt_im_plugin/value_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:badges/badges.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unit/blocs/chat/chat_bloc.dart';
import 'package:flutter_unit/blocs/chat/chat_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flt_im_plugin/flt_im_plugin.dart';
import 'package:flt_im_plugin/conversion.dart';

/*
 * 聊天了列表界面，目前是只加载最新的20条，有下拉刷新。
 */
class ImConversationListPage extends StatelessWidget{


  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  int _offset = 0;
  int _limit = 10; //一次加载10条数据,不建议加载太多。

  //只有下拉刷新，上拉加载leancloud有些问题
  void _onRefresh() async {
    _offset = 0;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: imRefreshHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: BlocBuilder<ChatBloc, ChatState>(builder: _buildContent),
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

  Widget _buildContent(BuildContext context, ChatState state) {
    if (state is ChatMessageSuccess) {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: state.message.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
                onTap: () {

                },
                child: _buildListItem(state.message[index]));
          });

    }

    return
       Container();
  }
}
