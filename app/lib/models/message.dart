import 'package:flutter/foundation.dart';

enum Sender {
  Client,
  Server
}

class Message {
  final DateTime timestamp;
  final String message;
  final Sender sender;

  Message({
    required this.timestamp, 
    required this.message,
    required this.sender
  });
}