import 'dart:ui';

import 'package:flutter/material.dart';

const MAX_LEVEL = 6;

class MdElement {
  final String content;

  MdElement({
    required this.content,
  });
}

/// 見出し
class MdTitle extends MdElement {
  final int level;

  MdTitle({
    required this.level,
    required String content,
  }) : super(content: content);
}

/// 箇条書き
class MdUnorderedList extends MdElement {
  final int level;

  MdUnorderedList({
    required this.level,
    required String content,
  }) : super(content: content);
}

/// 箇条書き チェックリスト
class MdUnorderedCheckList extends MdUnorderedList {
  final bool checked;

  MdUnorderedCheckList({
    required int level,
    required String content,
    required this.checked,
  }) : super(level: level, content: content);
}

/// 番号付き箇条書き
class MdOrderedList extends MdElement {
  final int level;
  final int order;

  MdOrderedList({
    required this.level,
    required String content,
    required this.order,
  }) : super(content: content);
}

/// 番号付き箇条書き
class MdOrderedCheckList extends MdOrderedList {
  final bool checked;

  MdOrderedCheckList({
    required int level,
    required String content,
    required int order,
    required this.checked,
  }) : super(level: level, content: content, order: order);
}

/// 引用文
class MdQuoteBlock extends MdElement {
  MdQuoteBlock({
    required String content,
  }) : super(content: content);
}

/// コードブロック
class MdCodeBlock extends MdElement {
  MdCodeBlock({
    required String content,
  }) : super(content: content);
}

class MdParser {
  static final openCodeBlockRegExp = RegExp("^{code.*}\$");
  static final closeCodeBlockRegExp = RegExp("^{/code.*}");

  static List<MdElement> parse(String content) {
    List<MdElement> result = List<MdElement>.empty(growable: true);
    var lines = content.split('\n');
    final quoteLines = List<String>.empty(growable: true);
    final quoteLinesWithTag = List<String>.empty(growable: true);
    final codeLines = List<String>.empty(growable: true);

    lines.forEach((line) {
      // 引用文
      if (quoteLinesWithTag.isEmpty) {
        if (line.startsWith('>')) {
          quoteLines.add(line.substring(1));
          return;
        } else if (quoteLines.isNotEmpty) {
          var mdQuoteBlock = MdQuoteBlock(content: quoteLines.join("\n"));
          result.add(mdQuoteBlock);
          quoteLines.clear();
        }
      }
      if (quoteLinesWithTag.isEmpty && line == "{quote}") {
        quoteLinesWithTag.add("");
        return;
      } else if (quoteLinesWithTag.isNotEmpty && line == "{/quote}") {
        var mdQuoteBlock;
        if (quoteLinesWithTag.length == 1) {
          mdQuoteBlock = MdQuoteBlock(content: "");
        } else {
          mdQuoteBlock = MdQuoteBlock(
              content: quoteLinesWithTag
                  .getRange(1, quoteLinesWithTag.length)
                  .join("\n"));
        }
        result.add(mdQuoteBlock);
        quoteLinesWithTag.clear();
        return;
      } else if (quoteLinesWithTag.isNotEmpty) {
        quoteLinesWithTag.add(line);
        return;
      }

      // コードブロック
      if (codeLines.isEmpty && openCodeBlockRegExp.hasMatch(line)) {
        codeLines.add("");
        return;
      } else if (codeLines.isNotEmpty && closeCodeBlockRegExp.hasMatch(line)) {
        var mdCodeBlock;
        if (codeLines.length == 1) {
          mdCodeBlock = MdCodeBlock(content: "");
        } else {
          mdCodeBlock = MdCodeBlock(
              content: codeLines.getRange(1, codeLines.length).join("\n"));
        }
        result.add(mdCodeBlock);
        codeLines.clear();
        return;
      } else if (codeLines.isNotEmpty) {
        codeLines.add(line);
        return;
      }

      // 見出し
      if (line.startsWith('*')) {
        var level = 1;
        var s = "";
        for (s = line.substring(level);
            s.startsWith('*');
            level++, s = s.substring(1)) {}
        if (level > MAX_LEVEL) {
          result.add(MdElement(content: line));
        } else {
          var c = s.trimLeft();
          result.add(MdTitle(level: level, content: c));
        }
        return;
      }
      // 箇条書き
      if (line.startsWith('-')) {
        var level = 1;
        var s = "";
        for (s = line.substring(level);
            s.startsWith('-');
            level++, s = s.substring(1)) {}
        if (s.startsWith(' [x] ')) {
          // チェックリスト（チェックつき）
          result.add(MdUnorderedCheckList(
              level: level, content: s.substring(5), checked: true));
        } else if (s.startsWith(' [ ] ')) {
          // チェックリスト（チェックなし）
          result.add(MdUnorderedCheckList(
              level: level, content: s.substring(5), checked: false));
        } else {
          // 箇条書き
          var c = s.trimLeft();
          result.add(MdUnorderedList(level: level, content: c));
        }
        return;
      }
      // 番号付き箇条書き
      if (line.startsWith('+')) {
        var level = 1;
        var s = "";
        for (s = line.substring(level);
            s.startsWith('+');
            level++, s = s.substring(1)) {}
        var order = 1;
        if (result.isNotEmpty && result.last is MdOrderedList) {
          final ol = result.last as MdOrderedList;
          if (ol.level == level) {
            order = (result.last as MdOrderedList).order + 1;
          }
        }
        if (s.startsWith(' [x] ')) {
          // チェックリスト（チェックつき）
          result.add(MdOrderedCheckList(
              level: level,
              content: s.substring(5),
              checked: true,
              order: order));
        } else if (s.startsWith(' [ ] ')) {
          // チェックリスト（チェックなし）
          result.add(MdOrderedCheckList(
              level: level,
              content: s.substring(5),
              checked: false,
              order: order));
        } else if (s.startsWith(' ')) {
          result.add(MdOrderedList(
              level: level, content: s.substring(1), order: order));
        }
        return;
      }
      result.add(MdElement(content: line));
    });
    return result;
  }

  static final int sNone = 0x00000000;
  static final int sBoldItalic1 = 0x00000100;
  static final int sBoldItalic2 = 0x00000101;
  static final int sBold = 0x00000200;
  static final int sBoldExit1 = 0x00000201;
  static final int sItalic = 0x00000300;
  static final int sItalicExit1 = 0x00000301;
  static final int sItalicExit2 =  0x00000302;
  static final int sLineThrough1 = 0x00000400;
  static final int sLineThrough = 0x00000500;
  static final int sLineThroughExit1 = 0x00000501;

  // TODO リファクタ必須
  static RichText toRichText(
      BuildContext context, TextStyle baseStyle, MdElement el) {
    List<InlineSpan> inlineSpans = List<InlineSpan>.empty(growable: true);
    final normalText = baseStyle;
    final boldText = normalText.copyWith(fontWeight: FontWeight.bold);
    final italicText = normalText.copyWith(fontStyle: FontStyle.italic);
    final lineThrough = normalText.copyWith(decoration: TextDecoration.lineThrough);

    // '' 太字
    var text = el.content;
    int? start;
    int state = sNone;
    var characters = text.characters;
    var span = StringBuffer();
    characters.forEach((e) {
      if (state == sNone) {
        if ("'" == e) {
          state = sBoldItalic1;
        } else if ("%" == e) {
          state = sLineThrough1;
        } else {
          span.write(e);
        }
      } else if (state == sBoldItalic1) {
        if ("'" == e) {
          state = sBoldItalic2;
        } else {
          state = sNone;
          span.write("'" + e);
        }
      } else if (state == sBoldItalic2) {
        if ("'" == e) {
          state = sItalic;
          inlineSpans.add(TextSpan(text: span.toString()));
          span.clear();
        } else {
          state = sBold;
          inlineSpans.add(TextSpan(text: span.toString()));
          span.clear();
          span.write(e);
        }
      } else if (state == sBold) {
        if ("'" == e) {
          state = sBoldExit1;
        } else {
          state = sBold;
          span.write(e);
        }
      } else if (state == sBoldExit1) {
        if ("'" == e) {
          state = sNone;
          inlineSpans.add(TextSpan(style: boldText, text: span.toString()));
          span.clear();
        } else {
          state = sBold;
          span.write("'" + e);
        }
      } else if (state == sItalic) {
        if ("'" == e) {
          state = sItalicExit1;
        } else {
          state = sItalic;
          span.write(e);
        }
      } else if (state == sItalicExit1) {
        if ("'" == e) {
          state = sItalicExit2;
        } else {
          state = sItalic;
          span.write("'" + e);
        }
      } else if (state == sItalicExit2) {
        if ("'" == e) {
          state = sNone;
          inlineSpans.add(TextSpan(style: italicText, text: span.toString()));
          span.clear();
        } else {
          state = sItalic;
          span.write("''" + e);
        }
      } else if (state == sLineThrough1) {
        if ("%" == e) {
          state = sLineThrough;
          inlineSpans.add(TextSpan(text: span.toString()));
          span.clear();
        } else {
          state = sNone;
          span.write("%" + e);
        }
      } else if (state == sLineThrough) {
        if ("%" == e) {
          state = sLineThroughExit1;
        } else {
          state = sLineThrough;
          span.write(e);
        }
      } else if (state == sLineThroughExit1) {
        if ("%" == e) {
          state = sNone;
          inlineSpans.add(TextSpan(style: lineThrough, text: span.toString()));
          span.clear();
        } else {
          state = sLineThrough;
          span.write("%" + e);
        }
      }
    });
    if (span.isNotEmpty) {
      inlineSpans.add(TextSpan(text: span.toString()));
    }

    RichText ret = RichText(
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      text: TextSpan(children: inlineSpans, style: baseStyle),
    );

    return ret;
  }

  static Widget buildFromMdElements(
      BuildContext context, List<MdElement> elements) {
    List<Widget> children = List<Widget>.empty(growable: true);
    elements.forEach((element) {
      // TODO 共通のmarginを生成するコンポーネントを全てに噛ませたほうがいいかも？
      final normalText = Theme.of(context).textTheme.bodyText2!;
      final normalFontSize = normalText.fontSize ?? 12.0;
      // 見出し
      if (element is MdTitle) {
        final TextStyle textStyle;
        switch (element.level) {
          case 1:
            textStyle = normalText.copyWith(
              fontSize: normalFontSize * 2.4,
              fontWeight: FontWeight.w900,
            );
            break;
          case 2:
            textStyle = normalText.copyWith(
              fontSize: normalFontSize * 2.0,
              fontWeight: FontWeight.w800,
            );
            break;
          case 3:
            textStyle = normalText.copyWith(
              fontSize: normalFontSize * 1.6,
              fontWeight: FontWeight.w800,
            );
            break;
          case 4:
            textStyle = normalText.copyWith(
              fontSize: normalFontSize * 1.4,
              fontWeight: FontWeight.w700,
            );
            break;
          case 5:
            textStyle = normalText.copyWith(
              fontSize: normalFontSize * 1.2,
              fontWeight: FontWeight.w700,
            );
            break;
          case 6:
            textStyle = normalText.copyWith(
              fontSize: normalFontSize * 1.0,
              fontWeight: FontWeight.w600,
            );
            break;
          default:
            textStyle = normalText;
        }
        // TODO 削除
        // final text = Text(
        //   element.content,
        //   style: textStyle,
        // );
        final text = MdParser.toRichText(context, textStyle, element);
        if (element.level == 1) {
          final pad = Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.green,
                  width: 3.0,
                ),
              ),
            ),
            margin: EdgeInsets.symmetric(vertical: 16),
            child: text,
          );
          children.add(pad);
        } else if (element.level == 2) {
          final pad = Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.green,
                  width: 1.0,
                ),
              ),
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
            child: text,
          );
          children.add(pad);
        } else {
          final e = Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: text,
          );
          children.add(e);
        }
        return;
      }

      // 箇条書き
      if (element is MdUnorderedList) {
        final indent = (element.level - 1) * 16;
        final Widget widget;
        final isCheckList = element is MdUnorderedCheckList;
        final checkedIcon = Icon(Icons.check_box, color: Colors.blue);
        final uncheckedIcon = Icon(Icons.check_box_outline_blank);
        final margin = SizedBox(width: 8);
        final lineThrough = normalText.copyWith(
          color: Colors.grey.shade400,
          decoration: TextDecoration.lineThrough,
        );
        switch (element.level) {
          case 1:
            widget = Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.only(left: indent.toDouble()),
              child: Row(
                children: [
                  margin,
                  if (isCheckList && (element as MdUnorderedCheckList).checked)
                    checkedIcon
                  else if (isCheckList &&
                      !((element as MdUnorderedCheckList).checked))
                    uncheckedIcon
                  else
                    Icon(Icons.circle, size: 8),
                  margin,
                  if (isCheckList && (element as MdUnorderedCheckList).checked)
                    Text(element.content, style: lineThrough)
                  else
                    Text(element.content),
                ],
              ),
            );
            children.add(widget);
            break;
          case 2:
            widget = Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.only(left: indent.toDouble()),
              child: Row(
                children: [
                  margin,
                  if (isCheckList && (element as MdUnorderedCheckList).checked)
                    checkedIcon
                  else if (isCheckList &&
                      !((element as MdUnorderedCheckList).checked))
                    uncheckedIcon
                  else
                    Icon(Icons.radio_button_unchecked, size: 10),
                  margin,
                  if (isCheckList && (element as MdUnorderedCheckList).checked)
                    Text(element.content, style: lineThrough)
                  else
                    Text(element.content),
                ],
              ),
            );
            children.add(widget);
            break;
          case 3:
          default:
            widget = Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.only(left: indent.toDouble()),
              child: Row(
                children: [
                  margin,
                  if (isCheckList && (element as MdUnorderedCheckList).checked)
                    checkedIcon
                  else if (isCheckList &&
                      !((element as MdUnorderedCheckList).checked))
                    uncheckedIcon
                  else
                    Icon(Icons.stop, size: 12),
                  margin,
                  if (isCheckList && (element as MdUnorderedCheckList).checked)
                    Text(element.content, style: lineThrough)
                  else
                    Text(element.content),
                ],
              ),
            );
            children.add(widget);
            break;
        }
        return;
      }

      // 番号付き箇条書き
      if (element is MdOrderedList) {
        final indent = (element.level - 1) * 16;
        final Widget widget;
        final isCheckList = element is MdOrderedCheckList;
        final checkedIcon = Icon(Icons.check_box, color: Colors.blue);
        final uncheckedIcon = Icon(Icons.check_box_outline_blank);
        final margin = SizedBox(width: 8);
        final lineThrough = normalText.copyWith(
          color: Colors.grey.shade400,
          decoration: TextDecoration.lineThrough,
        );
        widget = Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.only(left: indent.toDouble()),
          child: Row(
            children: [
              Text(element.order.toString() + "."),
              margin,
              if (isCheckList && (element as MdOrderedCheckList).checked)
                checkedIcon
              else if (isCheckList &&
                  !((element as MdOrderedCheckList).checked))
                uncheckedIcon,
              if (isCheckList) margin,
              if (isCheckList && (element as MdOrderedCheckList).checked)
                Text(element.content, style: lineThrough)
              else
                Text(element.content),
            ],
          ),
        );
        children.add(widget);
        return;
      }

      // 引用文
      if (element is MdQuoteBlock) {
        final textStyle = normalText.copyWith(color: Colors.grey.shade600);
        final pad = Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.grey.shade400,
                width: 3.0,
              ),
            ),
          ),
          margin: EdgeInsets.symmetric(vertical: 16),
          child: Text(element.content, style: textStyle),
        );
        children.add(pad);
        return;
      }

      // コードブロック
      if (element is MdCodeBlock) {
        final block = Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
            color: Colors.grey.shade100,
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Text(element.content, style: normalText),
        );
        children.add(block);
        return;
      }

      //
      if (element is MdElement) {
        children.add(Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: MdParser.toRichText(context, normalText, element),
        ));
        return;
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
