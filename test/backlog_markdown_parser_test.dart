
import 'package:flutter2_sample/utils/md_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final normal = '''
* 見出し1
** 見出し2
*** 見出し3
''';
  test(
    '見出し',
    () {
      var ret = MdParser.parse(normal);
      expect(ret.length, 3);
      expect(ret[0] is MdTitle, true);
      expect(ret[1] is MdTitle, true);
      expect(ret[2] is MdTitle, true);
      expect((ret[0] as MdTitle).level, 1);
      expect((ret[0] as MdTitle).content, "見出し1");
      expect((ret[1] as MdTitle).level, 2);
      expect((ret[1] as MdTitle).content, "見出し2");
      expect((ret[2] as MdTitle).level, 3);
      expect((ret[2] as MdTitle).content, "見出し3");
    },
  );
}
