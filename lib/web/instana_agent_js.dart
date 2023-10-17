@JS('')

import 'package:js/js.dart';

/// https://www.ibm.com/docs/en/instana-observability/current?topic=websites-javascript-agent-api

@JS('ineum')
external void ineum(String commandName, [Object args1, Object args2]);
