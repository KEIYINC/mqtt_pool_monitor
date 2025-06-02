# 🏊 mqtt_pool_monitor

Flutter tabanlı bu mobil uygulama, IoT cihazlarından gelen havuz sensör verilerini gerçek zamanlı olarak MQTT protokolüyle alır ve kullanıcıya sezgisel bir arayüzde görsel olarak sunar. Uygulama; pH, sıcaklık, TDS, EC ve ORP gibi değerleri animasyonlu göstergelerle izleme imkânı sağlar. MQTT bağlantısı TLS ile güvence altına alınır ve Flutter uygulaması, Node.js ile oluşturulmuş bir WebSocket Gateway üzerinden MQTT broker'a bağlanır.

---

## 🔧 Sistem Mimarisi

[ESP Sensör] → [HiveMQ MQTT Broker] → [Node.js WebSocket Gateway] → [Flutter Mobil Uygulama]


---

##  Overview

This repository includes only the mobile part of the system. The Flutter app connects to a WebSocket gateway that bridges HiveMQ MQTT messages and visualizes real-time pool sensor metrics like pH, temperature, and chlorine levels.

---

##  Getting Started

###  Prerequisites

- Flutter SDK (Install: [flutter.dev](https://flutter.dev/docs/get-started/install))
- MQTT Broker (e.g., HiveMQ Cloud)
- ESP32/ESP8266 or similar IoT device that publishes data to MQTT
- Node.js WebSocket Gateway (must be running at `ws://<your-ip>:8080`)

###  Installation

git clone https://github.com/your-username/mqtt_pool_monitor.git
cd mqtt_pool_monitor
flutter pub get
flutter run

## 📡 Örnek MQTT JSON Payload

{
  "ph": 7.25,
  "temperature": 24.1,
  "tds": 840,
  "ec": 1520,
  "orp": 312
}
