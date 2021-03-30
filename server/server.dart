import 'dart:convert';
import 'dart:core';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

const hostname = '0.0.0.0'; // Binds to all adapters
const port = 8000;

Future<void> startServer() async {
  final server = await ServerSocket.bind(hostname, port);
  print('TCP server started at ${server.address}:${server.port}.');

  try {
    server.listen((Socket socket) {
      print(
          'New TCP client ${socket.address.address}:${socket.port} connected.');
      socket.writeln("Hello from the echo server!");
      socket.writeln("How are you?");
      socket.listen(
        (Uint8List data) {
          if (data.length > 0 && data.first == 10) return;
          final msg = data.toString();
          print('Data from client: $msg');
          socket.add(utf8.encode("Echo: "));
          socket.add(data);
        },
        onError: (error) {
          print('Error for client ${socket.address.address}:${socket.port}.');
        },
        onDone: () {
          print('Connection to client ${socket.address.address}:${socket.port} done.');
        });
    });
  } on SocketException catch (ex) {
    print(ex.message);
  }
}

void main() {
  startServer();
}