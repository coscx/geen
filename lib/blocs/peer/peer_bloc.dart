import 'dart:math';

import 'package:flt_im_plugin/flt_im_plugin.dart';
import 'package:flt_im_plugin/message.dart';
import 'package:flt_im_plugin/value_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unit/app/res/cons.dart';
import 'peer_event.dart';
import 'peer_state.dart';



class PeerBloc extends Bloc<PeerEvent, PeerState> {


  PeerBloc();

  @override
  PeerState get initialState => PeerInital();

  Color get activeHomeColor {
    return Color(Cons.tabColors[0]);
  }

  @override
  Stream<PeerState> mapEventToState(PeerEvent event) async* {

    if(event is PeerInital){



    }
    if (event is EventReceiveNewMessage) {

      try {

          String cunrrentId;
          List<Message> newMessage =[];
          if (state is PeerMessageSuccess){
            Message mess =Message.fromMap(event.message);
            cunrrentId= state.props.elementAt(1);
            if (mess.sender!=cunrrentId){
               return;
            }
            List<Message> history=state.props.elementAt(0);

            newMessage.addAll(history);
            newMessage.add(mess);

          }else{
            FltImPlugin im = FltImPlugin();
            var res = await im.createConversion(
              currentUID: event.message['receiver'].toString(),
              peerUID: event.message['sender'].toString(),
            );
            Map response = await im.loadData();
            var  messages = ValueUtil.toArr(response["data"]).map((e) => Message.fromMap((e))).toList();

            newMessage.addAll(messages);
          }


        yield PeerMessageSuccess(newMessage,cunrrentId);
      } catch (err) {
        print(err);
        yield GetPeerFailed();
      }

    }

    if (event is EventFirstLoadMessage) {


      try {
        Map<String,dynamic> messageMap ={};
          FltImPlugin im = FltImPlugin();
          var res = await im.createConversion(
            currentUID: event.currentUID,
            peerUID: event.peerUID,
          );
          Map response = await im.loadData();
          var  messages = ValueUtil.toArr(response["data"]).map((e) => Message.fromMap(ValueUtil.toMap(e))).toList();

        yield PeerMessageSuccess(messages,event.peerUID);
      } catch (err) {
        print(err);
        yield GetPeerFailed();
      }

    }
    if (event is EventLoadMoreMessage) {

      try {
           String LocalId ="0";
           List<Message> newMessages=[] ;
           FltImPlugin im = FltImPlugin();
           Map response;
          List<Message> history=[];
          if (state is PeerMessageSuccess){

            history=state.props.elementAt(0);
            LocalId= history.first.msgLocalID.toString();
            response = await im.loadEarlierData( messageID: LocalId);
          }else{

            if (state is LoadMorePeerMessageSuccess){

              history=state.props.elementAt(0);
              LocalId= history.first.msgLocalID.toString();
              response = await im.loadEarlierData( messageID: LocalId);
            }else{
              response = await im.loadData();
            }


          }

          var  messages = ValueUtil.toArr(response["data"]).map((e) => Message.fromMap(ValueUtil.toMap(e))).toList();
          if(history.first!=null){
            newMessages.addAll(messages);
            newMessages.addAll(history);

          }else{
            newMessages.addAll(messages);
          }

        yield LoadMorePeerMessageSuccess(newMessages);
      } catch (err) {
        print(err);
        yield GetPeerFailed();
      }

    }
  }


}
