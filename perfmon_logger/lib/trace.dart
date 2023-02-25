import 'dart:collection';

class Trace {
  final _path = Queue<TraceRecord>();

  void addLayer(String name, {DateTime? time}) {
    _path.add(TraceRecord(name, time ?? DateTime.now()));
  }

  Iterable<TraceRecord> popLayer(String name) {
    if (_path.last.name == name) {
      final popped = _path.removeLast();
      return [..._path, popped];
    }
    final path = <TraceRecord>[];
    if (_path.any((x) => x.name == name)) {
      while (_path.isNotEmpty) {
        final current = _path.removeLast();
        path.add(current);
        if (current.name == name) break;
      }
    }
    return path.reversed;
  }

  Iterable<TraceRecord> currentTracePath() {
    return _path.toList();
  }
}

class TraceRecord {
  final String name;
  final DateTime addTime;
  TraceRecord(this.name, this.addTime);

  @override
  String toString() {
    return "$name(${addTime.millisecondsSinceEpoch})";
  }

  Duration operator -(TraceRecord b) {
    return addTime.difference(b.addTime);
  }

  Duration differenceTo(DateTime time) {
    return time.difference(addTime);
  }
}
