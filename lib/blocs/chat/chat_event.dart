import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unit/app/enums.dart';
import 'package:flutter_unit/storage/po/widget_po.dart';
import 'package:flutter_unit/model/widget_model.dart';



abstract class ChatEvent extends Equatable {

  @override
  List<Object> get props => [];
}


class EventNewMessage extends ChatEvent {
  final Map<String,dynamic> message;
  EventNewMessage(this.message);

}