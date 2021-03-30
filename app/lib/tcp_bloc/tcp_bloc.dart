import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tcp_example/models/message.dart';

part 'tcp_event.dart';
part 'tcp_state.dart';

class TcpBloc extends Bloc<TcpEvent, TcpState> {
  Socket? _socket;
  StreamSubscription? _socketStreamSub;
  ConnectionTask<Socket>? _socketConnectionTask;

  TcpBloc() : super(TcpState.initial());

  @override
  Stream<TcpState> mapEventToState(
    TcpEvent event,
  ) async* {
    if (event is Connect) {
      yield* _mapConnectToState(event);
    } else if (event is Disconnect) {
      yield* _mapDisconnectToState();
    } else if (event is ErrorOccured) {
      yield* _mapErrorToState();
    } else if (event is MessageReceived) {
      yield state.copyWithNewMessage(message: event.message);
    } else if (event is SendMessage) {
      yield* _mapSendMessageToState(event);
    }
  }

  Stream<TcpState> _mapConnectToState(Connect event) async* {
    yield state.copywith(connectionState: SocketConnectionState.Connecting);
    try {
      _socketConnectionTask = await Socket.startConnect(event.host, event.port);
      _socket = await _socketConnectionTask!.socket;

      _socketStreamSub = _socket!.asBroadcastStream().listen((event) {
        this.add(
          MessageReceived(
            message: Message(
              message: String.fromCharCodes(event),
              timestamp: DateTime.now(),
              sender: Sender.Server,
            )
          )
        );
      });
      _socket!.handleError(() {
        this.add(ErrorOccured());
      });

      yield state.copywith(connectionState: SocketConnectionState.Connected);
    } catch (err) {
      yield state.copywith(connectionState: SocketConnectionState.Failed);
    }
  }

  Stream<TcpState> _mapDisconnectToState() async* {
    try {
      yield state.copywith(connectionState: SocketConnectionState.Disconnecting);
      _socketConnectionTask?.cancel();
      await _socketStreamSub?.cancel();
      await _socket?.close();
    } catch (ex) {
      print(ex);
    }
    yield state.copywith(connectionState: SocketConnectionState.None, messages: []);
  }

  Stream<TcpState> _mapErrorToState() async* {
    yield state.copywith(connectionState: SocketConnectionState.Failed);
    await _socketStreamSub?.cancel();
    await _socket?.close();
  }

  Stream<TcpState> _mapSendMessageToState(SendMessage event) async* {
    if (_socket != null) {
      yield state.copyWithNewMessage(message: Message(
        message: event.message,
        timestamp: DateTime.now(),
        sender: Sender.Client,
      ));
      _socket!.writeln(event.message);
    }
  }

  @override
  Future<void> close() {
    _socketStreamSub?.cancel();
    _socket?.close();
    return super.close();
  }
}
