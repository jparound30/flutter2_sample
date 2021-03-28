import 'package:flutter_test/flutter_test.dart';

void main() {
  final colorStart = '''
これは&color( #ffffff,  #8abe00  ) { 背景色 }です。これは&color(#ffffff, #8abe00) { 背景色 }です。&color(#ffffff) { 背景色 }
''';
  test(
    '色、背景色 開始',
    () {
      final colorStartExp = RegExp(
          r"\&color\( *(?<text>#[a-zA-Z0-9]{6,6}){1,1}? *[, ]*(?<bgcolor>#[a-zA-Z0-9]{6,6}){0,1}? *\) *\{(?<content>[^}]*?)\}");

      expect(colorStartExp.hasMatch(colorStart), true);
      var allMatches = colorStartExp.allMatches(colorStart);
      allMatches.forEach((element) {
        print("start:" + element.start.toString());
        print("end  :" + element.end.toString());
        print(element.groupCount);
        print(element.group(0)); // 全部
        print(element.namedGroup("text"));
        print(element.namedGroup("bgcolor"));
        print(element.namedGroup("content"));
      });
    },
  );

  final colorEnd = '''
これは&color( #ffffff,  #8abe00  ) { 背景色 }です。これは&color(#ffffff, #8abe00) { 背景色 }です。
''';
  test(
    '色、背景色　終了',
    () {
      final colorStartExp = RegExp(r"\}");

      expect(colorStartExp.hasMatch(colorEnd), true);
      var allMatches = colorStartExp.allMatches(colorEnd);
      allMatches.forEach((element) {
        print("start:" + element.start.toString());
        print("end  :" + element.end.toString());
        print(element.groupCount);
        print(element.group(0)); // 全部
      });
    },
  );

}
