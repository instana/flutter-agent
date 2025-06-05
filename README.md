# Instana agent for Flutter

**[Changelog](CHANGELOG.md)** |
**[Contributing](CONTRIBUTING.md)**

---

Instana agent allows Flutter apps to send monitoring data to Instana. 

## Requirements
- Flutter version 1.20.0+
- Dart version between 2.12.0 and 4.0.0

## Installation

The **Instana agent** Flutter package is available via [pub.dev](https://pub.dev/). 

You can add it to your app the same way as usual:

1. Open the `pubspec.yaml` file located inside the app folder, and add `instana_agent:` under `dependencies`.
2. Install it
From the terminal: Run `flutter pub get`
Or
    * From Android Studio/IntelliJ: Click **Packages get** in the action ribbon at the top of `pubspec.yaml`.
    * From VS Code: Click **Get Packages** located in right side of the action ribbon at the top of `pubspec.yaml`.

## Initialization

Import package in your dart file(s):

```dart
import 'package:instana_agent/instana_agent.dart';
```

Stop and restart the app, if necessary

Setup Instana once as soon as possible. For example, in `initState()`

```dart
@override
  void initState() {
    super.initState();
    InstanaAgent.setup(key: 'YOUR-INSTANA-KEY', reportingUrl: 'YOUR-REPORTING_URL');
  }
```

## Tracking View changes

At any point after initializing the Instana agent:

```dart
import 'package:instana_agent/instana_agent.dart';

[...]

InstanaAgent.setView('Home');
```

## Tracking HTTP requests

At any point after initializing the Instana agent:

```dart
import 'package:instana_agent/instana_agent.dart';

[...]

InstanaAgent.startCapture(url: 'https://example.com/success', method: 'GET').then((marker) => marker
    ..responseStatusCode = 200
    ..responseSizeBody = 1000
    ..responseSizeBodyDecoded = 2400
    ..finish());
```

We recommend creating your own `InstrumentedHttpClient` extending `http.BaseClient` as shown in this snippet, for example:

```dart
class _InstrumentedHttpClient extends BaseClient {
   _InstrumentedHttpClient(this._inner);

   final Client _inner;

   @override
   Future<StreamedResponse> send(BaseRequest request) async {
      final Marker marker = await InstanaAgent.startCapture(url: request.url.toString(), method: request.method);

      StreamedResponse response;
      try {
         response = await _inner.send(request);
         marker
            ..responseStatusCode = response.statusCode
            ..responseSizeBody = response.contentLength
            ..backendTracingID = BackendTracingIDParser.fromHeadersMap(response.headers)
            ..responseHeaders = response.headers;
      } finally {
         await marker.finish();
      }

      return response;
   }
}

class _MyAppState extends State<MyApp> {

   [...]

   Future<void> httpRequest() async {
      final _InstrumentedHttpClient httpClient = _InstrumentedHttpClient(Client());
      final Request request = Request("GET", Uri.parse("https://www.instana.com"));
      httpClient.send(request);
   }

   [...]
}
```

## Error handling

All of the agent's interfaces return an asynchronous `Future`. Error are wrapped in an exception of the [PlatformException type](https://api.flutter.dev/flutter/services/PlatformException-class.html).

We advice developers to follow the [common error-handling techniques for Futures](https://dart.dev/guides/libraries/futures-error-handling) and at least log any possible error.

For example:

```dart
InstanaAgent.setup(key: 'KEY', reportingUrl: 'REPORTING_URL')
    .catchError((e) => 
            log("Captured PlatformException during Instana setup: $e")
        );
```

Or similarly in async functions:

```dart
try {
  var result = await InstanaAgent.setup(key: 'KEY', reportingUrl: 'REPORTING_URL');
} catch (e) {
log("Captured PlatformException during Instana setup: $e");
}
```

## How to enable native http capture
Since flutter-agent version 2.5.0, we are able to capture http calls made inside iOS platform (in Swift or Objective C language) and Android platform (in Kotlin or Java language) though by default it's disabled.
Please make changes to your Instana setup call like following:
```dart
@override
void initState() {
   super.initState();

   var options = SetupOptions();
   options.collectionEnabled = true;
   options.captureNativeHttp = true;
   InstanaAgent.setup(key: 'YOUR-INSTANA-KEY', reportingUrl: 'YOUR-REPORTING_URL', options: options);
}
```

#### For Android platform, also make following 2 changes:

1. In project level build.gradle file, add **android-agent-plugin** to classpath section.
```groovy
buildscript {
    ext.native_instana_version = '6.2.1' //version must be same as the android-agent version used by flutter-agent
    // other setups here
    dependencies {
        // other classpaths here
        classpath "com.instana:android-agent-plugin:$native_instana_version"
    }
}
```

2. In app level build.gradle file, apply android-agent-plugin **before** applying flutter.gradle.
```groovy
apply plugin: 'com.instana.android-agent-plugin'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"
```

## How to enable http auto capture
Since flutter-agent version 2.6.0, we are able to auto capture http calls made within Dart. Set your HttpOverrides.global like following:
```dart
@override
void main() {
   HttpOverrides.global = InstanaHttpOverrides();
   runApp(const MyApp());
}
```
If you already have your own version of HttpOverrides for other purpose, please merge the functionality of InstanaHttpOverrides class with your class and maintain the combined class by yourself. Chain in multiple HttpOverrides is error prone.
You can also analyze InstanaHttpOverrides class, create your own HttpOverrides class to do what InstanaHttpOverrides class is doing instead of calling InstanaHttpOverrides().

If you enable http auto capture, stop using above sample code like InstanaAgent.startCapture(), _InstrumentedHttpClient() otherwise double capture will occur. Sure InstanaAgent.setup() is always needed.

## More

The complete documentation for this package, including `custom events` and others can be found within [Instana's public documentation page](https://www.ibm.com/docs/en/instana-observability/current?topic=applications-flutter-monitoring-api)

Please also check out the [Flutter example](https://github.com/instana/flutter-agent/tree/main/example) in this repository for a simple usage demonstration.
