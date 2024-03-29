import 'package:flutter/material.dart';
import 'package:flutter2_sample/providers/credential_info.dart';
import 'package:flutter2_sample/utils/md_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  const title = '''
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

  const unorderedList = '''
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

  const orderedList = '''
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

  const checkList = '''
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

  const orderedCheckList = '''
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

  const quote1 = '''

>引用した内容です。
>引用した内容です。
引用じゃない内容です。''';
  test(
    '引用文',
    () {
      var ret = MdParser.parse(quote1);
      expect(ret.length, 3);
      expect(ret[1] is MdQuoteBlock, true);
      expect(ret[0].content, "");
      expect((ret[1] as MdQuoteBlock).content, "引用した内容です。\n引用した内容です。");
      expect(ret[2].content, "引用じゃない内容です。");
    },
  );

  const quote2 = '''

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

  const quote3 = '''

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

  const codeBlock = '''
AAAAAA
{code:java}
    package helloworld;
    public class Hello {
        public String sayHello {
            return "Hello";
        }
    }
{/code}
CCCCCC''';
  test(
    'コードブロック1',
    () {
      const code = '''
    package helloworld;
    public class Hello {
        public String sayHello {
            return "Hello";
        }
    }''';

      var ret = MdParser.parse(codeBlock);
      expect(ret.length, 3);
      expect(ret[0] is MdElement, true);
      expect(ret[1] is MdCodeBlock, true);
      expect(ret[2] is MdElement, true);
      expect(ret[0].content, "AAAAAA");
      expect((ret[1] as MdCodeBlock).content, code);
      expect(ret[2].content, "CCCCCC");
    },
  );

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

  const bold1 = """
これは''太字''です。""";
  testWidgets(
    '太字',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildAppWith(MdParser.toRichText, bold1));

      var finder = find.byType(RichText);
      final richText = tester.widget<RichText>(finder);

      expect((richText.text as TextSpan).text, null);
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 0))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "これは");
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 3))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "太字");
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 5))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "です。");
    },
  );

  const italic1 = """
これは'''斜体文字'''です。""";
  testWidgets(
    '斜体文字',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildAppWith(MdParser.toRichText, italic1));

      var finder = find.byType(RichText);
      final richText = tester.widget<RichText>(finder);

      expect((richText.text as TextSpan).text, null);
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 0))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "これは");
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 3))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "斜体文字");
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 7))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "です。");
    },
  );

  const lineThrough = """
これは%%打ち消し%%です。""";
  testWidgets(
    '打ち消し',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildAppWith(MdParser.toRichText, lineThrough));

      var finder = find.byType(RichText);
      final richText = tester.widget<RichText>(finder);

      expect((richText.text as TextSpan).text, null);
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 0))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "これは");
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 3))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "打ち消し");
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 7))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "です。");
    },
  );

  const color1 = """
これは&color(#FF0000) { 赤 }です。""";
  testWidgets(
    '色',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildAppWith(MdParser.toRichText, color1));

      var finder = find.byType(RichText);
      final richText = tester.widget<RichText>(finder);

      expect((richText.text as TextSpan).text, null);
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 0))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "これは");
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 3))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          " 赤 ");
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 6))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "です。");
    },
  );

  const bgColor1 = """
これは&color(#ffffff, #8abe00) { 背景色 }です。""";
  testWidgets(
    '背景色',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildAppWith(MdParser.toRichText, bgColor1));

      var finder = find.byType(RichText);
      final richText = tester.widget<RichText>(finder);

      expect((richText.text as TextSpan).text, null);
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 0))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "これは");
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 3))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          " 背景色 ");
      expect(
          richText.text
              .getSpanForPosition(const TextPosition(offset: 8))!
              .toPlainText(
                  includeSemanticsLabels: false, includePlaceholders: false),
          "です。");
    },
  );

  const table1 = '''
| ホスト名 | IPアドレス   |     備考      |h
|~ sun        | 192.168.100.1   |                  |
|~ earth     | 192.168.100.2   |                  |
''';
  test(
    '表',
    () {
      var ret = MdParser.parse(table1);
      expect(ret.length, 2);
      expect(ret[0] is MdTable, true);
      expect(ret[1] is MdElement, true);
      var table = (ret[0] as MdTable);
      expect(table.cellLists[0][0].columnHeader, true);
      expect(table.cellLists[0][0].content, "ホスト名");
      expect(table.cellLists[0][0].rowHeader, false);

      expect(table.cellLists[0][1].columnHeader, true);
      expect(table.cellLists[0][1].content, "IPアドレス");
      expect(table.cellLists[0][1].rowHeader, false);

      expect(table.cellLists[0][2].columnHeader, true);
      expect(table.cellLists[0][2].content, "備考");
      expect(table.cellLists[0][2].rowHeader, false);

      expect(table.cellLists[1][0].columnHeader, false);
      expect(table.cellLists[1][0].content, "sun");
      expect(table.cellLists[1][0].rowHeader, true);

      expect(table.cellLists[1][1].columnHeader, false);
      expect(table.cellLists[1][1].content, "192.168.100.1");
      expect(table.cellLists[1][1].rowHeader, false);

      expect(table.cellLists[1][2].columnHeader, false);
      expect(table.cellLists[1][2].content, "");
      expect(table.cellLists[1][2].rowHeader, false);

      expect(table.cellLists[2][0].columnHeader, false);
      expect(table.cellLists[2][0].content, "earth");
      expect(table.cellLists[2][0].rowHeader, true);

      expect(table.cellLists[2][1].columnHeader, false);
      expect(table.cellLists[2][1].content, "192.168.100.2");
      expect(table.cellLists[2][1].rowHeader, false);

      expect(table.cellLists[2][2].columnHeader, false);
      expect(table.cellLists[2][2].content, "");
      expect(table.cellLists[2][2].rowHeader, false);
    },
  );
}
