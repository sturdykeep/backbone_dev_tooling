import 'package:perfmon_logger/worker.dart';

typedef PrefMonMessageCallback = void Function(PerfMonEvent event);
typedef LogCallback = void Function(String message);

class Starting extends PerfMonEvent {
  Starting() : super("Starting", "Starting", null, null, null);
}

class Stopped extends PerfMonEvent {
  Stopped() : super("Stopped", "Stopped", null, null, null);
}
