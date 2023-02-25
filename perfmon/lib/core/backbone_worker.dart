import 'dart:convert';
import 'dart:io';

import 'package:perfmon/core/debug_data_model.dart';
import 'package:perfmon/core/settings.dart';
import 'package:perfmon/model/prefmon_events.dart';
import 'package:perfmon_logger/worker.dart';

class BackboneWorker {
  final DebugDataHandler dataHandler;
  final _settings = Settings();
  late Process _flutterRunner;
  LogCallback? logCallback;

  BackboneWorker(this.dataHandler);

  void start() async {
    final pathToYaml = File(_settings.pathToProject!);
    final workingDir = pathToYaml.parent.path;
    final cmd = _settings.flutterCommand!;
    final cmdParts = cmd.split(" ");

    _flutterRunner = await Process.start(
      "flutter",
      cmdParts.sublist(1),
      workingDirectory: workingDir,
      runInShell: Platform.isWindows || Platform.isLinux,
    );

    _flutterRunner.exitCode.then((value) {
      for (var callback in dataHandler.callbacks) {
        callback.call(Stopped());
      }
    });

    final encoding = utf8.decoder;
    log(Starting());
    _flutterRunner.stdout.listen((event) {
      final message = encoding.convert(event);
      logCallback?.call('LOG: $message');
    });
    _flutterRunner.stderr.listen((event) {
      final message = encoding.convert(event);
      logCallback?.call('ERROR: $message');
    });
  }

  void log(PerfMonEvent data) {
    for (var callback in dataHandler.callbacks) {
      callback.call(data);
    }
  }

  void stop() {
    _flutterRunner.kill();
    log(Stopped());
  }
}
