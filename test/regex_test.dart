import 'package:flutter_test/flutter_test.dart';

void main() {
  test('row', () {
    final tableRowExp = new RegExp(r'^\|.*\|h?');

    final ng1 = "aaaaa";
    final ok1 = "| ホスト名 | IPアドレス   |     備考      |";
    final ok2 = "| ホスト名 | IPアドレス   |     備考      |h";

    expect(tableRowExp.hasMatch(ng1), false);
    expect(tableRowExp.hasMatch(ok1), true);
    expect(tableRowExp.hasMatch(ok2), true);
  });

  test('image', () {
    final imageExp = new RegExp(r'#image\((?<name>[^()]+?)\)');

    // final ng1 = "aaaaa";
    final ok1 =
        "この課題の問題点#image(スクリーンショット 2021-03-26 19.30.01.png) ppppptruyvjygjytvkjhgouigliyglygljhgjkhbljhjhbljhbljhblkjh;kjhkjhkljh";
    final ok2 =
        "この課題の問題点#image(data1.png) ppppptruyvjygjytvkjhgouigliyglygljhgjkhbljhjhbljhbljhblkjh;#image(data2.png)kjhkjhkljh";
    // final ok2 = "| ホスト名 | IPアドレス   |     備考      |h";

    // expect(tableRowExp.hasMatch(ng1), false);
    expect(imageExp.hasMatch(ok1), true);
    expect(imageExp.firstMatch(ok1)?.namedGroup("name"),
        "スクリーンショット 2021-03-26 19.30.01.png");

    var allMatches = imageExp.allMatches(ok2);
    expect(allMatches.length, 2);
    expect(allMatches.elementAt(0).namedGroup("name"), "data1.png");
    expect(allMatches.elementAt(1).namedGroup("name"), "data2.png");
  });
}
