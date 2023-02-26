library perfmon_logger;

import 'package:backbone/logging/log.dart';

/*
    TODO: Import this file conditionally for native/web
          On the web, replace Isolate with Web Worker
          Try to compile dart business code to JS 
          Use the JS result in Web Worker
*/

abstract class PerfMonLogBase extends Log {}
