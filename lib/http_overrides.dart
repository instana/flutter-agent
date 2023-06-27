/*
 * (c) Copyright IBM Corp. 2023
 */

import 'dart:convert';
import 'dart:io';

import 'instana_agent.dart';

class InstanaHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    HttpClient client = super.createHttpClient(context);
    return InstanaHttpClient(client);
  }
}

class InstanaHttpClientRequest implements HttpClientRequest {
  final HttpClientRequest _clientRequest;
  Marker? _marker;

  InstanaHttpClientRequest(this._clientRequest, this._marker);

  @override
  bool get bufferOutput => _clientRequest.bufferOutput;

  @override
  set bufferOutput(bool value) => _clientRequest.bufferOutput = value;

  @override
  int get contentLength => _clientRequest.contentLength;

  @override
  set contentLength(int value) => _clientRequest.contentLength = value;

  @override
  Encoding get encoding => _clientRequest.encoding;

  @override
  set encoding(Encoding value) => _clientRequest.encoding = value;

  @override
  bool get followRedirects => _clientRequest.followRedirects;

  @override
  set followRedirects(bool value) => _clientRequest.followRedirects = value;

  @override
  int get maxRedirects => _clientRequest.maxRedirects;

  @override
  set maxRedirects(int value) => _clientRequest.maxRedirects = value;

  @override
  bool get persistentConnection => _clientRequest.persistentConnection;

  @override
  set persistentConnection(bool value) =>
      _clientRequest.persistentConnection = value;

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    _clientRequest.abort(exception, stackTrace);
  }

  @override
  void add(List<int> data) {
    _clientRequest.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _clientRequest.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    return _clientRequest.addStream(stream);
  }

  @override
  Future<HttpClientResponse> close() {
    return _clientRequest.close().then((response) {
      _sendHttpBeacon(response);
      return response;
    });
  }

  @override
  Future<HttpClientResponse> get done => _clientRequest.done.then((response) {
    _sendHttpBeacon(response);
    return response;
  });

  @override
  HttpConnectionInfo? get connectionInfo => _clientRequest.connectionInfo;

  @override
  List<Cookie> get cookies => _clientRequest.cookies;

  @override
  Future flush() {
    return _clientRequest.flush();
  }

  @override
  HttpHeaders get headers => _clientRequest.headers;

  @override
  String get method => _clientRequest.method;

  @override
  Uri get uri => _clientRequest.uri;

  @override
  void write(Object? object) {
    _clientRequest.write(object);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    _clientRequest.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    _clientRequest.writeCharCode(charCode);
  }

  @override
  void writeln([Object? object = ""]) {
    _clientRequest.writeln(object);
  }

  void _sendHttpBeacon(HttpClientResponse response) {
    final Marker? localMarker = _marker;

    if (_marker == null) {
      return;
    }
    _marker = null;

    final Map<String, String> headersMap = {};
    response.headers.forEach((key, values) {
      var strList = [];
      strList.addAll(values.map<String>((e) => e.toString()));
      if (headersMap.containsKey(key.toString())) {
        strList.add(headersMap[key.toString()]);
      }
      headersMap[key.toString()] = strList.join(",");
    });

    final String? backendTracingID = BackendTracingIDParser.fromHeadersMap(headersMap);

    _handleMarker(localMarker!, responseStatusCode: response.statusCode,
        backendTracingID: backendTracingID,
        responseSizeBody: response.contentLength,
        responseHeaders: headersMap);
  }

  Future<void> _handleMarker(Marker marker,
      { int? responseStatusCode,
        String? backendTracingID,
        int? responseSizeHeader,
        int? responseSizeBody,
        int? responseSizeBodyDecoded,
        String? errorMessage,
        Map<String, String>? responseHeaders}) async {
    try {
        if (responseStatusCode != null) {
          marker.responseStatusCode = responseStatusCode;
        }
        if (backendTracingID != null) {
          marker.backendTracingID = backendTracingID;
        }
        if (responseSizeHeader != null) {
          marker.responseSizeHeader = responseSizeHeader;
        }
        if (responseSizeBody != null) {
          marker.responseSizeBody = responseSizeBody;
        }
        if (responseSizeBodyDecoded != null) {
          marker.responseSizeBodyDecoded = responseSizeBodyDecoded;
        }
        if (errorMessage != null) {
          marker.errorMessage = errorMessage;
        }
        if (responseHeaders != null && responseHeaders.isNotEmpty) {
          marker.responseHeaders = responseHeaders;
        }
    } finally {
      await marker.finish();
    }
  }
}

class InstanaHttpClient implements HttpClient {
  final HttpClient _httpClient;

  InstanaHttpClient(this._httpClient);

  @override
  bool get autoUncompress => _httpClient.autoUncompress;

  @override
  set autoUncompress(bool value) => _httpClient.autoUncompress = value;

  @override
  Duration? get connectionTimeout => _httpClient.connectionTimeout;

  @override
  set connectionTimeout(Duration? value) =>
      _httpClient.connectionTimeout = value;

  @override
  Duration get idleTimeout => _httpClient.idleTimeout;

  @override
  set idleTimeout(Duration value) => _httpClient.idleTimeout = value;

  @override
  int? get maxConnectionsPerHost => _httpClient.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? value) =>
      _httpClient.maxConnectionsPerHost = value;

  @override
  String? get userAgent => _httpClient.userAgent;

  @override
  set userAgent(String? value) => _httpClient.userAgent = value;

  @override
  void addCredentials(
      Uri url, String realm, HttpClientCredentials credentials) {
    _httpClient.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(
      String host, int port, String realm, HttpClientCredentials credentials) {
    _httpClient.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  set authenticate(
      Future<bool> Function(Uri url, String scheme, String? realm)? f) {
    _httpClient.authenticate = f;
  }

  @override
  set authenticateProxy(
      Future<bool> Function(
              String host, int port, String scheme, String? realm)?
          f) {
    _httpClient.authenticateProxy = f;
  }

  @override
  set badCertificateCallback(
      bool Function(X509Certificate cert, String host, int port)? callback) {
    _httpClient.badCertificateCallback = callback;
  }

  @override
  void close({bool force = false}) {
    _httpClient.close(force: force);
  }

  @override
  set connectionFactory(
      Future<ConnectionTask<Socket>> Function(
              Uri url, String? proxyHost, int? proxyPort)?
          f) {
    _httpClient.connectionFactory = f;
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return _httpClient.delete(host, port, path).then((request){
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return _httpClient.deleteUrl(url).then((request){
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  set findProxy(String Function(Uri url)? f) {
    _httpClient.findProxy = f;
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    return _httpClient.get(host, port, path).then((request) {
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return _httpClient.getUrl(url).then((request) {
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    return _httpClient.head(host, port, path).then((request) {
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    return _httpClient.headUrl(url).then((request) {
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  set keyLog(Function(String line)? callback) {
    _httpClient.keyLog = callback;
  }

  @override
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    return _httpClient.open(method, host, port, path).then((request) {
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return _httpClient.openUrl(method, url).then((request) {
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return _httpClient.patch(host, port, path).then((request) {
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    return _httpClient.patchUrl(url).then((request) {
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    return _httpClient.post(host, port, path).then((request){
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    return _httpClient.postUrl(url).then((request){
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    return _httpClient.put(host, port, path).then((request){
      return _wrapHttpClientRequest(request);
    });
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    return _httpClient.putUrl(url).then((request){
      return _wrapHttpClientRequest(request);
    });
  }

  Future<HttpClientRequest> _wrapHttpClientRequest(HttpClientRequest request) async {
    Marker? marker;
    try {
      marker = await InstanaAgent.startCapture(url: request.uri.toString(),
          method: request.method);
    } catch (e) {
      return request;
    }
    return InstanaHttpClientRequest(request, marker);
  }
}
