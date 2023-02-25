library perfmon_logger;

import 'dart:async';
import 'dart:isolate';
import 'package:async/async.dart';
import 'package:backbone/logging/log.dart';
import 'package:flutter/foundation.dart';
import 'package:perfmon_logger/worker.dart';

/*
    TODO: Import this file conditionally for native/web
          On the web, replace Isolate with Web Worker
          Try to compile dart business code to JS 
          Use the JS result in Web Worker
*/

/// Log to PrefMon via websocket
class PerfMonLog extends Log {
  SendPort? sendPort;

  PerfMonLog({String host = "ws://localhost:8080"}) {
    init(host);
  }

  Future<void> init(String host) async {
    final p = ReceivePort();
    await Isolate.spawn(perfMonReport, p.sendPort);
    final events = StreamQueue<dynamic>(p);
    sendPort = await events.next;
    sendPort!.send(host);
    debugPrint('Logger is ready');
  }

  @override
  void addEvent(String event, {String? payload, int? frame}) {
    if (sendPort == null) return;
    sendPort!.send(
      WorkerEvent.addEvent(
        event,
        payload,
        DateTime.now(),
        frame: frame,
      ),
    );
  }

  @override
  void addSample(String key, int milliseconds, {int? frame}) {
    if (sendPort == null) return;
    sendPort!.send(WorkerEvent.addSample(
      key,
      DateTime.now(),
      milliseconds,
      frame: frame,
    ));
  }

  @override
  void endTrace(String trace, {int? frame}) {
    if (sendPort == null) return;
    sendPort!.send(
      WorkerEvent.endTrace(
        trace,
        DateTime.now(),
        frame: frame,
      ),
    );
  }

  @override
  void startTrace(String trace) {
    if (sendPort == null) return;
    sendPort!.send(
      WorkerEvent.startTrace(
        trace,
        DateTime.now(),
      ),
    );
  }
}
