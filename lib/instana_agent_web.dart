// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:instana_agent/web/instana_agent_js.dart';
import 'package:js/js_util.dart';

/// A web implementation of the InstanaAgent plugin.
///
/// https://www.ibm.com/docs/en/instana-observability/current?topic=websites-javascript-agent-api
class InstanaAgentPlugin {
  static late MethodChannel _channel;

  static void registerWith(Registrar registrar) {
    _channel = MethodChannel(
      'instana_agent',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = InstanaAgentPlugin();
    _channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    print(call.toString());
    var args = jsonDecode(jsonEncode(call.arguments));
    switch (call.method) {
      case 'setup':
        return true;
      case 'setCollectionEnabled':
        return true;
      case 'setUserID':
        return ineum('user', args['userID']);
      case 'setMeta':
        final key = args['key'];
        final value = args['value'];
        return ineum('meta', key, value);
      case 'setView':
        return ineum('page', args['viewName']);
      case 'reportEvent':
        return ineum(
          'reportEvent',
          args['eventName'],
          jsify({
            'timestamp': args['startTime'],
            'duration': args['duration'],
            'backendTraceId': args['backendTracingID'],
            'error': null,
            'componentStack': null,
            'meta': args['meta'],
          }),
        );
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              "The instana_agent plugin for web doesn't implement the method '${call.method}'",
        );
    }
  }
}
