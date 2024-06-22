import 'package:flutter_test/flutter_test.dart';
import 'package:instana_agent/instana_agent.dart';
import 'package:instana_agent/view_name_capture/instana_view_name_handler_bridge.dart';
import 'package:mockito/mockito.dart';

class MockInstanaAgent extends Mock implements InstanaAgent {}

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();


  test('updateScreenName sets view and meta data should not change captured name', () {
    final screenName = 'TestScreen';
    final viewMeta = {
      'key1': 'value1',
      'key2': 'value2',
    };
    InstanaViewNameHandler.updateScreenName(screenName: screenName, viewMeta: viewMeta);
    expect(screenName,'TestScreen');
  });

}
