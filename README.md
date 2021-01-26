# Instana agent for Flutter

**[Changelog](CHANGELOG.md)** |
**[Contributing](CONTRIBUTING.md)**

---

## Installation

The **Instana agent** Flutter package is available via [pub.dev](https://pub.dev/). 

You can add it to your app the same way as usual:

1. Open the `pubspec.yaml` file located inside the app folder, and add `instana_agent:` under `dependencies`.
2. Install it
From the terminal: Run `flutter pub get`
Or
    * From Android Studio/IntelliJ: Click **Packages get** in the action ribbon at the top of `pubspec.yaml`.
    * From VS Code: Click **Get Packages** located in right side of the action ribbon at the top of `pubspec.yaml`.

## Usage

Import package in your dart file(s)
```dart
import 'package:instana_agent/instana_agent.dart';
```
Stop and restart the app, if necessary

## Setup
Setup Instana once as soon as possible. 

For example, in `initState()`

```dart
@override
  void initState() {
    super.initState();
    InstanaAgent.setup(key: 'YOUR-INSTANA-KEY', reportingUrl: 'YOUR-REPORTING_URL');
  }
```

## More

The complete documentation for this package can be found in: [Instana Flutter API](https://www.instana.com/docs/mobile_app_monitoring/flutter_api) 

Please also check out the [Flutter example](https://github.com/instana/flutter-agent/tree/main/example) in this repository for a simple usage demonstration.
