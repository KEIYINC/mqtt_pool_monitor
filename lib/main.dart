// main.dart
import 'package:flutter/material.dart';
import 'package:mqtt_pool_monitor/services/mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    _connectToMQTT();
  }

  void _connectToMQTT() async {
    final connected = await mqttService.connect();
    if (connected) {
      mqttService.messageStream.listen((message) {
        print("💡 Mesaj alındı: $message");
      });
    }
  }

  @override
  void dispose() {
    mqttService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text("MQTT Flutter WebSocket Test")),
      ),
    );
  }
}
