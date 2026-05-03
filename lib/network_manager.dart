import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

enum NetworkStatus { idle, hosting, discovering, connected }

class NetworkManager extends ChangeNotifier {
  MqttBrowserClient? client;
  NetworkStatus status = NetworkStatus.idle;
  String? connectedRoomPin;
  String myPlayerName = "";
  late String _clientId;

  // Callback for when data is received
  Function(Map<String, dynamic>)? onDataReceived;
  // Callback for when a player joins
  Function()? onPlayerConnected;

  NetworkManager() {
    _clientId = 'ttt_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
  }

  Future<void> connectToRoom(String pin, String name, bool isHost) async {
    myPlayerName = name;
    connectedRoomPin = pin;
    status = isHost ? NetworkStatus.hosting : NetworkStatus.discovering;
    notifyListeners();

    // Use a public MQTT broker (Free, no account needed)
    client = MqttBrowserClient('wss://broker.emqx.io/mqtt', _clientId);
    client!.port = 8084;
    client!.keepAlivePeriod = 20;
    client!.onConnected = () => _onConnected(isHost);
    client!.onDisconnected = _onDisconnected;
    
    // Auto-reconnect settings
    client!.autoReconnect = true;

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
      
      try {
        Map<String, dynamic> data = jsonDecode(payload);
        
        // Ignore our own messages using clientId instead of name
        if (data['cid'] != _clientId) {
          onDataReceived?.call(data);
          if (data['type'] == 'JOIN_ANNOUNCE') {
            onPlayerConnected?.call();
          }
        }
      } catch (e) {
        debugPrint("Error parsing MQTT data: $e");
      }
    });

    // CRITICAL: Delay the announcement to ensure the subscription is ready
    if (!isHost) {
      Timer(const Duration(milliseconds: 1000), () {
        sendData({'type': 'JOIN_ANNOUNCE'});
      });
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
      data['cid'] = _clientId; // Unique client ID to prevent self-echo
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

  void stopAll() => disconnect();
  Future<void> hostRoom(String pin, String name) => connectToRoom(pin, name, true);
  Future<void> joinRoom(String pin, String name) => connectToRoom(pin, name, false);
}
