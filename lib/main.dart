import 'package:flutter/material.dart';
import 'services/mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Havuz Sensör Monitörü',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MqttService _mqttService;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService();
    _connectToMqtt();
  }

  Future<void> _connectToMqtt() async {
    bool connected = await _mqttService.connect();
    setState(() {
      _isConnected = connected;
    });
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Havuz Sensör Monitörü'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isConnected ? Icons.check_circle : Icons.error,
              size: 50,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _isConnected ? 'Bağlantı Kuruldu' : 'Bağlantı Hatası',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
} 