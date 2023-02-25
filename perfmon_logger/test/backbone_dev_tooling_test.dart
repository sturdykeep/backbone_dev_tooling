import 'package:flutter_test/flutter_test.dart';
import 'package:perfmon_logger/trace.dart';

void main() {
  test('test trace', () {
    final trace = Trace();
    var time = DateTime.fromMillisecondsSinceEpoch(0);
    trace.addLayer("A", time: time.add(const Duration(milliseconds: 1)));
    trace.addLayer("B");
    expect(trace.currentTracePath().length, 2);

    trace.addLayer("C", time: time);
    var result = trace.popLayer("C");
    expect(result.length, 1);
    expect(result.first.toString(), "C(0)");
    trace.addLayer("C");
    result = trace.popLayer("B");
    expect(result.length, 2);
    expect(trace.currentTracePath().length, 1);
    expect(trace.currentTracePath().first.toString(), "A(1)");
    trace.popLayer("A");
    expect(trace.currentTracePath().isEmpty, true);

    trace.addLayer("A", time: time);
    trace.addLayer("B", time: time.add(const Duration(milliseconds: 1)));
    final b = trace.popLayer("B").first;
    expect(b.differenceTo(time), const Duration(milliseconds: 1));
    final a = trace.popLayer("A").first;
    expect(b - a, const Duration(milliseconds: 1));
  });
}
