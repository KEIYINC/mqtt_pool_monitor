import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebSocketChannel channel;

  double? ph, temperature;
  int? tds, ec, orp;

  @override
  void initState() {
    super.initState();

    channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080'));

    channel.stream.listen((message) {
      print('📨 Gelen mesaj: $message');

      try {
        final outer = jsonDecode(message);
        final inner = jsonDecode(outer["payload"]);

        setState(() {
          ph = inner["ph"]?.toDouble();
          temperature = inner["temperature"]?.toDouble();
          tds = inner["tds"]?.toInt();
          ec = inner["ec"]?.toInt();
          orp = inner["orp"]?.toInt();
        });
      } catch (e) {
        print("❌ Parse hatası: $e");
      }
    }, onError: (err) {
      print('❌ WebSocket hatası: $err');
    });

    print("✅ WebSocket bağlandı");
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('MQTT Sensör Verileri')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ph == null
              ? Center(child: Text("Veri bekleniyor..."))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('pH: ${ph?.toStringAsFixed(2)}', style: _style()),
              Text('Sıcaklık: ${temperature?.toStringAsFixed(1)} °C', style: _style()),
              Text('TDS: $tds ppm', style: _style()),
              Text('EC: $ec μS/cm', style: _style()),
              Text('ORP: $orp mV', style: _style()),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _style() => TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
}
