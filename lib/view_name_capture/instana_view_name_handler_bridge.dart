import 'package:flutter/services.dart';
import 'package:instana_agent/instana_agent.dart';

class InstanaViewNameHandler {

  static void updateScreenName({
    required String screenName,
    Map<String, String>? viewMeta = null
  }) {

    _InternalMetaUpdater._clearInternalMeta();
    viewMeta?.forEach((key, value) {
      _InternalMetaUpdater._setInternalMeta(key: key,value: value);
    });
    InstanaAgent.setView(screenName);
  }

}

/// Internal use only!
/// Completely restricting these APIs from being consumed by anyone with agent dependency
class _InternalMetaUpdater{
  static const MethodChannel _channel = const MethodChannel('instana_agent');

  /// Sets Internal-Meta for agent's internal use-cases
  ///
  /// Max length: 128 characters
  static Future<void> _setInternalMeta({required String key, required String value}) async{
    await _channel.invokeMethod('setInternalMeta', <String, dynamic>{'key': key, 'value': value});
  }

  /// Clear internalMeta values
  static Future<void> _clearInternalMeta() async {
    await _channel.invokeMethod('clearInternalMeta');
  }
}
