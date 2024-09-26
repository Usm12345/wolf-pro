import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wolfpak/oop/product.dart';

const topics = [
  'temp',
  'status',
  'bat/soc',
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
  'poe/current',
  'inverter/state',
  'usb/state',
  'cig/state',
  'poe/state',
];

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  final Map<String, ValueNotifier<String>> _topicNotifiers = {};

  MqttServerClient? client;

  late String clientIdentifier;

  Future<void> connect(List<Product> products) async {
    if (client != null) {
      if (client!.connectionStatus!.state == MqttConnectionState.connected) {
        return;
      }
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String email = prefs.getString("userEmail")!;
    clientIdentifier = email;

    client = MqttServerClient('13.61.24.149', '');
    client!.port = 1883;

    client!.secure = false;
    client!.keepAlivePeriod = 600;
    client!.autoReconnect = true;
    client!.resubscribeOnAutoReconnect = true;

    client!.onConnected = () {
      subscribeToTopics(products);
      startListening();

      Fluttertoast.showToast(
        msg: "MQTT connected.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    };

    client!.onDisconnected = () {
      Fluttertoast.showToast(
        msg: "MQTT disconnected.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    };

    client!.onAutoReconnected = () {
      Fluttertoast.showToast(
        msg: "MQTT reconnected.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    };

    const uuid = Uuid();
    final clientIdentifierDU =
        "$clientIdentifier.${uuid.v4().replaceAll('-', '')}";

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifierDU)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
    } catch (e) {
      client!.disconnect();
    }
  }

  void subscribeToTopics(List<Product> products) {
    for (var product in products) {
      for (var topic in topics) {
        if (!_topicNotifiers.containsKey(topic)) {
          topic = '${product.name}/$topic';
          _topicNotifiers[topic] = ValueNotifier<String>('0.0');
          client!.subscribe(topic, MqttQos.atMostOnce);
        }
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
