import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instana_agent/view_name_capture/instana_route_observer.dart';
import 'package:mockito/mockito.dart';

class MockRouteSettings extends Mock implements RouteSettings {}
class MockBuildContext extends Mock implements BuildContext {}
class MockRoute extends Mock implements Route<dynamic> {
  // Define behavior for settings property
  RouteSettings? get mockSettings => super.noSuchMethod(Invocation.getter(#settings), returnValue: MockRouteSettings());
}

class MockRoutePageRoute extends Mock implements MaterialPageRoute<dynamic> {
  // Define behavior for settings property
  RouteSettings? get mockSettings => super.noSuchMethod(Invocation.getter(#settings), returnValue: MockRouteSettings());
  WidgetBuilder get builder => (context) => Text("data");
}

class MockScreenNameExtractor extends Mock {
  String? call(RouteSettings settings);
}

void main(){

  late InstanaScreenNameObserver observer;
  late MockBuildContext mockBuildContext;
  late MockScreenNameExtractor mockScreenNameExtractor;

  const MethodChannel channel = MethodChannel('instana_agent');
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
    mockBuildContext = MockBuildContext();
    mockScreenNameExtractor = MockScreenNameExtractor();

    observer = InstanaScreenNameObserver(
      buildContext: mockBuildContext,
      screenNameExtractor: mockScreenNameExtractor,
    );
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });



  test('didPush calls mockScreenNameExtractor with correct arguments', () {
    // Arrange
    final mockRouteSettings = MockRouteSettings();
    when(mockScreenNameExtractor(mockRouteSettings)).thenReturn('ScreenName');
    final Route mockPreviousRoute = MockRoute();
    final mockRoute = MockRoute();
    when(mockRoute.mockSettings).thenReturn(mockRouteSettings);
    // Act
    observer.didPush(mockRoute, mockPreviousRoute);
    // Assert
    verify(mockScreenNameExtractor(mockRouteSettings)).called(1);
  });

  test('didPush calls mockScreenNameExtractor with correct arguments with PageRoute', () {
    // Arrange
    final mockRouteSettings = MockRouteSettings();
    when(mockScreenNameExtractor(mockRouteSettings)).thenReturn('ScreenName');
    final Route mockPreviousRoute = MockRoute();
    final mockRoute = MockRoutePageRoute();
    when(mockRoute.mockSettings).thenReturn(mockRouteSettings);
    // Act
    observer.didPush(mockRoute, mockPreviousRoute);
    // Assert
    verify(mockScreenNameExtractor(mockRouteSettings)).called(1);
  });


  test('didPush calls with defaultScreenNameExtractor and MockRoutePageRoute', () {
    // Arrange
    final mockRouteSettings = MockRouteSettings();
    when(mockScreenNameExtractor(mockRouteSettings)).thenReturn('ScreenName');
    final Route mockPreviousRoute = MockRoute();
    final mockRoute = MockRoutePageRoute();
    when(mockRoute.mockSettings).thenReturn(mockRouteSettings);
    // Act
    bool alwaysTrueRouteFilter(Route<dynamic>? route) => true;
    observer = InstanaScreenNameObserver(
        buildContext: mockBuildContext,
        routeFilter: alwaysTrueRouteFilter
    );
    observer.didPush(mockRoute, mockPreviousRoute);
    // Assert
    verifyNever(mockScreenNameExtractor(mockRouteSettings));
  });

  test('didPop calls mockScreenNameExtractor with correct arguments', () {
    // Arrange
    final mockRouteSettings = MockRouteSettings();
    when(mockScreenNameExtractor(mockRouteSettings)).thenReturn('ScreenName');
    final Route mockPreviousRoute = MockRoute();
    final mockRoute = MockRoute();
    when(mockRoute.mockSettings).thenReturn(mockRouteSettings);

    // Act
    observer.didPop(mockRoute, mockPreviousRoute);
    // Assert
    verify(mockScreenNameExtractor(mockRouteSettings)).called(1);
  });

  test('didReplace calls mockScreenNameExtractor with incorrect arguments', () {
    // Arrange
    final mockRouteSettings = MockRouteSettings();
    when(mockScreenNameExtractor(mockRouteSettings)).thenReturn('ScreenName');
    final Route mockPreviousRoute = MockRoute();
    final mockRoute = MockRoute();
    when(mockRoute.mockSettings).thenReturn(mockRouteSettings);

    // Act
    observer.didReplace(newRoute: mockRoute,oldRoute: mockPreviousRoute);
    // Assert
    verifyNever(mockScreenNameExtractor(mockRouteSettings)).called(0);
  });

  test('empty init of defaultNameExtractor in the InstanaScreenNameObserver should work for did replace', () {
    // Arrange
    final mockRouteSettings = MockRouteSettings();
    when(mockScreenNameExtractor(mockRouteSettings)).thenReturn('ScreenName');
    final Route mockPreviousRoute = MockRoute();
    final mockRoute = MockRoute();
    when(mockRoute.mockSettings).thenReturn(mockRouteSettings);

    observer = InstanaScreenNameObserver(
      buildContext: mockBuildContext,
    );
    // Act
    observer.didReplace(newRoute: mockRoute,oldRoute: mockPreviousRoute);
    // Assert
    verifyNever(mockScreenNameExtractor(mockRouteSettings));
  });

  test('custom routeFilter for covering positive cases with mock routes', () {
    // Arrange
    final mockRouteSettings = MockRouteSettings();
    when(mockScreenNameExtractor(mockRouteSettings)).thenReturn('ScreenName');
    final Route mockPreviousRoute = MockRoute();
    final mockRoute = MockRoute();
    when(mockRoute.mockSettings).thenReturn(mockRouteSettings);
    bool alwaysTrueRouteFilter(Route<dynamic>? route) => true;
    observer = InstanaScreenNameObserver(
      buildContext: mockBuildContext,
      routeFilter: alwaysTrueRouteFilter
    );
    // Act
    observer.didReplace(newRoute: mockRoute,oldRoute: mockPreviousRoute);
    // Assert
    verifyNever(mockScreenNameExtractor(mockRouteSettings));
  });


  test('ScreenAttributes values should not change from mapped', () {
    expect(ScreenAttributes.SETTINGS_ROUTE.value, "settings.route.name");
    expect(ScreenAttributes.WIDGET_NAME.value, "widget.name");
    expect(ScreenAttributes.CHILD_WIDGET_NAME.value, "child.widget.name");
    expect(ScreenAttributes.CHILD_WIDGET_TITLE.value, "child.widget.title");
  });






}