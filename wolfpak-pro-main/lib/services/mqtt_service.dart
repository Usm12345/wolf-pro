import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const topics = [
  'bat/voltage',
  'bat/current',
  'solar/voltage',
  'solar/current',
  'inverter/voltage',
  'inverter/current',
  'usb/voltage',
  'usb/current',
  'cig/voltage',
  'cig/current',
  'poe/voltage',
  'poe/current'
];

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  final Map<String, ValueNotifier<String>> _topicNotifiers = {};

  MqttServerClient? client;

  late String clientIdentifier;

  void connect() async {
    if (client != null) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String email = prefs.getString("userEmail")!;
    clientIdentifier =
        utf8.encode(email).map((e) => e.toRadixString(13)).join();

    client = MqttServerClient('broker.hivemq.com', '');
    client!.port = 1883;

    client!.secure = false;
    client!.keepAlivePeriod = 60;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
      _subscribeToTopics();
      startListening();
    } catch (e) {
      client!.disconnect();
    }
  }

  void _subscribeToTopics() {
    for (var topic in topics) {
      if (!_topicNotifiers.containsKey(topic)) {
        topic = '/$clientIdentifier/$topic';
        print('subscribing to $topic');
        _topicNotifiers[topic] = ValueNotifier<String>('0.0');
        client!.subscribe(topic, MqttQos.atMostOnce);
      }
    }
  }

  void startListening() {
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final topic = c[0].topic;

      if (_topicNotifiers.containsKey(topic)) {
        _topicNotifiers[topic]!.value = payload;
        print('$topic: payload');
      }
    });
  }

  ValueNotifier<String>? getNotifierForTopic(String topic) {
    return _topicNotifiers[topic];
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client?.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void disconnect() {
    client?.disconnect();
  }
}
