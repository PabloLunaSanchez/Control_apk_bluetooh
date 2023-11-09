import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:carrito_bluetooh_apk/custombottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  late BluetoothConnection? connection = null;

  List<_Message> messages = [];

  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection?.input?.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
        backgroundColor: Color.fromARGB(255, 50, 46, 46),
        appBar: AppBar(
            title: (isConnected
                ? Text('Conectado a:  ${widget.server.name}')
                : Text('Chat log with ${widget.server.name}'))),
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Container(
              width: 300, // Ancho del control remoto
              height: 300, // Alto del control remoto
              decoration: BoxDecoration(
                color: Color.fromARGB(
                    255, 193, 97, 97), // Color de fondo del control remoto
                borderRadius: BorderRadius.circular(
                    100), // Forma redondeada del control remoto
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                          icon: Icons
                              .keyboard_arrow_up_rounded, //boton flecha ariba o avanzar
                          onPressed: () => _sendMessage(
                              '0')), // Llama a _sendMessage con '0' cuando se presiona
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                          icon: Icons
                              .keyboard_arrow_left_rounded, // boton flecha izquierda
                          onPressed: () => _sendMessage(
                              '3')), // Llama a _sendMessage con '3' cuando se presiona
                      SizedBox(width: 2),

                      // Botón de detener
                      CustomButton(
                        icon: Icons.stop_circle, // boton para detener
                        onPressed: () => _sendMessage('4'),
                        // Acción para detener
                      ),
                      SizedBox(width: 10),

                      CustomButton(
                          icon: Icons
                              .keyboard_arrow_right, // // boton para la derecha
                          onPressed: () => _sendMessage('2')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                          icon: Icons.keyboard_arrow_down_rounded,
                          onPressed: () => _sendMessage(
                              '1')), // boton para abajo o retroceder
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                  padding: const EdgeInsets.all(
                      12.0), //Esta es una lista para que cuando presionemos un boton se vea lo que estamos mandando 0-4
                  controller: listScrollController,
                  children: list),
            ),
          ],
        )));
  }

  void _onDataReceived(Uint8List data) {
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 6 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 5 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        final messageBytes = Uint8List.fromList(utf8.encode("$text\r\n"));
        connection?.output.add(messageBytes);
        await connection?.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });
      } catch (e) {
        // Manejar errores de envío de mensajes
        print("Error al enviar el mensaje: $e");
      }
    }
  }
}
