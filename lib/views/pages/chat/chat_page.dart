import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flt_im_plugin/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unit/blocs/peer/peer_bloc.dart';
import 'package:flutter_unit/blocs/peer/peer_event.dart';
import 'package:flutter_unit/blocs/peer/peer_state.dart';
import 'package:flutter_unit/views/items/chat_item_widgets.dart';
import 'package:flutter_unit/views/pages/chat/widget/more_widgets.dart';
import 'package:flutter_unit/views/pages/chat/widget/popupwindow_widget.dart';
import 'package:flutter_unit/views/pages/resource/colors.dart';
import 'package:flutter_unit/views/pages/utils/dialog_util.dart';
import 'package:flutter_unit/views/pages/utils/file_util.dart';
import 'package:flutter_unit/views/pages/utils/functions.dart';
import 'package:flutter_unit/views/pages/utils/image_util.dart';
import 'package:flutter_unit/views/pages/utils/object_util.dart';
import 'package:flutter_record/flutter_record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

/*
*  发送聊天信息
*/
class ChatsPage extends StatefulWidget {

  const ChatsPage(
      {Key key,})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChatsState();
  }
}

class ChatsState extends State<ChatsPage> {
  bool _isBlackName = false;
  var _popString = List<String>();
  bool _isShowSend = false; //是否显示发送按钮
  bool _isShowVoice = false; //是否显示语音输入栏
  bool _isShowFace = false; //是否显示表情栏
  bool _isShowTools = false; //是否显示工具栏
  TextEditingController _controller = new TextEditingController();
  FocusNode _textFieldNode = FocusNode();
  var voiceText = '按住 说话';
  var voiceBackground = ObjectUtil.getThemeLightColor();
  Color _headsetColor = ColorT.gray_99;
  Color _highlightColor = ColorT.gray_99;
  List<Widget> _guideFaceList = new List();
  List<Widget> _guideFigureList = new List();
  List<Widget> _guideToolsList = new List();
  bool _isFaceFirstList = true;
  List<Message> _messageList = new List();
  bool _isLoadAll = false; //是否已经加载完本地数据
  bool _first = false;
  bool _alive = false;
  ScrollController _scrollController = new ScrollController();
  String _audioIconPath = '';
  FlutterRecord _flutterRecord;
  String _voiceFilePath = '';
  String _voiceFileName = '';
  AudioCache _audioPlayer;
  AudioPlayer _fixedPlayer;

  @override
  void initState() {
    // TODO: implement initState
    _first = true;
    _alive = true;
    super.initState();
    _flutterRecord = FlutterRecord();
    _fixedPlayer = new AudioPlayer();
    _audioPlayer = new AudioCache(fixedPlayer: _fixedPlayer);
    _textFieldNode.addListener(_focusNodeListener); // 初始化一个listener
    _getLocalMessage();
    _initData();
    _checkBlackList();
    _getPermission();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _alive = false;
    _fixedPlayer.stop();
    super.dispose();
    _first = false;
    _textFieldNode.removeListener(_focusNodeListener); // 页面消失时必须取消这个listener！！
  }
  Future<Null> _focusNodeListener() async {
    if (_textFieldNode.hasFocus) {
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          _isShowTools = false;
          _isShowFace = false;
          _isShowVoice = false;
          try {
            _scrollController.position.jumpTo(0);
          } catch (e) {}
        });
      });
    }
  }
  _getPermission() {
    //请求读写权限
    ObjectUtil.getPermissions([
      PermissionGroup.storage,
      PermissionGroup.camera,
      PermissionGroup.speech,
      PermissionGroup.location,
    ]).then((res) {
      if (res[PermissionGroup.storage] == PermissionStatus.denied ||
          res[PermissionGroup.storage] == PermissionStatus.unknown) {
        //用户拒绝，禁用，或者不可用
        DialogUtil.showBaseDialog(context, '获取不到权限，APP不能正常使用',
            right: '去设置', left: '取消', rightClick: (res) {
          PermissionHandler().openAppSettings();
        });
      } else if (res[PermissionGroup.storage] == PermissionStatus.granted) {
      } else if (res[PermissionGroup.storage] == PermissionStatus.restricted) {
        //用户同意IOS的回调
      }
    });
  }

  _getLocalMessage() async {

  }

  _initData() {
    _popString.add('清空记录');
    _popString.add('删除好友');
    _popString.add('加入黑名单');
    // KeyboardVisibilityNotification().addNewListener(
    //   onChange: (bool visible) {
    //     if (visible) {
    //       _isShowTools = false;
    //       _isShowFace = false;
    //       _isShowVoice = false;
    //       try {
    //         _scrollController.position.jumpTo(0);
    //       } catch (e) {}
    //     }
    //   },
    // );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _onRefresh();
      }
    });
  }

  _checkBlackList() {

  }

  _initFaceList() {
    if (_guideFaceList.length > 0) {
      _guideFaceList.clear();
    }
    if (_guideFigureList.length > 0) {
      _guideFigureList.clear();
    }
    //添加表情图
    List<String> _faceList = new List();
    String faceDeletePath =
        FileUtil.getImagePath('face_delete', dir: 'face', format: 'png');
    String facePath;
    for (int i = 0; i < 100; i++) {
      if (i < 90) {
        facePath =
            FileUtil.getImagePath(i.toString(), dir: 'face', format: 'gif');
      } else {
        facePath =
            FileUtil.getImagePath(i.toString(), dir: 'face', format: 'png');
      }
      _faceList.add(facePath);
      if (i == 19 || i == 39 || i == 59 || i == 79 || i == 99) {
        _faceList.add(faceDeletePath);
        _guideFaceList.add(_gridView(7, _faceList));
        _faceList.clear();
      }
    }
    //添加斗图
    List<String> _figureList = new List();
    for (int i = 0; i < 96; i++) {
      if (i == 70 || i == 74) {
        String facePath =
            FileUtil.getImagePath(i.toString(), dir: 'figure', format: 'png');
        _figureList.add(facePath);
      } else {
        String facePath =
            FileUtil.getImagePath(i.toString(), dir: 'figure', format: 'gif');
        _figureList.add(facePath);
      }
      if (i == 9 ||
          i == 19 ||
          i == 29 ||
          i == 39 ||
          i == 49 ||
          i == 59 ||
          i == 69 ||
          i == 79 ||
          i == 89 ||
          i == 95) {
        _guideFigureList.add(_gridView(5, _figureList));
        _figureList.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Widget widgets = MaterialApp(
        theme: ThemeData(
            primaryColor: ObjectUtil.getThemeColor(),
            primarySwatch: ObjectUtil.getThemeSwatchColor(),
            platform: TargetPlatform.iOS),
        home: Scaffold(
          appBar: _appBar(),
          body: BlocListener<PeerBloc, PeerState>(
              listener: (ctx, state) {
                if (state is PeerMessageSuccess) {
                  //_scrollToBottom();
                  _scrollController.position.jumpTo(0);
                }
              },
              child:BlocBuilder<PeerBloc, PeerState>(builder: (ctx, state) {
                return _body(ctx, state);
              })),
        ));
    return widgets;
  }

  _appBar() {
    return MoreWidgets.buildAppBar(
      context, '(黑名单)',
      centerTitle: true,
      elevation: 2.0,
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          }),
      actions: <Widget>[
        InkWell(
            child: Container(
                padding: EdgeInsets.only(right: 15, left: 15),
                child: Icon(
                  Icons.more_horiz,
                  size: 22,
                )),
            onTap: () {
              MoreWidgets.buildDefaultMessagePop(context, _popString,
                  onItemClick: (res) {
                switch (res) {
                  case 'one':
                    DialogUtil.showBaseDialog(context, '即将删除该对话的全部聊天记录',
                        right: '删除', left: '再想想', rightClick: (res) {
                      _deleteAll();
                    });
                    break;
                  case 'two':
                    DialogUtil.showBaseDialog(context, '确定删除好友吗？',
                        right: '删除', left: '再想想', rightClick: (res) {

                    });
                    break;
                  case 'three':
                    if (_isBlackName) {
                      DialogUtil.showBaseDialog(context, '确定把好友移出黑名单吗？',
                          right: '移出', left: '再想想', rightClick: (res) {

                      });
                    } else {
                      DialogUtil.showBaseDialog(context, '确定把好友加入黑名单吗？',
                          right: '赶紧', left: '再想想', rightClick: (res) {
                        DialogUtil.showBaseDialog(
                            context, '即将将好友加入黑名单，是否需要支持发消息给TA？',
                            right: '需要',
                            left: '不需要',
                            title: '', rightClick: (res) {

                        }, leftClick: (res) {

                        });
                      });
                    }
                    break;
                }
              });
            })
      ],
    );
  }

  Future _deleteAll() async {


  }

  _body(BuildContext context, PeerState peerState) {
    return Column(children: <Widget>[
      Flexible(
          child: InkWell(
        child: _messageListView(context, peerState),
        onTap: () {
          _hideKeyBoard();
          setState(() {
            _isShowVoice = false;
            _isShowFace = false;
            _isShowTools = false;
          });
        },
      )),
      Divider(height: 1.0),
      Container(
        decoration: new BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        child: Container(
          height: 54,
          child: Row(
            children: <Widget>[
              IconButton(
                  icon: _isShowVoice
                      ? Icon(Icons.keyboard)
                      : Icon(Icons.play_circle_outline),
                  iconSize: 32,
                  onPressed: () {
                    setState(() {
                      _hideKeyBoard();
                      if (_isShowVoice) {
                        _isShowVoice = false;
                      } else {
                        _isShowVoice = true;
                        _isShowFace = false;
                        _isShowTools = false;
                      }
                    });
                  }),
              new Flexible(

                  child: _enterWidget()
              ),
              IconButton(
                  icon: _isShowFace
                      ? Icon(Icons.keyboard)
                      : Icon(Icons.sentiment_very_satisfied),
                  iconSize: 32,
                  onPressed: () {
                    _hideKeyBoard();
                    setState(() {
                      if (_isShowFace) {
                        _isShowFace = false;
                      } else {
                        _isShowFace = true;
                        _isShowVoice = false;
                        _isShowTools = false;
                      }
                    });
                  }),
              _isShowSend
                  ? InkWell(
                      onTap: () {
                        if (_controller.text.isEmpty) {
                          return;
                        }
                        _buildTextMessage(_controller.text);
                      },
                      child: new Container(
                        alignment: Alignment.center,
                        width: 40,
                        height: 32,
                        margin: EdgeInsets.only(right: 8),
                        child: new Text(
                          '发送',
                          style: new TextStyle(
                              fontSize: 14.0, color: Colors.red),
                        ),
                        decoration: new BoxDecoration(
                          color: ObjectUtil.getThemeSwatchColor(),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      iconSize: 32,
                      onPressed: () {
                        _hideKeyBoard();
                        setState(() {
                          if (_isShowTools) {
                            _isShowTools = false;
                          } else {
                            _isShowTools = true;
                            _isShowFace = false;
                            _isShowVoice = false;
                          }
                        });
                      }),
            ],
          ),
        ),
      ),
      (_isShowTools || _isShowFace || _isShowVoice)
          ? Container(
              height: 210,
              child: _bottomWidget(),
            )
          : SizedBox(
              height: 0,
            )
    ]);
  }

  _hideKeyBoard() {
    _textFieldNode.unfocus();
  }

  _bottomWidget() {
    Widget widget;
    if (_isShowTools) {
      widget = _toolsWidget();
    } else if (_isShowFace) {
      widget = _faceWidget();
    } else if (_isShowVoice) {
      widget = _voiceWidget();
    }
    return widget;
  }

  _voiceWidget() {
    return Stack(
      children: <Widget>[
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
                padding: EdgeInsets.all(20),
                child: Icon(
                  Icons.headset,
                  color: _headsetColor,
                  size: 50,
                ))),
        Align(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 10),
                    child: _audioIconPath == ''
                        ? SizedBox(
                            width: 30,
                            height: 30,
                          )
                        : Image.asset(
                            FileUtil.getImagePath(_audioIconPath,
                                dir: 'icon', format: 'png'),
                            width: 30,
                            height: 30,
                            color: ObjectUtil.getThemeSwatchColor(),
                          )),
                Container(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      onScaleStart: (res) {
                        _startRecord();
                      },
                      onScaleEnd: (res) {
                        if (_headsetColor == ObjectUtil.getThemeLightColor()) {
                          DialogUtil.buildToast('试听功能暂未实现');
                          if (_flutterRecord.isRecording) {
                            _flutterRecord.stopRecorder();
                          }
                        } else if (_highlightColor ==
                            ObjectUtil.getThemeLightColor()) {
                          File file = File(_voiceFilePath);
                          file.delete();
                          if (_flutterRecord.isRecording) {
                            _flutterRecord.stopRecorder();
                          }
                        } else {
                          if (_flutterRecord.isRecording) {
                            _flutterRecord.stopRecorder().then((res) {
                              File file = File(_voiceFilePath);
                              _flutterRecord
                                  .getDuration(
                                      path: _voiceFileName) //需要去掉文件类型后缀
                                  .then((length) {
                                print('voice length is---' + length.toString());
                                if (length < 1000) {
                                  //小于1s不发送
                                  file.delete();
                                  DialogUtil.buildToast('你说话时间太短啦~');
                                } else {
                                  //发送语音
                                  _buildVoiceMessage(file, length);
                                }
                              });
                            });
                          }
                        }
                        setState(() {
                          _audioIconPath = '';
                          voiceText = '按住 说话';
                          voiceBackground = ObjectUtil.getThemeLightColor();
                          _headsetColor = ColorT.gray_99;
                          _highlightColor = ColorT.gray_99;
                        });
                      },
                      onScaleUpdate: (res) {
                        if (res.focalPoint.dy > 550 &&
                            res.focalPoint.dy < 620) {
                          if (res.focalPoint.dx > 10 &&
                              res.focalPoint.dx < 80) {
                            setState(() {
                              voiceText = '松开 试听';
                              _headsetColor = ObjectUtil.getThemeLightColor();
                            });
                          } else if (res.focalPoint.dx > 330 &&
                              res.focalPoint.dx < 400) {
                            setState(() {
                              voiceText = '松开 删除';
                              _highlightColor = ObjectUtil.getThemeLightColor();
                            });
                          } else {
                            setState(() {
                              voiceText = '松开 结束';
                              _headsetColor = ColorT.gray_99;
                              _highlightColor = ColorT.gray_99;
                            });
                          }
                        } else {
                          setState(() {
                            voiceText = '松开 结束';
                            _headsetColor = ColorT.gray_99;
                            _highlightColor = ColorT.gray_99;
                          });
                        }
                      },
                      child: new CircleAvatar(
                        child: new Text(
                          voiceText,
                          style: new TextStyle(
                              fontSize: 17.0, color: ColorT.gray_33),
                        ),
                        radius: 60,
                        backgroundColor: voiceBackground,
                      ),
                    ))
              ],
            )),
        Align(
            alignment: Alignment.centerRight,
            child: Container(
                padding: EdgeInsets.all(20),
                child: Icon(
                  Icons.highlight_off,
                  color: _highlightColor,
                  size: 50,
                ))),
      ],
    );
  }

  _startRecord() {
    Vibration.vibrate(duration: 50);
    setState(() {
      voiceText = '松开 结束';
      voiceBackground = ColorT.divider;
    });
    //flutterRecord这个框架把文件都存在了根目录，所以要在MainActivity创建文件../BHMFlutter/voice/
    _voiceFileName =
        'BHMFlutter/voice/' + DateTime.now().millisecondsSinceEpoch.toString();
    _flutterRecord
        .startRecorder(path: _voiceFileName, maxVolume: 10.0)
        .then((voiceFilePath) {
      print('voice file path-- ' + voiceFilePath);
      _voiceFilePath = voiceFilePath;
    });

    _flutterRecord.volumeSubscription.stream.listen((volume) {
      setState(() {
        if (volume <= 0) {
          _audioIconPath = '';
        } else if (volume > 0 && volume < 3) {
          _audioIconPath = 'audio_player_1';
        } else if (volume < 5) {
          _audioIconPath = 'audio_player_2';
        } else if (volume < 10) {
          _audioIconPath = 'audio_player_3';
        }
      });
    });
  }

  _faceWidget() {
    _initFaceList();
    return Column(
      children: <Widget>[
        Flexible(
            child: Stack(
          children: <Widget>[
            Offstage(
              offstage: _isFaceFirstList,
              child: Swiper(
                  autoStart: false,
                  circular: false,
                  indicator: CircleSwiperIndicator(
                      radius: 3.0,
                      padding: EdgeInsets.only(top: 20.0),
                      itemColor: ColorT.gray_99,
                      itemActiveColor: ObjectUtil.getThemeSwatchColor()),
                  children: _guideFigureList),
            ),
            Offstage(
              offstage: !_isFaceFirstList,
              child: Swiper(
                  autoStart: false,
                  circular: false,
                  indicator: CircleSwiperIndicator(
                      radius: 3.0,
                      padding: EdgeInsets.only(top: 20.0),
                      itemColor: ColorT.gray_99,
                      itemActiveColor: ObjectUtil.getThemeSwatchColor()),
                  children: _guideFaceList),
            )

          ],
        )),
        SizedBox(
          height: 2,
        ),
        new Divider(height: 1.0),
        Container(
          height: 24,
          child: Row(
            children: <Widget>[
              Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      padding: EdgeInsets.only(left: 20),
                      child: InkWell(
                        child: Icon(
                          Icons.sentiment_very_satisfied,
                          color: _isFaceFirstList
                              ? ObjectUtil.getThemeSwatchColor()
                              : _headsetColor,
                          size: 22,
                        ),
                        onTap: () {
                          setState(() {
                            _isFaceFirstList = true;
                          });
                        },
                      ))),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: InkWell(
                        child: Icon(
                          Icons.favorite_border,
                          color: _isFaceFirstList
                              ? _headsetColor
                              : ObjectUtil.getThemeSwatchColor(),
                          size: 24,
                        ),
                        onTap: () {
                          setState(() {
                            _isFaceFirstList = false;
                          });
                        },
                      ))),
            ],
          ),
        )
      ],
    );
  }

  _toolsWidget() {
    if (_guideToolsList.length > 0) {
      _guideToolsList.clear();
    }
    List<Widget> _widgets = new List();
    _widgets.add(MoreWidgets.buildIcon(Icons.insert_photo, '相册', o: (res) {
      ImageUtil.getGalleryImage().then((imageFile) {
        //相册取图片
        _willBuildImageMessage(imageFile);
      });
    }));
    _widgets.add(MoreWidgets.buildIcon(Icons.camera_alt, '拍摄', o: (res) {
      PopupWindowUtil.showCameraChosen(context, onCallBack: (type, file) {
        if (type == 1) {
          //相机取图片
          _willBuildImageMessage(file);
        } else if (type == 2) {
          //相机拍视频
          _buildVideoMessage(file);
        }
      });
    }));
    _widgets.add(MoreWidgets.buildIcon(Icons.videocam, '视频通话'));
    _widgets.add(MoreWidgets.buildIcon(Icons.location_on, '位置'));
    _widgets.add(MoreWidgets.buildIcon(Icons.view_agenda, '红包'));
    _widgets.add(MoreWidgets.buildIcon(Icons.swap_horiz, '转账'));
    _widgets.add(MoreWidgets.buildIcon(Icons.mic, '语音输入'));
    _widgets.add(MoreWidgets.buildIcon(Icons.favorite, '我的收藏'));
    _guideToolsList.add(GridView.count(
        crossAxisCount: 4, padding: EdgeInsets.all(0.0), children: _widgets));
    List<Widget> _widgets1 = new List();
    _widgets1.add(MoreWidgets.buildIcon(Icons.person, '名片'));
    _widgets1.add(MoreWidgets.buildIcon(Icons.folder, '文件'));
    _guideToolsList.add(GridView.count(
        crossAxisCount: 4, padding: EdgeInsets.all(0.0), children: _widgets1));

  }

  _gridView(int crossAxisCount, List<String> list) {
    return GridView.count(
        crossAxisCount: crossAxisCount,
        padding: EdgeInsets.all(0.0),
        children: list.map((String name) {
          return new IconButton(
              onPressed: () {
                if (name.contains('face_delete')) {
                  DialogUtil.buildToast('暂时不会把自定义表情显示在TextField，谁会的教我~');
                } else {
                  //表情因为取的是assets里的图，所以当初文本发送
                  _buildTextMessage(name);
                }
              },
              icon: Image.asset(name,
                  width: crossAxisCount == 5 ? 60 : 32,
                  height: crossAxisCount == 5 ? 60 : 32));
        }).toList());
  }

  /*输入框*/
  _enterWidget() {
    return new Material(
      borderRadius: BorderRadius.circular(8.0),
      shadowColor: ObjectUtil.getThemeLightColor(),
      color: ColorT.gray_f0,
      elevation: 0,
      child: new TextField(
          focusNode: _textFieldNode,
          textInputAction: TextInputAction.send,
          controller: _controller,
          inputFormatters: [
            LengthLimitingTextInputFormatter(150), //长度限制11
          ], //只能输入整数
          style: TextStyle(color: Colors.black, fontSize: 18),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
          ),
          onChanged: (str) {
            setState(() {
              if (str.isNotEmpty) {
                _isShowSend = true;
              } else {
                _isShowSend = false;
              }
            });
          },
          onEditingComplete: () {
            if (_controller.text.isEmpty) {
              return;
            }
            _buildTextMessage(_controller.text);
          }),
    );
  }

  _messageListView(BuildContext context, PeerState peerState) {
    return Container(
        color: ColorT.gray_f0,
        child: Column(
          //如果只有一条数据，listView的高度由内容决定了，所以要加列，让listView看起来是满屏的
          children: <Widget>[
            Flexible(
                //外层是Column，所以在Column和ListView之间需要有个灵活变动的控件
                child: _buildContent(context, peerState))
          ],
        ));
  }
  Widget _buildContent(BuildContext context, PeerState state) {
    if (state is PeerMessageSuccess) {
      return   ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _messageListViewItem(state.messageList,index);
          },
          //倒置过来的ListView，这样数据多的时候也会显示“底部”（其实是顶部），
          //因为正常的listView数据多的时候，没有办法显示在顶部最后一条
          reverse: true,
          //如果只有一条数据，因为倒置了，数据会显示在最下面，上面有一块空白，
          //所以应该让listView高度由内容决定
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: state.messageList.length);
    }
    if (state is LoadMorePeerMessageSuccess) {
      return   ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _messageListViewItem(state.messageList,index);
          },
          //倒置过来的ListView，这样数据多的时候也会显示“底部”（其实是顶部），
          //因为正常的listView数据多的时候，没有办法显示在顶部最后一条
          reverse: true,
          //如果只有一条数据，因为倒置了，数据会显示在最下面，上面有一块空白，
          //所以应该让listView高度由内容决定
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: state.messageList.length);
    }
    return Container();
  }
  Future<Null> _onRefresh() async {

    BlocProvider.of<PeerBloc>(context).add(EventLoadMoreMessage());
  }

  Widget _messageListViewItem(List<Message>messageList, int index) {
    //list最后一条消息（时间上是最老的），是没有下一条了
    Message _nextEntity = (index == messageList.length - 1) ? null : messageList[index + 1];
    Message _entity = messageList[index];
    return ChatItemWidgets.buildChatListItem(_nextEntity, _entity,
        onResend: (reSendEntity) {
      _onResend(reSendEntity); //重发
    }, onItemClick: (onClickEntity) async {
      Message entity = onClickEntity;
    });
  }

  /*删除好友*/
  _deleteContact(String username) {

  }

  /*加入黑名单*/
  _addToBlackList(String isNeed, String username) {

  }

  /*移出黑名单*/
  _removeUserFromBlackList(String username) {

  }

  //重发
  _onResend(Message entity) {

  }

  _buildTextMessage(String content) {
    BlocProvider.of<PeerBloc>(context).add(EventSendNewMessage("1","2",content));
    //setState(() {
      _controller.clear();
      _isShowSend = false;
    //});

  }
  sendTextMessage(String text) async {
    if (text == null || text.length == 0) {

      return;
    }



  }
  _willBuildImageMessage(File imageFile) {
    if (imageFile == null || imageFile.path.isEmpty) {
      return;
    }
    DialogUtil.showBaseDialog(context, '是否发送原图？',
        title: '', right: '原图', left: '压缩图', rightClick: (res) {
      _buildImageMessage(imageFile, true);
    }, leftClick: (res) {
      _buildImageMessage(imageFile, false);
    });
  }

  _buildImageMessage(File file, bool sendOriginalImage) {


    setState(() {

      _controller.clear();
    });

  }

  _buildVoiceMessage(File file, int length) {

    setState(() {

      _controller.clear();
    });

  }

  _buildVideoMessage(Map file) {


    setState(() {

      _controller.clear();
    });

  }

  _sendMessage(Message messageEntity, {bool isResend = false}) {
    if (isResend) {
      setState(() {

      });
    }

  }

  @override
  void updateData(Message entity) {
    // TODO: implement updateData
    if (null == entity) {
      return;
    }
    if (entity.sender == "0" || _first) {
      //自己发的消息，通知消息页面刷新的时候，这里也会收到，但是这些不处理
      _first = false;
      return;
    } else if (entity.type == MessageType.MESSAGE_TEXT) {

      setState(() {
        _messageList.insert(0, entity);
      });
    }
  }
}
