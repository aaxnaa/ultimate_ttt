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

  Function(Map<String, dynamic>)? onDataReceived;

  NetworkManager() {
    _clientId = 'ttt_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
  }

  Future<void> connectToRoom(String pin, String name, bool isHost) async {
    myPlayerName = name;
    connectedRoomPin = pin;
    status = isHost ? NetworkStatus.hosting : NetworkStatus.discovering;
    notifyListeners();

    // Use a unique room topic version to avoid collisions with old session data
    client = MqttBrowserClient('wss://broker.emqx.io/mqtt', _clientId);
    client!.port = 8084;
    client!.keepAlivePeriod = 20;
    client!.onConnected = () => _onConnected(isHost);
    client!.onDisconnected = _onDisconnected;
    client!.autoReconnect = true;
    client!.resubscribeOnAutoReconnect = true;

    try {
      await client!.connect();
    } catch (e) {
      debugPrint('MQTT Connection failed: $e');
      disconnect();
    }
  }

  void _onConnected(bool isHost) {
    status = NetworkStatus.connected;
    final topic = 'ultimate_ttt_v25_room_$connectedRoomPin';
    client!.subscribe(topic, MqttQos.atLeastOnce);

    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      
      try {
        Map<String, dynamic> data = jsonDecode(payload);
        if (data['cid'] != _clientId) {
          onDataReceived?.call(data);
        }
      } catch (e) {
        debugPrint("Error parsing MQTT data: $e");
      }
    });

    // HANDSHAKE V2.5: Host doesn't need to do anything, Joiner requests state
    if (!isHost) {
      Timer(const Duration(milliseconds: 1500), () {
        sendData({'type': 'JOIN_REQ', 'name': myPlayerName});
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
      data['cid'] = _clientId;
      data['ts'] = DateTime.now().millisecondsSinceEpoch; // Timestamp for ordering
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(data));
      client!.publishMessage('ultimate_ttt_v25_room_$connectedRoomPin', MqttQos.atLeastOnce, builder.payload!);
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
