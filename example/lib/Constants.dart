import 'package:webview_flutter/webview_flutter.dart';

String scriptWeasel = '''
if (!window.InstanaEumObject) {
          window.InstanaEumObject = 'ineum';
          window.ineum = function() {
            ineum.q.push(arguments);
          };
          ineum.q = [];
          ineum.v = 2;
          ineum.l = 1 * new Date;
      
// Configure InstanaEumObject
ineum('reportingUrl', '<REPORTING_URL>');
ineum('key', '<INSTANA_WEB_KEY>');
ineum('trackSessions');

// Create and append a new script element
var newScript = document.createElement("script");
newScript.src = "<REPORTING_URL>/eum.min.js";
newScript.crossOrigin = "anonymous";
document.head.appendChild(newScript);
} 
''';

WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..loadRequest(Uri.parse('https://www.google.com'))
      ..loadRequest(Uri.parse('https://github.ibm.com'))
      // ..loadRequest(Uri.parse('https://www.instana.com'))
    ;
