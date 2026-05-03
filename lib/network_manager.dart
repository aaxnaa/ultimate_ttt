import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

enum NetworkStatus { idle, hosting, discovering, connected }

class NetworkManager extends ChangeNotifier {
  MqttBrowserClient? client;
  NetworkStatus status = NetworkStatus.idle;
  String? connectedRoomPin;
  String myPlayerName = "";

  // Callback for when data is received
  Function(Map<String, dynamic>)? onDataReceived;
  // Callback for when a player joins
  Function()? onPlayerConnected;

  Future<void> connectToRoom(String pin, String name, bool isHost) async {
    myPlayerName = name;
    connectedRoomPin = pin;
    status = isHost ? NetworkStatus.hosting : NetworkStatus.discovering;
    notifyListeners();

    // Use a public MQTT broker (Free, no account needed)
    client = MqttBrowserClient('wss://broker.emqx.io/mqtt', 'ttt_${DateTime.now().millisecondsSinceEpoch}');
    client!.port = 8084; // WebSocket port for EMQX
    client!.keepAlivePeriod = 20;
    client!.onConnected = () => _onConnected(isHost);
    client!.onDisconnected = _onDisconnected;

    try {
      await client!.connect();
    } catch (e) {
      debugPrint('MQTT Connection failed: $e');
      disconnect();
    }
  }

  void _onConnected(bool isHost) {
    status = NetworkStatus.connected;
    
    // Subscribe to the room's topic
    final topic = 'ultimate_ttt_room_$connectedRoomPin';
    client!.subscribe(topic, MqttQos.atLeastOnce);

    // Listen for messages
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      
      Map<String, dynamic> data = jsonDecode(payload);
      
      // Ignore our own messages
      if (data['sender'] != myPlayerName) {
        onDataReceived?.call(data);
        if (data['type'] == 'JOIN_ANNOUNCE') {
          onPlayerConnected?.call();
        }
      }
    });

    // If joining, announce arrival
    if (!isHost) {
      sendData({'type': 'JOIN_ANNOUNCE'});
    }
    
    notifyListeners();
  }

  void _onDisconnected() {
    status = NetworkStatus.idle;
    notifyListeners();
  }

  void sendData(Map<String, dynamic> data) {
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      data['sender'] = myPlayerName;
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(data));
      client!.publishMessage('ultimate_ttt_room_$connectedRoomPin', MqttQos.atLeastOnce, builder.payload!);
    }
  }

  void disconnect() {
    client?.disconnect();
    status = NetworkStatus.idle;
    connectedRoomPin = null;
    notifyListeners();
  }

  // Legacy methods for UI compatibility
  void stopAll() => disconnect();
  Future<void> hostRoom(String pin, String name) => connectToRoom(pin, name, true);
  Future<void> joinRoom(String pin, String name) => connectToRoom(pin, name, false);
}
