import 'package:flutter_test/flutter_test.dart';

void main() {
  const colorStart = '''
これは&color( #ffffff,  #8abe00  ) { 背景色 }です。これは&color(#ffffff, #8abe00) { 背景色 }です。&color(#ffffff) { 背景色 }
''';
  test(
    '色、背景色 開始',
    () {
      final colorStartExp = RegExp(
          r"\&color\( *(?<text>#[a-zA-Z0-9]{6,6}){1,1}? *[, ]*(?<bgcolor>#[a-zA-Z0-9]{6,6}){0,1}? *\) *\{(?<content>[^}]*?)\}");

      expect(colorStartExp.hasMatch(colorStart), true);
      var allMatches = colorStartExp.allMatches(colorStart);
      for (var element in allMatches) {
        print("start:${element.start}");
        print("end  :${element.end}");
        print(element.groupCount);
        print(element.group(0)); // 全部
        print(element.namedGroup("text"));
        print(element.namedGroup("bgcolor"));
        print(element.namedGroup("content"));
      }
    },
  );

  const colorEnd = '''
これは&color( #ffffff,  #8abe00  ) { 背景色 }です。これは&color(#ffffff, #8abe00) { 背景色 }です。
''';
  test(
    '色、背景色　終了',
    () {
      final colorStartExp = RegExp(r"\}");

      expect(colorStartExp.hasMatch(colorEnd), true);
      var allMatches = colorStartExp.allMatches(colorEnd);
      for (var element in allMatches) {
        print("start:${element.start}");
        print("end  :${element.end}");
        print(element.groupCount);
        print(element.group(0)); // 全部
      }
    },
  );

  const boldStart = '''
これは''太字''です。 これは''太'字''です。
''';
  test(
    '太字 開始',
    () {
      final boldStartExp = RegExp(r"''(?<content>.*?)''");

      expect(boldStartExp.hasMatch(boldStart), true);
      var allMatches = boldStartExp.allMatches(boldStart);
      for (var element in allMatches) {
        print("start:${element.start}");
        print("end  :${element.end}");
        print(element.groupCount);
        print(element.group(0)); // 全部
        print(element.namedGroup("content"));
      }
    },
  );

  const boldEnd = '''
これは''太字''です。 これは''太字''です。
''';
  test(
    '太字　終了',
    () {
      final boldEndExp = RegExp(r"''");

      expect(boldEndExp.hasMatch(boldEnd), true);
      var allMatches = boldEndExp.allMatches(boldEnd);
      for (var element in allMatches) {
        print("start:${element.start}");
        print("end  :${element.end}");
        print(element.groupCount);
        print(element.group(0)); // 全部
      }
    },
  );
  const italicStart = """
これは''太字''です。 これは''太字''です。 これは'''斜体文字'''です。 これは'''斜体文字'''です。
""";
  test(
    '斜体文字 開始',
    () {
      final italicStartExp = RegExp(r"'''(?<content>.*?)'''");

      expect(italicStartExp.hasMatch(italicStart), true);
      var allMatches = italicStartExp.allMatches(italicStart);
      for (var element in allMatches) {
        print("start:${element.start}");
        print("end  :${element.end}");
        print(element.groupCount);
        print(element.group(0)); // 全部
        print(element.namedGroup("content"));
      }
    },
  );

  const italicEnd = """
これは''太字''です。 これは''太字''です。 これは'''斜体文字'''です。 これは'''斜体文字'''です。
""";
  test(
    '斜体文字 終了',
    () {
      final italicEndExp = RegExp(r"'''");

      expect(italicEndExp.hasMatch(italicEnd), true);
      var allMatches = italicEndExp.allMatches(italicEnd);
      for (var element in allMatches) {
        print("start:${element.start}");
        print("end  :${element.end}");
        print(element.groupCount);
        print(element.group(0)); // 全部
      }
    },
  );

  const lineThroughStart = '''
これは%%取り消し%%です。 これは%%取り消し%%です。
''';
  test(
    '取り消し 開始',
    () {
      final lineThroughStartExp = RegExp(r"%%(?<content>.*?)%%");

      expect(lineThroughStartExp.hasMatch(lineThroughStart), true);
      var allMatches = lineThroughStartExp.allMatches(lineThroughStart);
      for (var element in allMatches) {
        print("start:${element.start}");
        print("end  :${element.end}");
        print(element.groupCount);
        print(element.group(0)); // 全部
        print(element.namedGroup("content"));
      }
    },
  );

  const lineThroughEnd = '''
これは%%取り消し%%です。 これは%%取り消し%%です。
''';
  test(
    '取り消し 終了',
    () {
      final lineThroughEndExp = RegExp(r"%%");

      expect(lineThroughEndExp.hasMatch(lineThroughEnd), true);
      var allMatches = lineThroughEndExp.allMatches(lineThroughEnd);
      for (var element in allMatches) {
        print("start:${element.start}");
        print("end  :${element.end}");
        print(element.groupCount);
        print(element.group(0)); // 全部
      }
    },
  );
}
