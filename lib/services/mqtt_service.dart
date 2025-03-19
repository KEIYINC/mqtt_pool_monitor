import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  // MQTT Broker bağlantı bilgileri
  static String brokerIp = "broker.ip.adresi"; // Daha sonra güncellenecek
  static int port = 1883; // Varsayılan MQTT portu
  static List<String> topicList = ["sensor/sicaklik", "sensor/ph"]; // Örnek topic'ler

  late MqttServerClient client;
  
  MqttService() {
    client = MqttServerClient(brokerIp, '');
    client.port = port;
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
  }

  Future<bool> connect() async {
    try {
      await client.connect();
      return true;
    } catch (e) {
      print('Bağlantı hatası: $e');
      client.disconnect();
      return false;
    }
  }

  void onConnected() {
    print('Broker\'a bağlandı');
    // Topic'lere abone ol
    for (String topic in topicList) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }
    
    // Gelen mesajları dinle
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage message = messages[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      
      print('Topic: ${messages[0].topic}, Mesaj: $payload');
    });
  }

  void onDisconnected() {
    print('Broker bağlantısı kesildi');
  }

  void onSubscribed(String topic) {
    print('Topic\'e abone olundu: $topic');
  }

  void disconnect() {
    client.disconnect();
  }
} 