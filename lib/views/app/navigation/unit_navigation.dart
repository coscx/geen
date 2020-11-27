import 'package:flt_im_plugin/flt_im_plugin.dart';
import 'package:flt_im_plugin/value_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unit/app/res/cons.dart';
import 'package:flutter_unit/app/router.dart';
import 'package:flutter_unit/blocs/bloc_exp.dart';
import 'package:flutter_unit/components/permanent/overlay_tool_wrapper.dart';
import 'package:flutter_unit/views/app/navigation/unit_bottom_bar.dart';
import 'package:flutter_unit/views/pages/category/collect_page.dart';
import 'package:flutter_unit/views/pages/category/home_right_drawer.dart';
import 'package:flutter_unit/views/pages/chat/conversation_list.dart';
import 'package:flutter_unit/views/pages/chat/view/util/ImMessage.dart';
import 'package:flutter_unit/views/pages/home/home_drawer.dart';
import 'package:flutter_unit/views/pages/home/home_page.dart';


/// 说明: 主题结构 左右滑页 + 底部导航栏

class UnitNavigation extends StatefulWidget {
  @override
  _UnitNavigationState createState() => _UnitNavigationState();
}

class _UnitNavigationState extends State<UnitNavigation> {
  PageController _controller; //页面控制器，初始0
  //List<Conversion> conversions = [];
  FltImPlugin im = FltImPlugin();
  String tfSender;
  @override
  void initState() {
    super.initState();
    FltImPlugin().init(host: "mm.3dsqq.com", apiURL: "http://mm.3dsqq.com:8000");
    _controller = PageController();
    tfSender = ValueUtil.toStr(1);
    login(success: () {

    });
    listenNative();
    BlocProvider.of<ChatBloc>(context).add(EventNewMessage(null));
  }

  @override
  void dispose() {
    _controller.dispose(); //释放控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {

        final Color color =  BlocProvider.of<HomeBloc>(context).activeHomeColor;


        return Scaffold(
          drawer: HomeDrawer(),
          //左滑页
          endDrawer: HomeRightDrawer(),
          //右滑页
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildSearchButton(color),
          body: wrapOverlayTool(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              children: <Widget>[
                HomePage(),
                CollectPage(),
                ImConversationListPage(),
                CollectPage(),

              ],
            ),
          ),
          bottomNavigationBar: UnitBottomBar(
              color: color,
              itemData: Cons.ICONS_MAP,
              onItemClick: _onTapNav));
      },
    );
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
  listenNative() {
    im.onBroadcast.listen((event) {
      NativeResponse response = NativeResponse.fromMap(event);
      Map data = response.data;
      String type = ValueUtil.toStr(data['type']);
      var result = data['result'];
      if (response.code == 0) {
         if (type == 'onNewMessage') {
          //loadConversions();
           int error = ValueUtil.toInt(data['error']);
           onNewMessage(result, error);
        } else if (type == 'onSystemMessage') {
          //loadConversions();
        } else if (type == 'onPeerMessageACK') {
          int error = ValueUtil.toInt(data['error']);
          onPeerMessageACK(result, error);
        } else if (type == 'onPeerMessage') {
          onPeerMessage(result);
        } else if (type == 'onPeerSecretMessage') {
          onPeerSecretMessage(result);
        } else if (type == 'onImageUploadSuccess') {
          String url = ValueUtil.toStr(data['URL']);
          onImageUploadSuccess(result, url);
        } else if (type == 'onAudioDownloadSuccess') {
          onAudioDownloadSuccess(result);
        } else if (type == 'onAudioDownloadFail') {
          onAudioDownloadFail(result);
        } else if (type == 'onPeerMessageFailure') {
          onPeerMessageFailure(result);
        } else if (type == 'onAudioUploadSuccess') {
          String url = ValueUtil.toStr(data['URL']);
          onAudioUploadSuccess(result, url);
        } else if (type == 'onAudioUploadFail') {
          onAudioUploadFail(result);
        } else if (type == 'onImageUploadFail') {
          onImageUploadFail(result);
        } else if (type == 'onVideoUploadSuccess') {
          String url = ValueUtil.toStr(data['URL']);
          String thumbnailURL = ValueUtil.toStr(data['thumbnailURL']);
          onVideoUploadSuccess(result, url, thumbnailURL);
        } else if (type == 'onVideoUploadFail') {
          onVideoUploadFail(result);
        } else {
          print(result);
        }
      } else {
        print(response.message);
      }
    });
  }
  // OverlayToolWrapper 在此 添加 因为Builder外层: 因为需要 Scaffold 的上下文，打开左右滑页
  Widget wrapOverlayTool({Widget child}) {
    return Builder(
        builder: (ctx) => OverlayToolWrapper(
              child: child,
            ));
  }

  Widget _buildSearchButton(Color color) {
    return FloatingActionButton(
      elevation: 2,
      backgroundColor: color,
      child: const Icon(Icons.wc),
      onPressed: () => Navigator.of(context).pushNamed(UnitRouter.search),
    );
  }

  _onTapNav(int index) {
    _controller.jumpToPage(index);
    if (index == 1) {
      //BlocProvider.of<CollectBloc>(context).add(EventSetCollectData());
    }
  }

  void onPeerMessageACK(result, int error) {
    //BlocProvider.of<PeerBloc>(context).add(EventReceiveNewMessageAck(Map<String, dynamic>.from(result)));
  }
  onPeerMessageFailure(Map result) {
    // IMMessage
  }

  /// OutboxObserver
  onImageUploadSuccess(Map result, String url) {
    ///IMessage
  }
  onAudioUploadSuccess(Map result, String url) {
    /// IMessage
  }
  onAudioUploadFail(Map result) {
    //IMessage
  }
  onImageUploadFail(Map result) {
    // IMessage
  }
  onVideoUploadSuccess(Map result, url, thumbnailURL) {}
  onVideoUploadFail(Map result) {}

  /// AudioDownloaderObserver
  onAudioDownloadSuccess(Map result) {
    // IMessage
  }
  onAudioDownloadFail(Map result) {
    //IMessage
  }

  void onPeerMessage(result) {
    BlocProvider.of<PeerBloc>(context).add(EventReceiveNewMessage(Map<String, dynamic>.from(result)));
  }

  void onPeerSecretMessage(result) {

  }

  void onNewMessage(result, int error) {
    BlocProvider.of<ChatBloc>(context).add(EventNewMessage(result));
  }
}
