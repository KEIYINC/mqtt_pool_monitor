// mqtt_service.dart
import 'dart:async';
import 'dart:convert';
// import 'dart:io'; // Sertifika devre disi
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static const String broker =
      '1bd1cd42519c4824a7187d4e1fe35646.s1.eu.hivemq.cloud';
  static const int port = 8884; // WebSocket port
  static const String username = 'ilhami';
  static const String password = '12.62.52iLHA';
  static const List<String> topicList = ['zigbee/#'];
  final String clientId = 'flutter_ws_${DateTime.now().millisecondsSinceEpoch}';

  late MqttServerClient client;
  final _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  MqttService() {
    client = MqttServerClient.withPort(broker, clientId, port)
      ..useWebSocket = true
      ..secure = true
      ..websocketProtocols = ['mqtt']
      ..logging(on: true)
      ..keepAlivePeriod = 60
      ..onConnected = onConnected
      ..onDisconnected = onDisconnected
      ..onSubscribed = (topic) => print('✅ Abone olundu: \$topic');
  }

  Future<bool> connect() async {
    print(">> MQTT connect debug: USER = '\$username' | PASS = '\$password'");

    // Sertifika kontrolu kaldirildi. WebSocket icin gerek yok.
    /*
    final context = SecurityContext(withTrustedRoots: false);
    final cert = await rootBundle.load('assets/cert/hivemq_root_ca.pem');
    context.setTrustedCertificatesBytes(cert.buffer.asUint8List());
    client.securityContext = context;
    */

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(username, password)
        .startClean()
        .keepAliveFor(60);

    client.connectionMessage = connMess;

    try {
      await client.connect();
      return true;
    } catch (e) {
      print(' Bağlantı hatası: \$e');
      client.disconnect();
      return false;
    }
  }

  void onConnected() {
    print(' MQTT bağlantısı başarılı!');
    for (final topic in topicList) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> events) {
      final recMess = events[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(' [\${events[0].topic}] \$payload');
      try {
        final jsonMap = jsonDecode(payload) as Map<String, dynamic>;
        _messageStreamController.add(jsonMap);
      } catch (e) {
        print(' JSON parse hatası: \$e');
      }
    });
  }

  void onDisconnected() => print(' MQTT bağlantısı kesildi.');
  void disconnect() => client.disconnect();
  void dispose() {
    _messageStreamController.close();
    disconnect();
  }
}
