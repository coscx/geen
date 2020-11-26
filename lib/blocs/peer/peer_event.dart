import 'package:equatable/equatable.dart';
import 'package:flt_im_plugin/message.dart';




abstract class PeerEvent extends Equatable {

  @override
  List<Object> get props => [];
}


class EventFirstLoadMessage extends PeerEvent {
  final String currentUID;
  final String peerUID;
  EventFirstLoadMessage(this.currentUID,this.peerUID);

}

class EventLoadMoreMessage extends PeerEvent {

}

class EventReceiveNewMessage extends PeerEvent {
  final Map<String,dynamic> message;
  EventReceiveNewMessage(this.message);

}

class EventSendNewMessage extends PeerEvent {

  final String currentUID;
  final String peerUID;
  final String content;
  EventSendNewMessage(this.currentUID,this.peerUID,this.content,);

}