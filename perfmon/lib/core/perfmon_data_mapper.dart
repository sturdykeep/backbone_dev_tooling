import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:perfmon_logger/worker.dart';

class PerfmonDataMapper {
  static const String startTag = 'prefmon:';
  static const String endTag = ':prefmon';

  static PerfMonEvent? parse(String message) {
    try {
      final json = jsonDecode(message);
      return PerfMonEvent.fromJson(json);
    } catch (ex) {
      debugPrint(message);
    }

    return null;
  }
}
