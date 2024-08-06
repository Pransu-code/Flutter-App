import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebSocketPage(),
    );
  }
}

class WebSocketPage extends StatefulWidget {
  @override
  _WebSocketPageState createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://ws-feed.pro.coinbase.com'),
  );
  String _lastPrice = "Waiting for data...";

  @override
  void initState() {
    super.initState();
    _subscribeToWebSocket();
  }

  void _subscribeToWebSocket() {
    final subscribeMessage = json.encode({
      "type": "subscribe",
      "channels": [
        {
          "name": "ticker",
          "product_ids": ["BTC-USD"]
        }
      ]
    });
    channel.sink.add(subscribeMessage);

    channel.stream.listen((data) {
      final parsedData = json.decode(data);
      if (parsedData['type'] == 'ticker' && parsedData['price'] != null) {
        setState(() {
          _lastPrice = parsedData['price'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: Text('Last Price: $_lastPrice'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
