import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter2_sample/providers/credential_info.dart';
import 'package:flutter2_sample/utils/md_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockHttpClient extends Mock implements HttpClient {
  HttpClientRequest request;

  MockHttpClient(this.request);

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return Future.value(request);
  }
}

class MockHttpClientRequest extends Mock implements HttpClientRequest {
  final HttpHeaders _headers;
  final HttpClientResponse _response;

  MockHttpClientRequest(HttpHeaders headers, HttpClientResponse response)
      : _headers = headers,
        _response = response;

  @override
  get headers {
    return _headers;
  }

  @override
  Future<HttpClientResponse> close() {
    return Future.value(_response);
  }
}

class MockHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get contentLength => _transparentImage.length;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable(<List<int>>[_transparentImage])
        .listen(onData,
            onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
}

class MockHttpHeaders extends Mock implements HttpHeaders {}

// Returns a mock HTTP client that responds with an image to all requests.
HttpClient _createMockImageHttpClient(SecurityContext? _) {
  final MockHttpHeaders headers = MockHttpHeaders();
  final MockHttpClientResponse response = MockHttpClientResponse();
  // ignore: close_sinks
  final MockHttpClientRequest request =
      MockHttpClientRequest(headers, response);

  final HttpClient client = MockHttpClient(request);
  return client;
}

const List<int> _transparentImage = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
];

void main() {
  MaterialApp _buildAppWith(
      RichText Function(BuildContext context, TextStyle baseStyle, MdElement el) func,
      String content,
      {ThemeData? theme,
      double textScaleFactor = 1.0}) {
    return MaterialApp(
      theme: theme,
      home: Material(
        child: ChangeNotifierProvider<CredentialInfo>(
          create: (_) =>
              CredentialInfo(space: "example.com", apiKey: "APIKEYYYYYY"),
          child: Builder(
            builder: (BuildContext context) {
              final baseStyle = Theme.of(context).textTheme.bodyMedium!;
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaleFactor: textScaleFactor),
                child: func(context, baseStyle, MdElement(content: content)),
              );
            },
          ),
        ),
      ),
    );
  }

  const image = '''
#image(data1.png)
''';
  testWidgets('添付ファイル画像の表示', (WidgetTester tester) async {
    HttpOverrides.runZoned(() async {
      await tester.pumpWidget(_buildAppWith(MdParser.toRichText, image));
      await tester.pumpAndSettle();

      var finder = find.byType(RichText);
      final richText = tester.firstWidget<RichText>(finder);
      expect((richText.text as TextSpan).text, null);

      expect(find.byWidgetPredicate((widget) {
        if (widget is Image) {
          return true;
        } else {
          return false;
        }
      }), findsNWidgets(1));
    }, createHttpClient: _createMockImageHttpClient);
  });

  const image2 = '''
#image(data1.png)

#image(data2.png)
''';
  testWidgets('添付ファイル画像の表示　複数個', (WidgetTester tester) async {
    HttpOverrides.runZoned(() async {
      await tester.pumpWidget(_buildAppWith(MdParser.toRichText, image2));
      await tester.pumpAndSettle();

      var finder = find.byType(RichText);
      final richText = tester.firstWidget<RichText>(finder);
      expect((richText.text as TextSpan).text, null);

      expect(find.byWidgetPredicate((widget) {
        if (widget is Image) {
          return true;
        } else {
          return false;
        }
      }), findsNWidgets(2));
    }, createHttpClient: _createMockImageHttpClient);
  });

  const image3 = '''
#image(data1.png)

あいだに ** #image(data2.png) ** 装飾
''';
  testWidgets('添付ファイル画像の表示　複数個 文字装飾中', (WidgetTester tester) async {
    HttpOverrides.runZoned(() async {
      await tester.pumpWidget(_buildAppWith(MdParser.toRichText, image3));
      await tester.pumpAndSettle();

      var finder = find.byType(RichText);
      final richText = tester.firstWidget<RichText>(finder);
      expect((richText.text as TextSpan).text, null);

      expect(find.byWidgetPredicate((widget) {
        if (widget is Image) {
          return true;
        } else {
          return false;
        }
      }), findsNWidgets(2));
    }, createHttpClient: _createMockImageHttpClient);
  });
}
