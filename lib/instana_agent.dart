/*
 * (c) Copyright IBM Corp. 2021
 * (c) Copyright Instana Inc. and contributors 2021
 */

import 'dart:async';

import 'package:flutter/services.dart';

/// Class providing all methods related to the setup and usage of the Instana Flutter agent
class InstanaAgent {
  static const MethodChannel _channel = const MethodChannel('instana_agent');

  /// Initializes Instana with a [key] and [reportingUrl] and optionally with SetupOptions
  ///
  /// Please run this as soon as possible in your app's lifecycle
  static Future<bool> setup(
      {required String key,
      required String reportingUrl,
      SetupOptions? options}) async {
    Map<String, dynamic> params = {
      'key': key,
      'reportingUrl': reportingUrl,
      'collectionEnabled': options?.collectionEnabled,
      'captureNativeHttp': options?.captureNativeHttp,
      'slowSendInterval': options?.slowSendInterval,
      'usiRefreshTimeIntervalInHrs': options?.usiRefreshTimeIntervalInHrs,
      'queryTrackedDomainList': options?.queryTrackedDomainList,
      'dropBeaconReporting': options?.dropBeaconReporting,
      'enableW3CHeaders': options?.enableW3CHeaders,
      'trustDeviceTiming': options?.trustDeviceTiming,
      'hybridAgentId': 'f',
      'hybridAgentVersion': '3.1.4'
    };
    if (options?.rateLimits != null) {
      // convert enum to integer for cross language boundary value passing
      params['rateLimits'] = options!.rateLimits!.index;
    }
    return await _channel.invokeMethod('setup', params);
  }

  /// Enable or disable collection (opt-in or opt-out)
  ///
  /// If needed, you can set collectionEnabled to false via Instana's setup and enable the collection later. (e.g. after giving the consent)
  /// Note: Any instrumentation is ignored when setting collectionEnabled to false.
  static Future<void> setCollectionEnabled(bool enable) async {
    await _channel.invokeMethod(
        'setCollectionEnabled', <String, dynamic>{'collectionEnabled': enable});
  }

  /// Returns unique ID assigned by Instana to current session
  ///
  /// SessionID will change every time the app cold-starts
  static Future<String?> getSessionID() async {
    return await _channel.invokeMethod('getSessionID', <String, dynamic>{});
  }

  /// Sets custom User ID which all new beacons will be associated with
  ///
  /// Max length: 128 characters
  static Future<void> setUserID(String? userID) async {
    await _channel
        .invokeMethod('setUserID', <String, dynamic>{'userID': userID});
  }

  /// Sets User name which all new beacons will be associated with
  ///
  /// Max length: 128 characters
  static Future<void> setUserName(String? name) async {
    await _channel
        .invokeMethod('setUserName', <String, dynamic>{'userName': name});
  }

  /// Sets User email which all new beacons will be associated with
  ///
  /// Max length: 128 characters
  static Future<void> setUserEmail(String? email) async {
    await _channel
        .invokeMethod('setUserEmail', <String, dynamic>{'userEmail': email});
  }

  /// Sets Human-readable name of logical view to which new beacons will be associated
  ///
  /// Max length: 256 characters
  static Future<void> setView(String? name) async {
    await _channel.invokeMethod('setView', <String, dynamic>{'viewName': name});
  }

  /// Sets Key-Value pair which all new beacons will be associated with
  ///
  /// Max Key Length: 98 characters
  ///
  /// Max Value Length: 1024 characters
  static Future<void> setMeta(
      {required String key, required String value}) async {
    await _channel
        .invokeMethod('setMeta', <String, dynamic>{'key': key, 'value': value});
  }

  /// Provide a List of String with regular expressions to redact values from the captured http query
  /// Example: "passwor(t|d)" to redact the password or passwort parameter
  ///
  /// Default: We redact all query values matching the parameter: key, secret, password (also myKey or Password)
  ///
  /// - Parameters:
  ///    - regex: List of String that is used for the redaction
  static Future<void> redactHTTPQuery({required List<String> regex}) async {
    await _channel.invokeMethod(
        'redactHTTPQuery', <String, dynamic>{'redactHTTPQueryRegEx': regex});
  }

  /// Sends a Custom Event beacon to Instana
  static Future<void> reportEvent(
      {required String name, EventOptions? options}) async {
    await _channel.invokeMethod('reportEvent', <String, dynamic>{
      'eventName': name,
      'startTime': options?.startTime?.toDouble(),
      'duration': options?.duration?.toDouble(),
      'viewName': options?.viewName,
      'meta': options?.meta,
      'backendTracingID': options?.backendTracingID,
      'customMetric': options?.customMetric
    });
  }

  ///
  /// Capture HTTP header fields by providing a list
  /// of regular expressions strings that match the HTTP field keys.
  ///
  /// Default: No HTTP header fields are captured. Keywords must be provided explicitly
  ///
  /// - Parameters:
  ///    - regex: List of String to capture matching HTTP header field keywords
  static Future<void> setCaptureHeaders({required List<String> regex}) async {
    await _channel
        .invokeMethod('setCaptureHeaders', <String, dynamic>{'regex': regex});
  }

  /// Mark the start of an HTTP Request
  ///
  /// Returns a [Marker] you can [finish()] to send a beacon to Instana
  static Future<Marker> startCapture(
      {required String url, required String method, String? viewName}) async {
    var currentView =
        await _channel.invokeMethod('getView', <String, dynamic>{});
    var markerId = await _channel.invokeMethod(
        'startCapture', <String, dynamic>{
      'url': url,
      'method': method,
      'viewName': viewName ?? currentView
    });
    return Marker(
        channel: _channel, id: markerId, viewName: viewName ?? currentView);
  }
}

/// This class can be used to manually track HTTP Requests
///
/// Please use the [startCapture()] method to obtain your [Marker]
class Marker {
  Marker(
      {required MethodChannel channel,
      required this.id,
      required this.viewName})
      : _channel = channel;

  final MethodChannel _channel;
  final String? id;
  final String? viewName;

  /// Response's HTTP Status Code
  int? responseStatusCode;

  /// Backend Trace ID obtained from the [BackendTracingIDParser.headerKey] header of the response
  ///
  /// You can use the included [BackendTracingIDParser.fromHeadersMap(headers)] method to extract it from the response
  ///
  /// This will be used to correlate backend requests and tracking beacons
  String? backendTracingID;

  /// Response's Header-size in bytes
  int? responseSizeHeader;

  /// Response's compressed Body-size in bytes
  int? responseSizeBody;

  /// Response's uncompressed Body-size in bytes
  int? responseSizeBodyDecoded;

  /// Response's error message
  String? errorMessage;

  /// Response's header (header name as map key, header value as map value)
  Map<String, String>? responseHeaders;

  /// Finishes the [Marker], triggering the generation and queueing of a HTTP tracking beacon
  Future<void> finish() async {
    await _channel.invokeMethod('finish', <String, dynamic>{
      'id': id,
      'responseStatusCode': responseStatusCode,
      'backendTracingID': backendTracingID,
      'responseSizeHeader': responseSizeHeader,
      'responseSizeBody': responseSizeBody,
      'responseSizeBodyDecoded': responseSizeBodyDecoded,
      'errorMessage': errorMessage,
      'responseHeaders': responseHeaders
    });
  }

  /// Cancels the [Marker], triggering the generation and queuing of a HTTP tracking beacon
  Future<void> cancel() async {
    await _channel.invokeMethod('cancel', <String, dynamic>{'id': id});
  }
}

/**
 * Rate-Limiter configuration for the maximum number of beacons allowed within specific time intervals:
 *
 * - `DEFAULT_LIMITS`:
 *     - 500 beacons per 5 minutes
 *     - 20 beacons per 10 seconds
 *
 * - `MID_LIMITS`:
 *     - 1000 beacons per 5 minutes
 *     - 40 beacons per 10 seconds
 *
 * - `MAX_LIMITS`:
 *     - 2500 beacons per 5 minutes
 *     - 100 beacons per 10 seconds
 */
enum RateLimits {
  DEFAULT_LIMITS,
  MID_LIMITS,
  MAX_LIMITS
}

class SetupOptions {
  ///  Enable or disable collection (instrumentation) on setup. Can be changed later via the property `collectionEnabled` (Default: true)
  bool collectionEnabled = true;

  ///  Enable or disable native http capture, ie. capture http made in Android (Kotlin/Java) or iOS (swift/Objective C) (Default: false)
  bool captureNativeHttp = false;

  ///  Enable slow send mode on beacon send failure if slowSendInterval is set to a positive number (Default: 0.0 means disabled)
  ///  In slow send mode, each time flutter-agent sends one beacon to server instead of a batch (maximum 100) of beacons.
  ///  If this beacon send succeeded, send mode is back to default pace. Otherwise beacon sending is kept in this slow mode.
  ///  Default beacon send interval is 2 seconds.
  ///  Unit of slowSendInterval is in seconds.
  ///  Slow send mode replaces traditional fail and retry approach.
  double slowSendInterval = 0.0;

  /// Enable user session id. Default value is -1.
  /// Negative value means user session id is enabled and remains unchanged after first creation.
  /// A positive number means user session id is refreshed (a new one is created) after that many hours.
  /// 0.0 means user session id is disabled.
  double usiRefreshTimeIntervalInHrs = -1.0;

  ///
  /// List of url domains which needs to be tracked with the query params.
  /// If any domain is provided all other URLs will be captured without query params.
  ///
  /// Default: No url domains are listed. All url parameters are tracked.
  ///
  /// Each string is treated as a regular expression.
  List<String> queryTrackedDomainList = [];

  /// collect and report dropped beacons (on behalf of rate limit) to Instana backend
  /// optional otherwise takes platform agent's configuration
  bool? dropBeaconReporting;

  /// configure rate limit of beacons sent to Instana backend
  /// optional otherwise takes platform agent's configuration
  RateLimits? rateLimits;

  /// When set to true, this option includes W3C-compliant headers in HTTP request headers,
  /// ensuring compatibility with W3C standards for tracing.
  bool? enableW3CHeaders;

  /// When enabled, the device's timestamp is used as-is by the backend.
  /// Otherwise, if the beacon reaches the backend more than 30 minutes late,
  /// its timestamp is overridden with the arrival time.
  /// This setting is optional; if not specified, the platform agent's configuration is used.
  bool? trustDeviceTiming;
}

/// This class contains all the options you can provide for the Custom Events reported through [InstanaAgent.reportEvent()]
class EventOptions {
  /// Start Time in milliseconds since epoch
  ///
  /// If not set, it will default to the time of creation of the beacon
  int? startTime;

  /// Duration in milliseconds
  ///
  /// If not set, it will default to 0
  int? duration;

  /// View name
  ///
  /// If not set, it will default to the View name set in [InstanaAgent.setView()]
  String? viewName;

  /// Maps of Key-Value pairs which this Custom Event will be associated with. This will not affect any other beacons
  ///
  /// Max Key Length: 98 characters
  ///
  /// Max Value Length: 1024 characters
  Map<String, String>? meta;

  /// Backend Trace ID to associate this Custom Event to
  String? backendTracingID;

  /// Custom Metric
  double? customMetric;
}

/// Helper class to make the manual extraction of the BackendTracingID easier
///
/// The BackendTracingID will be extracted from the [headerKey] header
class BackendTracingIDParser {
  static final String headerKey = "server-timing";
  static final RegExp headerValueRegex = RegExp("^.* ?intid;desc=([^,]+)?.*\$");

  /// Returns the BackendTracingID or null
  static String? fromHeadersMap(Map<String, String> headers) {
    var result;
    headers.forEach((key, value) {
      if (key.toLowerCase() == headerKey.toLowerCase()) {
        result = headerValueRegex.firstMatch(value)?.group(1);
      }
    });
    return result;
  }
}
