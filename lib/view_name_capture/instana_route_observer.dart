import 'package:flutter/material.dart';
import 'package:instana_agent/view_name_capture/instana_view_name_handler_bridge.dart';

typedef ScreenNameExtractor = String? Function(RouteSettings settings);

String? defaultNameExtractor(RouteSettings settings) => settings.name;

/// [RouteFilter] helps filter routes that should not be tracked.
///
/// By default, only [PageRoute]s are tracked. you can provide your
/// custom Filter logic via constructor if needed.
typedef RouteFilter = bool Function(Route<dynamic>? route);

bool defaultRouteFilter(Route<dynamic>? route) => route is PageRoute;

class InstanaScreenNameObserver extends RouteObserver<ModalRoute<dynamic>> {
  final BuildContext? buildContext;
  final ScreenNameExtractor screenNameExtractor;
  final RouteFilter routeFilter;

  ///
  /// When the [NavigatorObserver] sends the events with the currently active [ModalRoute] changes (push/pop),
  /// Instana will extract the screen name from [RouteSettings] using [ScreenNameExtractor].
  ///
  /// You can customise the way in which the name should be extracted by providing a custom [ScreenNameExtractor]
  /// with the constructor. If the [BuildContext] is not provided with [InstanaScreenNameObserver] constructor, Instana will not try
  /// to extract names from the active Widget's name/ child/ child's title.
  ///
  ///
  /// For usage, add it to the `navigatorObservers` of your [Navigator],
  /// For Eg:
  /// ```dart
  /// MaterialApp(
  ///   home: Home(),
  ///   navigatorObservers: [
  ///     InstanaScreenNameObserver(buildContext),
  ///   ],
  /// );
  /// ```
  InstanaScreenNameObserver({
    this.buildContext = null,
    this.screenNameExtractor = defaultNameExtractor,
    this.routeFilter = defaultRouteFilter
  });

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateScreenName(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && routeFilter(newRoute)) {
      _updateScreenName(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _updateScreenName(route);
  }

  void _updateScreenName(Route<dynamic> route) {
    /// Default way of taking route names this will collect screen
    /// names when there is named routes provided
    Map<String,String> viewTakenFrom = Map();
    String? screenName = screenNameExtractor(route.settings);
    if(screenName!=null) viewTakenFrom[ScreenAttributes.SETTINGS_ROUTE.value] = screenName;

    /// Instana allows to advance way to collect the screen names from
    /// widgets, child root titles if the named route is not available
    if (screenNameExtractor == defaultNameExtractor &&
        buildContext != null &&
        screenName == null
    ) {
      if (route is MaterialPageRoute) {
        final WidgetBuilder? builder = route.builder;
        final dynamic widget = builder != null ? builder(buildContext!) : null;

        try {
          screenName = route.builder(buildContext!).toString();
          viewTakenFrom[ScreenAttributes.WIDGET_NAME.value] = screenName;
          if (widget.child != null) {
            screenName = widget.child.toString();
            viewTakenFrom[ScreenAttributes.CHILD_WIDGET_NAME.value] = screenName;
            dynamic child = widget.child;
            if (child.title != null) {
              screenName = child.title.toString();
              viewTakenFrom[ScreenAttributes.CHILD_WIDGET_TITLE.value] = screenName;
            }
          }
        } catch (e) {
          print("InstanaScreenNameCapture-e");
        }
      }
    }
    if (screenName != null)
      InstanaViewNameHandler.updateScreenName(screenName: screenName,viewMeta: viewTakenFrom);
  }

}

class ScreenAttributes {
  final String value;

  const ScreenAttributes._(this.value);

  static const ScreenAttributes SETTINGS_ROUTE = ScreenAttributes._("settings.route.name");
  static const ScreenAttributes WIDGET_NAME = ScreenAttributes._("widget.name");
  static const ScreenAttributes CHILD_WIDGET_NAME = ScreenAttributes._("child.widget.name");
  static const ScreenAttributes CHILD_WIDGET_TITLE = ScreenAttributes._("child.widget.title");
  static const ScreenAttributes GO_ROUTER = ScreenAttributes._("go.router.path");
 }
