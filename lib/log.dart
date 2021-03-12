class Log {
  static bool showHttpRequestUrl = true;
  static bool showHttpResponseBody = false;

  static void httpRequest(String msg) {
    if (showHttpRequestUrl) {
      print(msg);
    }
  }

  static void httpResponse(String msg) {
    if (showHttpResponseBody) {
      print(msg);
    }
  }
}
