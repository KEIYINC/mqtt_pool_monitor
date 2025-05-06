import 'package:flutter/material.dart';
import 'services/mqtt_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MqttService mqttService;
  String ph = '-';
  String temperature = '-';
  String tds = '-';
  String ec = '-';
  String orp = '-';
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    _connectAndListen();
  }

  Future<void> _connectAndListen() async {
    final connected = await mqttService.connect();
    if (connected) {
      setState(() => isConnected = true);

      mqttService.messageStream.listen((data) {
        if (data == null) return;
        setState(() {
          ph = data['ph']?.toStringAsFixed(2) ?? '-';
          temperature = data['temperature']?.toStringAsFixed(2) ?? '-';
          tds = data['tds']?.toString() ?? '-';
          ec = data['ec']?.toString() ?? '-';
          orp = data['orp']?.toString() ?? '-';
        });
      });
    }
  }

  @override
  void dispose() {
    mqttService.dispose();
    super.dispose();
  }

  Widget sensorTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18)),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('MQTT Sensör Verileri')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isConnected
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sensorTile('pH', ph),
                    sensorTile('Sıcaklık (°C)', temperature),
                    sensorTile('TDS', tds),
                    sensorTile('EC', ec),
                    sensorTile('ORP', orp),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        mqttService.publishMessage(
                            "test/topic", "Flutter'dan test mesajı!");
                      },
                      child: Text("Test Mesajı Gönder"),
                    ),
                  ],
                )
              : Center(child: Text("MQTT bağlantısı kuruluyor...")),
        ),
      ),
    );
  }
}
