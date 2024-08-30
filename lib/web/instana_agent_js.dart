@JS('')

import 'dart:js_interop';

/// https://www.ibm.com/docs/en/instana-observability/current?topic=websites-javascript-agent-api

@JS('ineum')
external void ineum(String commandName, [JSAny? args1, JSAny? args2]);
