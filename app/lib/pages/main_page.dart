import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/message.dart';
import '../utils/validators.dart';
import '../tcp_bloc/tcp_bloc.dart';
import 'about_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TcpBloc? _tcpBloc;
  TextEditingController? _hostEditingController;
  TextEditingController? _portEditingController;
  TextEditingController? _chatTextEditingController;

  @override
  void initState() {
    super.initState();
    _tcpBloc =  BlocProvider.of<TcpBloc>(context);

    _hostEditingController = new TextEditingController(text: '10.0.2.2');
    _portEditingController = new TextEditingController(text: '8000');
    _chatTextEditingController = new TextEditingController(text: '');

    _chatTextEditingController!.addListener(() {
      setState(() {
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TCP Client Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) {
                  return AboutPage();
                }
              ));
            },
          )
        ],
      ),
      body: BlocConsumer<TcpBloc, TcpState>(
        bloc: _tcpBloc,
        listener: (BuildContext context, TcpState tcpState) { 
          if (tcpState.connectionState == SocketConnectionState.Connected) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar();
          } else if (tcpState.connectionState == SocketConnectionState.Failed) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text("Connection failed"), Icon(Icons.error)],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        builder: (context, tcpState) {
          if (tcpState.connectionState == SocketConnectionState.None || tcpState.connectionState == SocketConnectionState.Failed) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
              child: ListView(
                children: [
                  TextFormField(
                    controller: _hostEditingController,
                    autovalidateMode : AutovalidateMode.always,
                    validator: (str) => isValidHost(str) ? null : 'Invalid hostname',
                    decoration: InputDecoration(
                      helperText: 'The ip address or hostname of the TCP server',
                      hintText: 'Enter the address here, e. g. 10.0.2.2',
                    ),
                  ),
                  TextFormField(
                    controller: _portEditingController,
                    autovalidateMode : AutovalidateMode.always,
                    validator: (str) => isValidPort(str) ? null : 'Invalid port',
                    decoration: InputDecoration(
                      helperText: 'The port the TCP server is listening on',
                      hintText: 'Enter the port here, e. g. 8000',
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Connect'),
                    onPressed: isValidHost(_hostEditingController!.text) && isValidPort(_portEditingController!.text)
                      ? () {
                        _tcpBloc!.add(
                          Connect(
                            host: _hostEditingController!.text, 
                            port: int.parse(_portEditingController!.text)
                          )
                        );
                      }
                      : null,
                  )
                ],
              ),
            );
          } else if (tcpState.connectionState == SocketConnectionState.Connecting) {
            return Center(
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text('Connecting...'),
                  ElevatedButton(
                    child: Text('Abort'),
                    onPressed: () {
                      _tcpBloc!.add(Disconnect());
                    },
                  )
                ],
              ),
            );
          } else if (tcpState.connectionState == SocketConnectionState.Connected) {
            return Column(
              children: [
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      itemCount: tcpState.messages.length,
                      itemBuilder: (context, idx) {
                        Message m = tcpState.messages[idx];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Bubble(
                            child: Text(m.message),
                            alignment: m.sender == Sender.Client ? Alignment.centerRight : Alignment.centerLeft,
                          ),
                        );
                      }
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Message'
                          ),
                          controller: _chatTextEditingController,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _chatTextEditingController!.text.isEmpty
                          ? null
                          : () {
                            _tcpBloc!.add(SendMessage(message: _chatTextEditingController!.text));
                            _chatTextEditingController!.text = '';
                          },
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  child: Text('Disconnect'),
                  onPressed: () {
                    _tcpBloc!.add(Disconnect());
                  },
                ),                
              ],
            );
          } else {
            return Container();
          }
        }, 
      ),
    );
  }
}