part of 'tcp_bloc.dart';

enum SocketConnectionState {
  Connecting,
  Disconnecting,
  Connected,
  Failed,
  None
}

@immutable
class TcpState {
  final SocketConnectionState connectionState;
  final List<Message> messages;

  TcpState({
    required this.connectionState,
    required this.messages,
  });

  factory TcpState.initial() {
    return TcpState(
      connectionState: SocketConnectionState.None, 
      messages: <Message>[]
    );
  }

  TcpState copywith({
    SocketConnectionState? connectionState,
    List<Message>? messages,
  }) {
    return TcpState(
      connectionState: connectionState ?? this.connectionState,
      messages: messages ?? this.messages,
    );
  }

  TcpState copyWithNewMessage({required Message message}) {
    return TcpState(
      connectionState: this.connectionState,
      messages: List.from(this.messages)..add(message),
    );
  }
}