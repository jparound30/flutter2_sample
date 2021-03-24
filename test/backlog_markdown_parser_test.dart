
import 'package:flutter2_sample/utils/md_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final title = '''
*見出し1
** 見出し2
***  見出し3
''';
  test(
    '見出し',
    () {
      var ret = MdParser.parse(title);
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

  final unorderedList = '''
- 箇条書き1
- 箇条書き2
-- 箇条書き2-1
--- 箇条書き2-1-1
''';
  test(
    '箇条書き',
        () {
      var ret = MdParser.parse(unorderedList);
      expect(ret.length, 4);
      expect(ret[0] is MdUnorderedList, true);
      expect(ret[1] is MdUnorderedList, true);
      expect(ret[2] is MdUnorderedList, true);
      expect(ret[3] is MdUnorderedList, true);
      expect((ret[0] as MdUnorderedList).level, 1);
      expect((ret[0] as MdUnorderedList).content, "箇条書き1");
      expect((ret[1] as MdUnorderedList).level, 1);
      expect((ret[1] as MdUnorderedList).content, "箇条書き2");
      expect((ret[2] as MdUnorderedList).level, 2);
      expect((ret[2] as MdUnorderedList).content, "箇条書き2-1");
      expect((ret[3] as MdUnorderedList).level, 3);
      expect((ret[3] as MdUnorderedList).content, "箇条書き2-1-1");
    },
  );

  final unorderedListNoSpace = '''
---箇条書き2-1-1
''';
  test(
    '箇条書き 空白区切りなし',
        () {
      var ret = MdParser.parse(unorderedListNoSpace);
      expect(ret.length, 1);
      expect(ret[0] is MdElement, true);
      expect((ret[0]).content, "---箇条書き2-1-1");
    },
  );

  final orderedList = '''
+ 箇条書き1
+ 箇条書き2
+ 箇条書き3
++ 箇条書き3-1
++ 箇条書き3-2
''';
  test(
    '番号付き箇条書き',
        () {
      var ret = MdParser.parse(orderedList);
      expect(ret.length, 5);
      expect(ret[0] is MdOrderedList, true);
      expect(ret[1] is MdOrderedList, true);
      expect(ret[2] is MdOrderedList, true);
      expect(ret[3] is MdOrderedList, true);
      expect(ret[4] is MdOrderedList, true);
      expect((ret[0] as MdOrderedList).level, 1);
      expect((ret[0] as MdOrderedList).content, "箇条書き1");
      expect((ret[0] as MdOrderedList).order, 1);
      expect((ret[1] as MdOrderedList).level, 1);
      expect((ret[1] as MdOrderedList).content, "箇条書き2");
      expect((ret[1] as MdOrderedList).order, 2);
      expect((ret[2] as MdOrderedList).level, 1);
      expect((ret[2] as MdOrderedList).content, "箇条書き3");
      expect((ret[2] as MdOrderedList).order, 3);
      expect((ret[3] as MdOrderedList).level, 2);
      expect((ret[3] as MdOrderedList).content, "箇条書き3-1");
      expect((ret[3] as MdOrderedList).order, 1);
      expect((ret[4] as MdOrderedList).level, 2);
      expect((ret[4] as MdOrderedList).content, "箇条書き3-2");
      expect((ret[4] as MdOrderedList).order, 2);
    },
  );

  final checkList = '''
- [ ] Item-A
- [x] Item-B
-- [ ] Item-B-1
--- [ ] Item-B-2-a
''';
  test(
    'チェックリスト',
        () {
      var ret = MdParser.parse(checkList);
      expect(ret.length, 4);
      expect(ret[0] is MdUnorderedCheckList, true);
      expect(ret[1] is MdUnorderedCheckList, true);
      expect(ret[2] is MdUnorderedCheckList, true);
      expect(ret[3] is MdUnorderedCheckList, true);
      expect((ret[0] as MdUnorderedCheckList).level, 1);
      expect((ret[0] as MdUnorderedCheckList).content, "Item-A");
      expect((ret[0] as MdUnorderedCheckList).checked, false);
      expect((ret[1] as MdUnorderedCheckList).level, 1);
      expect((ret[1] as MdUnorderedCheckList).content, "Item-B");
      expect((ret[1] as MdUnorderedCheckList).checked, true);
      expect((ret[2] as MdUnorderedCheckList).level, 2);
      expect((ret[2] as MdUnorderedCheckList).content, "Item-B-1");
      expect((ret[2] as MdUnorderedCheckList).checked, false);
      expect((ret[3] as MdUnorderedCheckList).level, 3);
      expect((ret[3] as MdUnorderedCheckList).content, "Item-B-2-a");
      expect((ret[3] as MdUnorderedCheckList).checked, false);
    },
  );

  final orderedCheckList = '''
+ [ ] Item-A
+ [x] Item-B
++ [ ] Item-B-1
+++ [ ] Item-B-2-a
''';
  test(
    'チェックリスト',
        () {
      var ret = MdParser.parse(orderedCheckList);
      expect(ret.length, 4);
      expect(ret[0] is MdOrderedCheckList, true);
      expect(ret[1] is MdOrderedCheckList, true);
      expect(ret[2] is MdOrderedCheckList, true);
      expect(ret[3] is MdOrderedCheckList, true);
      expect((ret[0] as MdOrderedCheckList).level, 1);
      expect((ret[0] as MdOrderedCheckList).content, "Item-A");
      expect((ret[0] as MdOrderedCheckList).order, 1);
      expect((ret[0] as MdOrderedCheckList).checked, false);
      expect((ret[1] as MdOrderedCheckList).level, 1);
      expect((ret[1] as MdOrderedCheckList).content, "Item-B");
      expect((ret[1] as MdOrderedCheckList).order, 2);
      expect((ret[1] as MdOrderedCheckList).checked, true);
      expect((ret[2] as MdOrderedCheckList).level, 2);
      expect((ret[2] as MdOrderedCheckList).content, "Item-B-1");
      expect((ret[2] as MdOrderedCheckList).order, 1);
      expect((ret[2] as MdOrderedCheckList).checked, false);
      expect((ret[3] as MdOrderedCheckList).level, 3);
      expect((ret[3] as MdOrderedCheckList).content, "Item-B-2-a");
      expect((ret[3] as MdOrderedCheckList).order, 1);
      expect((ret[3] as MdOrderedCheckList).checked, false);
    },
  );

}
