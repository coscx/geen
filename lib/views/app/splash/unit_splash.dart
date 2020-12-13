
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geen/app/router.dart';
import 'package:flutter_geen/storage/dao/local_storage.dart';
import 'package:flutter_geen/views/dialogs/CustomDialog.dart';
import 'unit_paint.dart';
import 'package:jverify/jverify.dart';
/// 说明: app 闪屏页

class UnitSplash extends StatefulWidget {
  final double size;

  UnitSplash({this.size = 200});

  @override
  _UnitSplashState createState() => _UnitSplashState();
}

class _UnitSplashState extends State<UnitSplash> with TickerProviderStateMixin {
  AnimationController _controller;
  double _factor;
  Animation _curveAnim;

  bool _animEnd = false;
  bool _getPreLoginSuccess = false;
  /// 统一 key
  final String f_result_key = "result";
  /// 错误码
  final  String  f_code_key = "code";
  /// 回调的提示信息，统一返回 flutter 为 message
  final  String  f_msg_key  = "message";
  /// 运营商信息
  final  String  f_opr_key  = "operator";


  String _platformVersion = 'Unknown';
  String _result = "token=";
  var controllerPHone = new TextEditingController();
  final Jverify jverify = new Jverify();
  bool _loading = false;
  String _token;


  @override
  void initState() {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    _controller =
        AnimationController(duration: Duration(milliseconds: 1000), vsync: this)
          ..addListener(_listenAnimation)
          ..addStatusListener(_listenStatus)
          ..forward();

    _curveAnim = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    super.initState();
    initPlatformState();
  }

  void _listenAnimation() {
    setState(() {
      return _factor = _curveAnim.value;
    });
  }
  Future<void> initPlatformState() async {
    String platformVersion;

    // 初始化 SDK 之前添加监听
    jverify.addSDKSetupCallBackListener((JVSDKSetupEvent event){
      print("receive sdk setup call back event :${event.toMap()}");

      jverify.isInitSuccess().then((map) {
        bool result = map[f_result_key];
        print(_result);
        jverify.checkVerifyEnable().then((map) {
          bool result = map[f_result_key];
          if (result) {
            jverify.preLogin().then((map) {
              print("预取号接口回调：${map.toString()}");
              int code = map[f_code_key];
              String message = map[f_msg_key];
              _getPreLoginSuccess=true;

            });
          }else {

              _result = "[2016],msg = 当前网络环境不支持认证";
               print(_result);
          }
        });


      });

    });

    jverify.setDebugMode(true); // 打开调试模式
    jverify.setup(
        appKey: "334db8731c1e38a9c7c3f512",//"你自己应用的 AppKey",
        channel: "devloper-default"); // 初始化sdk,  appKey 和 channel 只对ios设置有效
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    /// 授权页面点击时间监听
    jverify.addAuthPageEventListener((JVAuthPageEvent event) {
      print("receive auth page event :${event.toMap()}");
    });
  }

  void _listenStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _animEnd = true;
        Future.delayed(Duration(milliseconds: 500)).then((e) async {
          var ss = await LocalStorage.get("token");
          var sss =ss.toString();
          if(sss == "" || ss == null){
            Navigator.of(context).pushReplacementNamed(UnitRouter.login);
          } else{
            //LocalStorage.save("token", '');
            var agree = await LocalStorage.get("agree");
            var agrees =agree.toString();
            if(agrees == "1"){
              Navigator.of(context).pushReplacementNamed(UnitRouter.nav);

            } else{
              //LocalStorage.save("token", '');
              showDialog(context: context, builder: (ctx) => _buildDialog());
            }

            //
          }




        });
      });
    }
  }
  static Widget _buildDialog() => Dialog(
    backgroundColor: Colors.white,
    elevation: 5,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
    child: Container(
      width: 50,
      child: DeleteDialog(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final double winH = MediaQuery.of(context).size.height;
    final double winW = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _buildLogo(Colors.blue),
          Container(
            width: winW,
            height: winH,
            child: CustomPaint(
              painter: UnitPainter(factor: _factor),
            ),
          ),
          _buildText(winH, winW),
          _buildHead(),
          _buildPower(),
        ],
      ),
    );
  }

  Widget _buildText(double winH, double winW) {
    final shadowStyle = TextStyle(
      fontSize: 40,
      color: Theme.of(context).primaryColor,
      fontWeight: FontWeight.bold,
      shadows: [
        const Shadow(
          color: Colors.grey,
          offset: Offset(1.0, 1.0),
          blurRadius: 1.0,
        )
      ],
    );

    return Positioned(
      top: winH / 1.4,
      child: AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          opacity: _animEnd ? 1.0 : 0.0,
          child: Text(
            'GUGU管理端',
            style: shadowStyle,
          )),
    );
  }

  final colors = [Colors.red, Colors.yellow, Colors.blue];

  Widget _buildLogo(Color primaryColor) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0),
        end: const Offset(0, -1.5),
      ).animate(_controller),
      child: RotationTransition(
          turns: _controller,
          child: ScaleTransition(
            scale: Tween(begin: 2.0, end: 1.0).animate(_controller),
            child: FadeTransition(
                opacity: _controller,
                child: Container(
                  height: 120,
                  child: FlutterLogo(
                    size: 60,
                  ),
                )),
          )),
    );
  }

  Widget _buildHead() => SlideTransition(
      position: Tween<Offset>(
        end: const Offset(0, 0),
        begin: const Offset(0, -5),
      ).animate(_controller),
      child: Container(
        height: 45,
        width: 45,
        child: Image.asset('assets/images/icon_head.webp'),
      ));

  Widget _buildPower() => Positioned(
        bottom: 30,
        right: 30,
        child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _animEnd ? 1.0 : 0.0,
            child: const Text("Power off GUGU Group",
                style: TextStyle(
                    color: Colors.grey,
                    shadows: [
                      Shadow(
                          color: Colors.black,
                          blurRadius: 1,
                          offset: Offset(0.3, 0.3))
                    ],
                    fontSize: 16))),
      );
}
