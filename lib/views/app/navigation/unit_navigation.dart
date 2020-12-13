import 'dart:math';

import 'package:flt_im_plugin/flt_im_plugin.dart';
import 'package:flt_im_plugin/value_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_unit/app/res/cons.dart';
import 'package:flutter_unit/app/router.dart';
import 'package:flutter_unit/blocs/bloc_exp.dart';
import 'package:flutter_unit/components/permanent/overlay_tool_wrapper.dart';
import 'package:flutter_unit/storage/dao/local_storage.dart';
import 'package:flutter_unit/views/app/navigation/unit_bottom_bar.dart';
import 'package:flutter_unit/views/pages/category/collect_page.dart';
import 'package:flutter_unit/views/pages/category/home_right_drawer.dart';
import 'package:flutter_unit/views/pages/chat/conversation_list.dart';
import 'package:flutter_unit/views/pages/chat/view/util/ImMessage.dart';
import 'package:flutter_unit/views/pages/data/big.dart';
import 'package:flutter_unit/views/pages/data/card.dart';
import 'package:flutter_unit/views/pages/data/info.dart';
import 'package:flutter_unit/views/pages/home/home_drawer.dart';
import 'package:flutter_unit/views/pages/home/home_page.dart';
import 'package:jpush_flutter/jpush_flutter.dart';


/// 说明: 主题结构 左右滑页 + 底部导航栏

class UnitNavigation extends StatefulWidget {
  @override
  _UnitNavigationState createState() => _UnitNavigationState();
}

class _UnitNavigationState extends State<UnitNavigation> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  PageController _controller; //页面控制器，初始0
  //List<Conversion> conversions = [];
  String debugLable = 'Unknown';
  FltImPlugin im = FltImPlugin();
  JPush jpush = new JPush();
  static String tfSender = "";
  @override
  void initState() {
    super.initState();
    FltImPlugin().init(host: "mm.3dsqq.com", apiURL: "http://mm.3dsqq.com:8000");
    _controller = PageController();
    tfSender = ValueUtil.toStr(2);
    Future.delayed(Duration(milliseconds: 500)).then((e) async {
      var ss = await LocalStorage.get("im_token");
      var memberId = await LocalStorage.get("memberId");
      if(memberId != "" && memberId != null){
        tfSender=memberId.toString();
      }
      if(ss !="" || ss != null){

        login(success: () {

        });

      }else{

        login(success: () {

        });
      }
      BlocProvider.of<ChatBloc>(context).add(EventNewMessage(null));
      BlocProvider.of<GlobalBloc>(context).add(EventSetMemberId(tfSender));



    });


    initPlatformState();
    listenNative();

  }
// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
            print("flutter onReceiveNotification: $message");
            setState(() {
               debugLable = "flutter onReceiveNotification: $message";
            });
          }, onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
        setState(() {
          debugLable = "flutter onOpenNotification: $message";
        });
      }, onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
        setState(() {
          debugLable = "flutter onReceiveMessage: $message";
        });
      }, onReceiveNotificationAuthorization:
          (Map<String, dynamic> message) async {
        print("flutter onReceiveNotificationAuthorization: $message");
        setState(() {
          debugLable = "flutter onReceiveNotificationAuthorization: $message";
        });
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    jpush.setup(
      appKey: "334db8731c1e38a9c7c3f512", //你自己应用的 AppKey
      channel: "theChannel",
      production: false,
      debug: true,
    );
    jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));

    // Platform messages may fail, so we use a try/catch PlatformException.
    jpush.getRegistrationID().then((rid) {
      print("flutter get registration id : $rid");
      setState(() {
        debugLable = "flutter getRegistrationID: $rid";
      });
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      debugLable = platformVersion;
    });
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
        final String id =  BlocProvider.of<GlobalBloc>(context).state.memberId;

        return Scaffold(
          drawer: HomeDrawer(),
          //左滑页
          endDrawer: HomeRightDrawer(),
          //右滑页
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: _buildSearchButton(color),
          body: wrapOverlayTool(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              children: <Widget>[
                HomePage(),
                FocusPage(),
                ImConversationListPage(memberId: id,),
                CollectPage(),

              ],
            ),
          ),
          bottomNavigationBar: UnitBottomBar(
              color: Colors.white,
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

  Future<String> getImToken() async {
    var ss = await LocalStorage.get("token");
    var sss =ss.toString();
    return sss;
  }
  loginByToken(String token,{void Function() success}) async {
    if (tfSender == null || tfSender.length == 0) {
      print('发送用户id 必须填写');
      return;
    }
    final res = await FltImPlugin().login(uid: tfSender,token: token);
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
      backgroundColor: Colors.white,
      child: const Icon(Icons.wc,color: Colors.black,),
      onPressed: () => Navigator.of(context).pushNamed(UnitRouter.search),
    );
  }

  _onTapNav(int index) {
    _controller.jumpToPage(index);
    if (index == 1) {
      //BlocProvider.of<CollectBloc>(context).add(EventSetCollectData());
    }
  }
  // 系统通知栏消息推送
  void _showNotification(String title, String body) async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: (int id, String title, String body, String payload) async => null);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String payload) async {
      if (payload != null) {
        print('notification payload: ' + payload);
      }
      // 点击通知栏跳转的页面(暂为空白)
      var memberId = await LocalStorage.get("memberId");
      Navigator.pushNamed(context, UnitRouter.chat_list, arguments: memberId);
    });

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0', title, body,
      importance: Importance.max, priority: Priority.high, ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        randomBit(8, type: 'num'), title, body, platformChannelSpecifics,
        payload: body
    );
  }
  // 生成随机串
  static dynamic randomBit(int len, { String type }) {
    String character = type == 'num' ? '0123456789' : 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
    String left = '';
    for (var i = 0; i < len; i++) {
      left = left + character[Random().nextInt(character.length)];
    }
    return type == 'num' ? int.parse(left) : left;
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
    Map<String, dynamic> message= Map<String, dynamic>.from(result);
    String title="通知";
    String content="消息";
    var type =message['type'];
    if(type == "MESSAGE_TEXT"){
      title="通知";
      content= message['content']['text'];
    }else{
      title="通知";
      content= '聊天消息';
    }


    //_showNotification(title,content);
    BlocProvider.of<PeerBloc>(context).add(EventReceiveNewMessage(message));
  }

  void onPeerSecretMessage(result) {

  }

  void onNewMessage(result, int error) {
    BlocProvider.of<ChatBloc>(context).add(EventNewMessage(result));
  }
}
