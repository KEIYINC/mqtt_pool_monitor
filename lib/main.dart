import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebSocketChannel channel;

  double? ph, temperature, tds, ec, orp;

  @override
  void initState() {
    super.initState();

    channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080'));

    channel.stream.listen((message) {
      try {
        final outer = jsonDecode(message);
        final inner = jsonDecode(outer["payload"]);

        setState(() {
          ph = double.tryParse(inner["ph"].toString());
          temperature = double.tryParse(inner["temperature"].toString());
          tds = double.tryParse(inner["tds"].toString());
          ec = double.tryParse(inner["ec"].toString());
          orp = double.tryParse(inner["orp"].toString());
        });
      } catch (e) {
        print("❌ Parse hatası: $e");
      }
    });

    print("✅ WebSocket bağlandı");
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Widget buildGauge(String title, double? value, double min, double max, String unit) {
    return Column(
      children: [
        Text("$title: ${value?.toStringAsFixed(2) ?? '-'} $unit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SfRadialGauge(
          axes: [
            RadialAxis(
              minimum: min,
              maximum: max,
              showLabels: true,
              showTicks: true,
              ranges: [
                GaugeRange(startValue: min, endValue: max, color: Colors.blue[100]!),
              ],
              pointers: [
                NeedlePointer(value: value ?? 0),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Text("${value?.toStringAsFixed(2) ?? '-'} $unit", style: TextStyle(fontSize: 14)),
                  angle: 90,
                  positionFactor: 0.8,
                )
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('MQTT Sensör Verileri')),
        body: ph == null
            ? Center(child: Text("Veri bekleniyor..."))
            : SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              buildGauge("pH", ph, 0, 14, ""),
              buildGauge("Sıcaklık", temperature, 0, 100, "°C"),
              buildGauge("TDS", tds, 0, 2000, "ppm"),
              buildGauge("EC", ec, 0, 3000, "μS/cm"),
              buildGauge("ORP", orp, 0, 1000, "mV"),
            ],
          ),
        ),
      ),
    );
  }
}
