import 'package:backbone/logging/log.dart';
import 'package:perfmon_logger/platform/perfmon_logger_stub.dart'
    if (dart.library.io) 'package:perfmon_logger/platform/perfmon_logger_io.dart'
    if (dart.library.html) 'package:perfmon_logger/platform/perfmon_logger_web.dart';

class PerfmonLogger extends Log {
  final PerfMonLogImpl _logger;
  PerfmonLogger({String host = "ws://localhost:8080"})
      : _logger = PerfMonLogImpl(host: host);

  @override
  void addEvent(String event, {String? payload, int? frame}) {
    _logger.addEvent(event, payload: payload, frame: frame);
  }

  @override
  void addSample(String key, int milliseconds, {int? frame}) {
    _logger.addSample(key, milliseconds, frame: frame);
  }

  @override
  void endTrace(String trace, {int? frame}) {
    _logger.endTrace(trace, frame: frame);
  }

  @override
  void startTrace(String trace) {
    _logger.startTrace(trace);
  }
}
