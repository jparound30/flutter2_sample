import 'package:flutter/material.dart';
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
      expect(ret.length, 4);
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
---箇条書き2-1-1
----箇条書き4
-------箇条書き7
''';
  test(
    '箇条書き',
    () {
      var ret = MdParser.parse(unorderedList);
      expect(ret.length, 7);
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
      expect((ret[4] as MdUnorderedList).level, 4);
      expect((ret[4] as MdUnorderedList).content, "箇条書き4");
      expect((ret[5] as MdUnorderedList).level, 7);
      expect((ret[5] as MdUnorderedList).content, "箇条書き7");
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
      expect(ret.length, 6);
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
      expect(ret.length, 5);
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
      expect(ret.length, 5);
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

  final quote1 = '''

>引用した内容です。
>引用した内容です。
引用じゃない内容です。
''';
  test(
    '引用文',
    () {
      var ret = MdParser.parse(quote1);
      expect(ret.length, 4);
      expect(ret[1] is MdQuoteBlock, true);
      expect(ret[0].content, "");
      expect((ret[1] as MdQuoteBlock).content, "引用した内容です。\n引用した内容です。");
      expect(ret[2].content, "引用じゃない内容です。");
      expect(ret[3].content, "");
    },
  );

  final quote2 = '''

>引用した内容です。
>引用した内容です。
引用じゃない内容です。
{quote}
>引用した内容です。
>引用した内容です。
{/quote}
''';
  test(
    '引用文({quote}{/quote}) 入れ子1',
    () {
      var ret = MdParser.parse(quote2);
      expect(ret.length, 5);
      expect(ret[1] is MdQuoteBlock, true);
      expect(ret[3] is MdQuoteBlock, true);
      expect(ret[0].content, "");
      expect((ret[1] as MdQuoteBlock).content, "引用した内容です。\n引用した内容です。");
      expect(ret[2].content, "引用じゃない内容です。");
      expect(ret[3] is MdQuoteBlock, true);
      expect((ret[3] as MdQuoteBlock).content, ">引用した内容です。\n>引用した内容です。");
    },
  );

  final quote3 = '''

>引用した内容です。
{quote}
>引用した内容です。
引用じゃない内容です。
>引用した内容です。
{/quote}
>引用した内容です。
''';
  test(
    '引用文({quote}{/quote}) 入れ子2',
    () {
      var ret = MdParser.parse(quote3);
      expect(ret.length, 5);
      expect(ret[1] is MdQuoteBlock, true);
      expect(ret[2] is MdQuoteBlock, true);
      expect(ret[3] is MdQuoteBlock, true);
      expect(ret[0].content, "");
      expect((ret[1] as MdQuoteBlock).content, "引用した内容です。");
      expect((ret[2] as MdQuoteBlock).content,
          ">引用した内容です。\n引用じゃない内容です。\n>引用した内容です。");
      expect((ret[3] as MdQuoteBlock).content, "引用した内容です。");
    },
  );

  final codeBlock = '''
AAAAAA
{code:java}
    package helloworld;
    public class Hello {
        public String sayHello {
            return "Hello";
        }
    }
{/code}
CCCCCC
''';
  test(
    'コードブロック1',
    () {
      final code = '''
    package helloworld;
    public class Hello {
        public String sayHello {
            return "Hello";
        }
    }''';

      var ret = MdParser.parse(codeBlock);
      expect(ret.length, 4);
      expect(ret[0] is MdElement, true);
      expect(ret[1] is MdCodeBlock, true);
      expect(ret[2] is MdElement, true);
      expect(ret[0].content, "AAAAAA");
      expect((ret[1] as MdCodeBlock).content, code);
      expect(ret[2].content, "CCCCCC");
    },
  );

  MaterialApp _buildAppWith(
      RichText func(BuildContext context, TextStyle baseStyle, MdElement el),
      String content,
      {ThemeData? theme,
      double textScaleFactor = 1.0}) {
    return MaterialApp(
      theme: theme,
      home: Material(
        child: Builder(
          builder: (BuildContext context) {
            final baseStyle = Theme.of(context).textTheme.bodyText2!;
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaleFactor: textScaleFactor),
              child: func(context, baseStyle, MdElement(content: content)),
            );
          },
        ),
      ),
    );
  }

  final textStyle1 = """
AAAAAA
これは''太字''です。
これは'''斜体文字'''です。
これは%%打ち消し%%です。
これは&color(red) { 赤 }です。
これは&color(#ffffff, #8abe00) { 背景色 }です。
""";
  testWidgets(
    '文字装飾',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildAppWith(MdParser.toRichText, textStyle1));

      var finder = find.byType(RichText);
      final richText = tester.widget<RichText>(finder);

      expect((richText.text as TextSpan).text, textStyle1);
    },
  );
}
