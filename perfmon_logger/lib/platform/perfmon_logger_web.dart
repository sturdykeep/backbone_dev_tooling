import 'package:flutter/foundation.dart';
import 'package:perfmon_logger/platform/perfmon_logger_base.dart';
import 'package:perfmon_logger/trace.dart';
import 'package:perfmon_logger/worker.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

/// Log to PrefMon via websocket
class PerfMonLogImpl extends PerfMonLogBase {
  Worker? worker;
  final trace = Trace();

  PerfMonLogImpl({String host = "ws://localhost:8080"}) {
    init(host);
  }

  Future<void> init(String host) async {
    worker = Worker("worker.js");
    worker!.postMessage(host);
    debugPrint('Logger (web) is ready');
  }

  @override
  void addEvent(String event, {String? payload, int? frame}) {
    final data = WorkerEvent.addEvent(
      event,
      payload,
      DateTime.now(),
      frame: frame,
    );
    _handle(data);
  }

  @override
  void addSample(String key, int milliseconds, {int? frame}) {
    final data = WorkerEvent.addSample(
      key,
      DateTime.now(),
      milliseconds,
      frame: frame,
    );
    _handle(data);
  }

  @override
  void endTrace(String trace, {int? frame}) {
    final data = WorkerEvent.endTrace(
      trace,
      DateTime.now(),
      frame: frame,
    );
    _handle(data);
  }

  @override
  void startTrace(String trace) {
    final data = WorkerEvent.startTrace(
      trace,
      DateTime.now(),
    );
    _handle(data);
  }

  void _handle(WorkerEvent workerEvent) {
    if (workerEvent.eventType == "addEvent" ||
        workerEvent.eventType == "addSample") {
      _send(
        PerfMonEvent(
          workerEvent.eventType,
          workerEvent.name,
          workerEvent.payload,
          workerEvent.milliseconds,
          workerEvent.frame,
        ),
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
        _send(
          PerfMonEvent(
            "trace",
            workerEvent.name,
            payload,
            lastTime.inMilliseconds,
            workerEvent.frame,
          ),
        );
      }
    } else {
      debugPrint('Unkown event type send');
    }
  }

  void _send(PerfMonEvent event) {
    if (worker == null) return;
    worker!.postMessage(event.toJson());
  }
}
