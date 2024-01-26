# Contributing

## How to Contribute

This is an open source project, and we appreciate your help!

Each source file must include this license header:

```
/*
 * (c) Copyright IBM Corp. 2024
 */
```

Furthermore you must include a sign-off statement in the commit message.

> Signed-off-by: John Doe <john.doe@example.com>

### Please note that in the case of the below-mentioned scenarios, follow the specified steps:
- **Proposing New Features**: Vist the ideas portal for [Cloud Management and AIOps](https://automation-management.ideas.ibm.com/?project=INSTANA) and post your idea to get feedback from IBM. This is to avoid you wasting your valuable time working on a feature that the project developers are not interested in accepting into the code base.
- **Raising a Bug**: Please visit [IBM Support](https://www.ibm.com/mysupport/s/?language=en_US) and open a case to get help from our experts.
- **Merge Approval**: The codeowners use LGTM (Looks Good To Me) in comments on the code review to indicate acceptance. A change requires LGTMs from two of the members. Request review from @instana/eng-eum for approvals.

Thank you for your interest in the Instana Flutter project!

## Building Instana Agent for Flutter

The example app included in this project will always use the `instana_agent` package contained in this repository. 

The steps to build the code into a package and run the example with it remain as simple as:

1. Install [flutter](https://flutter.dev/docs/get-started/install) 
2. Clone this repository
3. Go to the example folder
4. Use the terminal to start flutter with `flutter run`

## Release Process

We follow [Semantic Versioning 2.0](https://semver.org/).

Steps:
1. Update [CHANGELOG.md](./CHANGELOG.md) with the new version. Note, there might be existing version which is not published in the file, run a cross check with last released git tag to decide the actual version to be published.
2. Update [pubspec.yaml](./pubspec.yaml) with the new version
4. Commit and push the change
5. Create release tag
6. Run `flutter pub publish --dry-run` to verify all is good
7. Run `flutter pub publish` to publish


For more info, please check the [Flutter docs for Publishing Packages](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#publish) and the [Dart docs for Publishing Packages](https://dart.dev/tools/pub/publishing).
