import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Sertifika için
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static String broker = "1bd1cd42519c4824a7187d4e1fe35646.s1.eu.hivemq.cloud";
  static String username = "ilhami";
  static String password = "12.62.52iLHA";
  static List<String> topicList = ["zigbee/sensor"];

  late MqttServerClient client;

  final StreamController<Map<String, dynamic>> _messageStreamController =
  StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageStreamController.stream;

  MqttService() {
    client = MqttServerClient.withPort(broker, 'flutter_client', 8883);
    client.useWebSocket = false;
    client.secure = true;
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.setProtocolV311();

    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
  }

  Future<bool> connect() async {
    print("MQTT Bağlantısı başlatılıyor...");

    // PEM yükle ve güvenilir sertifikaya ekle
    final context = SecurityContext(withTrustedRoots: false);
    final ByteData certData = await rootBundle.load('assets/cert/ca.pem');
    context.setTrustedCertificatesBytes(certData.buffer.asUint8List());

    client.securityContext = context;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .authenticateAs(username, password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMess;

    try {
      await client.connect();
      return true;
    } catch (e, stacktrace) {
      print('Bağlantı hatası: $e');
      print('Stacktrace: $stacktrace');
      client.disconnect();
      return false;
    }
  }


  void onConnected() {
    print('✔️ MQTT bağlantısı başarılı!');
    for (String topic in topicList) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
      final recMess = messages[0].payload as MqttPublishMessage;
      final payloadStr = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print('[${messages[0].topic}] Gelen JSON: $payloadStr');

      try {
        final json = jsonDecode(payloadStr) as Map<String, dynamic>;
        _messageStreamController.add(json);
      } catch (e) {
        print('JSON parse hatası: $e');
      }
    });
  }

  void onDisconnected() {
    print(' MQTT bağlantısı kesildi.');
  }

  void onSubscribed(String topic) {
    print(' Abone olundu: $topic');
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    client.disconnect();
  }

  void dispose() {
    _messageStreamController.close();
    disconnect();
  }
}
