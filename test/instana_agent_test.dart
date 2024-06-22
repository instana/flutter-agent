/*
 * (c) Copyright IBM Corp. 2021
 * (c) Copyright Instana Inc. and contributors 2021
 */

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instana_agent/instana_agent.dart';

void main() {
  const MethodChannel channel = MethodChannel('instana_agent');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
    const MethodChannel('instana_agent').setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'setup') {
        return true; // simulate a successful setup
      }
      if (methodCall.method == 'setCollectionEnabled') {
        // Verify that the correct parameters are passed
        expect(methodCall.arguments['collectionEnabled'], true);
      }
      if (methodCall.method == 'getSessionID') {
        // Verify that the correct parameters are passed
        return 'sessionID';
      }
      return null;
    });
  });

  // Remove mock after tests
  tearDown(() {
    const MethodChannel('instana_agent').setMockMethodCallHandler(null);
  });

  test('BackendTracingIDParser returns null when header is not present', () {
    var headers = {"key1": "value1", "key2": "value2"};
    expect(BackendTracingIDParser.fromHeadersMap(headers), null);
  });

  test('BackendTracingIDParser returns backendTracingID', () {
    var headers = {
      "key1": "value1",
      "key2": "value2",
      "server-timing": "intid;desc=backendTracingID"
    };
    expect(BackendTracingIDParser.fromHeadersMap(headers), "backendTracingID");
  });

  test('BackendTracingIDParser is case insensitive', () {
    var headers = {
      "key1": "value1",
      "key2": "value2",
      "Server-Timing": "intid;desc=backendTracingID"
    };
    expect(BackendTracingIDParser.fromHeadersMap(headers), "backendTracingID");
  });

  test('BackendTracingIDParser can handle strange values in inspected header',
      () {
    var headers = {
      "key1": "value1",
      "key2": "value2",
      "server-timing": "completely non-expected header value"
    };
    expect(BackendTracingIDParser.fromHeadersMap(headers), null);
  });

  test('setup should return true if key and url is valid', () async {
    // Call the setup method
    bool setupSuccessful = await InstanaAgent.setup(
        key: "validKey",
        reportingUrl: "http://valid.url",
        options: SetupOptions()
    );
    expect(setupSuccessful, true);
  });

  test('setCollectionEnabled should invoke the method with correct parameters', () async {
    // Call the setCollectionEnabled method
    await InstanaAgent.setCollectionEnabled(true);
  });

  test('getSessionID should return the ids', () async {
    // Call the setCollectionEnabled method
    InstanaAgent.getSessionID().then((value) => {
    expect(value, 'sessionID')
    });

  });





}
