import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:perfmon_logger/trace.dart';
import 'package:web_socket_client/web_socket_client.dart';

@pragma('vm:entry-point')
Future<void> perfMonReport(SendPort p) async {
  // Send a SendPort to the main isolate so that it can send JSON strings to
  // this isolate.
  final commandPort = ReceivePort();
  p.send(commandPort.sendPort);
  final trace = Trace();
  late final WebSocket socket;
  // Create a WebSocket client.
  await for (final message in commandPort) {
    if (message is String) {
      final wsHost = message.toString();
      socket = WebSocket(Uri.parse(wsHost.toString()));
      await socket.connection.firstWhere((state) => state is Connected);
      debugPrint('perfMonReport isolate is ready and connected');
    }

    try {
      final workerEvent = message as WorkerEvent;
      if (workerEvent.eventType == "addEvent" ||
          workerEvent.eventType == "addSample") {
        socket.send(
          jsonEncode(PerfMonEvent(
            workerEvent.eventType,
            workerEvent.name,
            workerEvent.payload,
            workerEvent.milliseconds,
            workerEvent.frame,
          ).toJson()),
        );
      } else if (workerEvent.eventType == "startTrace") {
        trace.addLayer(workerEvent.name, time: workerEvent.creationTime);
      } else if (workerEvent.eventType == "endTrace") {
        final result = trace.popLayer(workerEvent.name);
        if (result.isNotEmpty) {
          final lastTime = result.last.differenceTo(workerEvent.creationTime);
          final payload = result.fold(
              "",
              (previousValue, element) =>
                  "$previousValue${previousValue.isNotEmpty ? "->" : ""}$element");
          socket.send(
            jsonEncode(PerfMonEvent(
              "trace",
              workerEvent.name,
              payload,
              lastTime.inMilliseconds,
              workerEvent.frame,
            ).toJson()),
          );
        }
      } else {
        debugPrint('Unkown event type send');
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }
  Isolate.exit();
}

class PerfMonEvent {
  final String eventType;
  final String name;
  final String? payload;
  final int? milliseconds;
  final int? frame;

  PerfMonEvent(
    this.eventType,
    this.name,
    this.payload,
    this.milliseconds,
    this.frame,
  );

  static PerfMonEvent fromJson(Map<String, dynamic> json) {
    return PerfMonEvent(
      json["eventType"],
      json["name"],
      json["payload"],
      json["milliseconds"],
      json["frame"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "eventType": eventType,
      "name": name,
      "payload": payload,
      "milliseconds": milliseconds,
      "frame": frame,
    };
  }
}

class WorkerEvent {
  final String name;
  final String? payload;
  final int? milliseconds;
  final DateTime creationTime;
  final String eventType;
  final int? frame;

  WorkerEvent(this.name, this.payload, this.creationTime, this.eventType,
      this.milliseconds, this.frame);
  WorkerEvent.addEvent(
    this.name,
    this.payload,
    this.creationTime, {
    this.eventType = "addEvent",
    this.milliseconds,
    this.frame,
  });
  WorkerEvent.addSample(
    this.name,
    this.creationTime,
    this.milliseconds, {
    this.eventType = "addSample",
    this.payload,
    this.frame,
  });
  WorkerEvent.startTrace(
    this.name,
    this.creationTime, {
    this.eventType = "startTrace",
    this.payload,
    this.milliseconds,
    this.frame,
  });
  WorkerEvent.endTrace(
    this.name,
    this.creationTime, {
    this.eventType = "endTrace",
    this.payload,
    this.milliseconds,
    this.frame,
  });
}
