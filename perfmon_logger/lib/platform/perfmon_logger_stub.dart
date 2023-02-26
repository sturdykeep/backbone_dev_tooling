import 'package:perfmon_logger/platform/perfmon_logger_base.dart';

class PerfMonLogImpl extends PerfMonLogBase {
  PerfMonLogImpl({String host = "ws://localhost:8080"});

  @override
  void addEvent(String event, {String? payload, int? frame}) {
    throw Exception("Stub implementation");
  }

  @override
  void addSample(String key, int milliseconds, {int? frame}) {
    throw Exception("Stub implementation");
  }

  @override
  void endTrace(String trace, {int? frame}) {
    throw Exception("Stub implementation");
  }

  @override
  void startTrace(String trace) {
    throw Exception("Stub implementation");
  }
}
