# mqtt_pool_monitor


Flutter tabanlı bu mobil uygulama, IoT cihazlarından gelen havuz sensör verilerini gerçek zamanlı olarak MQTT üzerinden alır ve kullanıcıya görsel olarak sunar. Uygulama; pH, sıcaklık, TDS, EC ve ORP gibi değerleri animasyonlu göstergelerle izleme imkânı sağlar. MQTT bağlantısı TLS ile güvence altına alınır ve mobil istemci ile broker arasındaki iletişim WebSocket üzerinden kurulan bir Node.js köprüsüyle sağlanır.

## 🔧 Sistem Mimarisi

```text
[ESP Sensör] → [HiveMQ MQTT Broker] → [Node.js WebSocket Gateway] → [Flutter Mobil Uygulama]

## Overview

This github repository includes only mobile part of the project. This Flutter application is designed to monitor and display real-time pool sensor data, including pH levels, temperature, chlorine concentration, and other parameters from an IoT device using the MQTT protocol. It enables seamless data retrieval and visualization on a mobile platform.

---

## Getting Started

To get started with this project, you'll need to have **Flutter** installed on your machine. Follow the steps below to set up the project.

### Prerequisites

- Install **Flutter** from [flutter.dev](https://flutter.dev/docs/get-started/install).
- Make sure you have a working **MQTT broker** setup to send the sensor data.
- An **ESP H2** or compatible IoT device that can send data over MQTT.

### Installing Dependencies

1. Clone the repository:

```bash
git clone https://github.com/your-repo/mqtt_pool_monitor.git
