# Changelog

## 3.1.2
- Removed jvmToolchain dependency of Java language 8

## 3.1.1
- Added namespace support for gradle 8.0+
- Support W3C trace context headers configuration
- Support rate limits configuration
- Support queryTrackedDomainList
- Upgrade iOSAgent to 1.9.1, memory leak fix
- Upgrade android-agent to 6.2.1, error handling for root-level casting issues
- Fixed issue with inaccurate start time in HTTP requests for android-agent

## 3.1.0
- Upgrade iOSAgent to 1.8.3, minimum supported iOS version increased from 11 to 12
- Upgrade android-agent to 6.0.19, Error Type added to crash beacons

## 3.0.9
- Upgrade iOSAgent to 1.8.2, HTTPCaptureResult tracks http status code along with error message
- Upgrade android-agent to 6.0.18

## 3.0.8
- Added screen name auto capture methods

## 3.0.7
- CustomMetric field support in reportEvent method
- Upgrade iOSAgent to 1.6.9, android-agent to 6.0.14

## 3.0.6
- Pass flutter-agent id and version down to iOSAgent and android-agent
- Upgrade iOSAgent to 1.6.8, android-agent to 6.0.12

## 3.0.5
- Support user session id by upgrading iOSAgent to 1.6.5, android-agent to 6.0.6

## 3.0.4
- Upgrade Android agent to 6.0.5 which fixed duplicated beacons issue

## 3.0.3
- Report http timeout error to Instana backend in InstanaHttpOverrides
- Upgrade iOS agent to 1.6.4 which fixed http response header capture issue

## 3.0.2
- Add new feature to redact password, key, secrets from HTTP query parameters
- Upgrade iOS agent to 1.6.3 which fixed duplicated beacons issue

## 3.0.1
- Remove print in code since it conflicts with some linter rules
- Upgrade iOS agent to 1.6.2 which improves slow send mode
- Update flutter sdk constraint to '>=2.12.0 <4.0.0'

## 3.0.0
- Upgrade android-agent to 6.0.3 which allows Java/Kotlin http capture for Google Ads

## 2.7.2
- Use android-agent 5.2.7 which allows Java/Kotlin http capture for Google Ads

## 2.7.1
- Upgrade android-agent to 6.0.2 which improves error handling on beacon send failure

## 2.7.0
- Upgrade iOS agent to 1.6.1 which improves error handling on beacon send failure

## 2.6.0
- Add InstanaHttpOverrides class to auto capture http calls made in Dart

## 2.5.0
- Support native http capture (Kotlin/Java for Android, swift/ObjectiveC for iOS)
- Upgrade example app Android platform AGP to version 7.3.1

## 2.4.1
- Update native Android agent to version 5.2.4
- Update CocoaPods's specs to match with iOS native agent version 1.5.2
- Fix example app for newer version flutter

## 2.4.0
- Update native Android agent to version 5.2.3
- Update native iOS agent to version 1.5.2

## 2.3.2
- Update native Android agent to version 5.1.0

## 2.3.1
- Update native iOS agent to version 1.3.1

## 2.3.0
- Fix custom error message
- Update dependency libs 

## 2.2.0
- Use iOS agent version 1.3.0

## 2.1.2
- Update native iOS agent to version 1.2.4

## 2.1.1
- Update native iOS agent to version 1.2.2

## 2.1.0
- Update native iOS and Android Instana agents
- Introduce collectionEnabled flag to disable or enable the agent after the setup process

## 2.0.4
* iOS native agent version 1.1.18 

## 2.0.3
* iOS native agent version 1.1.15

## 2.0.2
* iOS native agent version 1.1.13
* Android native agent version 1.5.6

## 2.0.1

* Android native agent version 1.5.5
* iOS native agent version 1.1.12

## 2.0.0

* Add support for Flutter 2
* Migrate to null safety
* Android native agent version 1.5.3

## 1.0.1

* Fix Android compilation issue
* iOS native agent version 1.1.11

## 1.0.0

* First release of the Instana agent for Flutter, based on
  * Android native agent version 1.5.1
  * iOS native agent version 1.1.10
