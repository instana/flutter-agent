import 'package:go_router/go_router.dart';
import 'package:instana_agent/view_name_capture/instana_view_name_handler_bridge.dart';

import 'instana_route_observer.dart';

/// When the application employs [GoRouter] for navigation, Instana can automatically
/// track screen names based on the route. You have the option to provide the
/// GoRoute object to the [InstanaGoRouteObserver] constructor for this purpose.
class InstanaGoRouteObserver {
  late final GoRouter router;

  InstanaGoRouteObserver(this.router) {
    _initializeListener();
    _updateScreenName();
  }

  void _initializeListener() {
    router.routeInformationProvider.addListener(() {
      _updateScreenName();
    });
  }

  void _updateScreenName() {
    final screenName = router.routeInformationProvider.value.location;
    if (screenName.isNotEmpty) {
      final viewMeta = {ScreenAttributes.GO_ROUTER.value: screenName};
      InstanaViewNameHandler.updateScreenName(screenName: screenName, viewMeta: viewMeta);
    }
  }
}