/*
 * (c) Copyright IBM Corp. 2021
 * (c) Copyright Instana Inc. and contributors 2021
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instana_agent/instana_agent.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'Constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? timer = null;

  @override
  void initState() {
    super.initState();

    /// Initializes Instana. Must be run only once as soon as possible in the app's lifecycle
    setupInstana();
  }

  void periodicInjection(int durationInMinutes, int intervalInMilliSeconds) {
    disposeWebviewInjectionTimer();

    timer = Timer.periodic(Duration(milliseconds: intervalInMilliSeconds), (timer) {
      print("Running Injection");
      controller.runJavaScript(scriptWeasel);
      if ((timer.tick * intervalInMilliSeconds) >=
          (durationInMinutes * 60 * 1000)) {
        disposeWebviewInjectionTimer();
      }
    });
  }

  void setupInstana() async {
    SetupOptions options = SetupOptions();
    options.captureNativeHttp = true;
    bool ret = await InstanaAgent.setup(
        key: '<INSTANA_MOBILE_KEY>',
        reportingUrl: '<REPORTING_URL>/mobile',
        options: options);
    if (!ret) {
      // Error handling here
      if (kDebugMode) {
        print("InstanaAgent setup failed");
      }
    }
    await InstanaAgent.setView('Home');
  }

  @override
  Widget build(BuildContext context) {
    controller.currentUrl().then((value) async =>
        await InstanaAgent.startCapture(url: value.toString(), method: 'GET')
            .then((value) => value.finish()));
    controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {
          controller.runJavaScript(scriptWeasel);
          periodicInjection(5, 500);
          print("URLs onPageStarted: $url");
        },
        onPageFinished: (String url) {
          disposeWebviewInjectionTimer();
          controller.runJavaScript(scriptWeasel); //best place to inject javascript
          print("URLs onPageFinished: $url");
        },
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) async {
          controller.runJavaScript(scriptWeasel);
          print("URLs onNavigationRequest: ${request.url}");
          if (request.url.toString() != "about:blank") {
            await InstanaAgent.reportEvent(
                name: "${request.url}",
                options: EventOptions()
                  ..viewName = 'webView'
                  ..startTime = DateTime.now().millisecondsSinceEpoch
                  ..duration = 0);
          }
          return NavigationDecision.navigate;
        },
      ),
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8.0),
                      textStyle:
                          const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    onPressed: () {
                      controller.goBack();
                    },
                    child: Text("back")),
                Container(
                  width: double.infinity,
                  height: 550.0,
                  child: WebViewWidget(
                    controller: controller,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    disposeWebviewInjectionTimer();
    super.dispose();
  }

  void disposeWebviewInjectionTimer() {
    timer?.cancel();
    timer = null;
  }
}
