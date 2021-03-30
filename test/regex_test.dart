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
}
