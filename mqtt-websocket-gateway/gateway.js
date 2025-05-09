const WebSocket = require('ws');
const mqtt = require('mqtt');

// WebSocket sunucusu (Flutter buraya bağlanacak)
const wss = new WebSocket.Server({ port: 8080 });
console.log("🟢 WebSocket server ready on ws://localhost:8080");

// MQTT istemcisi (Node.js -> HiveMQ)
const mqttClient = mqtt.connect('mqtts://1bd1cd42519c4824a7187d4e1fe35646.s1.eu.hivemq.cloud:8883', {
  username: 'ilhami',
  password: '12.62.52iLHA',
  clientId: 'node_ws_bridge_' + Date.now(),
});

mqttClient.on('connect', () => {
  console.log(' Connected to HiveMQ');
  mqttClient.subscribe('zigbee/#');
});

mqttClient.on('message', (topic, message) => {
  const payload = message.toString();
  console.log(` MQTT >> ${topic}: ${payload}`);

  // MQTT'den geleni WebSocket üzerinden Flutter'a gönder
  wss.clients.forEach(ws => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({ topic, payload }));
    }
  });
});

// Flutter'dan gelen WebSocket mesajını MQTT'ye aktar
wss.on('connection', (ws) => {
  console.log(' Flutter connected via WebSocket');

  ws.on('message', (msg) => {
    try {
      const data = JSON.parse(msg);
      mqttClient.publish(data.topic, data.payload);
      console.log(` WS >> MQTT publish: ${data.topic}: ${data.payload}`);
    } catch (err) {
      console.error(' Invalid WebSocket message:', msg);
    }
  });

  ws.on('close', () => {
    console.log(' WebSocket client disconnected');
  });
});
