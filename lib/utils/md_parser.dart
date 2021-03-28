import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter2_sample/utils/color_converter.dart';

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
      if (result.isNotEmpty && result.last.runtimeType == MdElement) {
        var newLine = result.last.content + "\n" + line;
        result.removeLast();
        result.add(MdElement(content: newLine));
      } else {
        result.add(MdElement(content: line));
      }
    });
    return result;
  }

  static final int sNone = 0x00000000;
  static final int sBold = 0x00000200;
  static final int sItalic = 0x00000400;
  static final int sLineThrough = 0x00001000;
  static final int sColor = 0x00002000;

  static final colorStartExp = RegExp(
      r"\&color\( *(?<text>#[a-zA-Z0-9]{6,6}){1,1}? *[, ]*(?<bgcolor>#[a-zA-Z0-9]{6,6}){0,1}? *\) *\{(?<content>[^}]*?)\}");
  static final colorStartExp2 = RegExp(
      r"\&color\( *(?<text>#[a-zA-Z0-9]{6,6}){1,1}? *[, ]*(?<bgcolor>#[a-zA-Z0-9]{6,6}){0,1}? *\) *\{");
  static final colorEndExp = RegExp(r"\}");
  static final boldStartExp = RegExp(r"''(?<content>.*?)''");
  static final boldStartExp2 = RegExp(r"''");
  static final boldEndExp = RegExp(r"''");
  static final italicStartExp = RegExp(r"'''(?<content>.*?)'''");
  static final italicStartExp2 = RegExp(r"'''");
  static final italicEndExp = RegExp(r"'''");
  static final lineThroughStartExp = RegExp(r"%%(?<content>.*?)%%");
  static final lineThroughStartExp2 = RegExp(r"%%");
  static final lineThroughEndExp = RegExp(r"%%");

  // TODO リファクタ必須
  static RichText toRichText(
      BuildContext context, TextStyle baseStyle, MdElement el) {
    List<InlineSpan> inlineSpans = List<InlineSpan>.empty(growable: true);
    final normalText = baseStyle;
    final boldText = normalText.copyWith(fontWeight: FontWeight.bold);
    final italicText = normalText.copyWith(fontStyle: FontStyle.italic);
    final lineThroughText =
        normalText.copyWith(decoration: TextDecoration.lineThrough);

    // '' 太字
    var text = el.content;
    int? start;
    int state = sNone;
    var characters = text.characters;

    int type = 0; // 0 none, 1 bold, 2 italic, 3 line through, 4 color
    int nextType = 0;

    final defaultFontColor = normalText.color ?? Colors.black;
    final defaultBgColor = normalText.backgroundColor ?? Colors.white;
    Color fontColor = defaultFontColor;
    Color bgColor = defaultBgColor;
    Color nextFontColor = fontColor;
    Color nextBgColor = bgColor;
    while (true) {
      int minStart = -1;
      int end = -1;

      if (state == sNone) {
        Iterable<RegExpMatch> boldStart = boldStartExp.allMatches(text);
        Iterable<RegExpMatch> italicStart = italicStartExp.allMatches(text);
        Iterable<RegExpMatch> lineThroughStart =
            lineThroughStartExp.allMatches(text);
        var colorStart = colorStartExp.allMatches(text);

        if (italicStart.isNotEmpty) {
          italicStart = italicStartExp2.allMatches(text);
          if (minStart == -1 || italicStart.first.start < minStart) {
            minStart = italicStart.first.start;
            end = italicStart.first.end;
            nextType = sItalic;
          }
        }
        if (lineThroughStart.isNotEmpty) {
          lineThroughStart = lineThroughStartExp2.allMatches(text);
          if (minStart == -1 || lineThroughStart.first.start < minStart) {
            minStart = lineThroughStart.first.start;
            end = lineThroughStart.first.end;
            nextType = sLineThrough;
          }
        }
        if (boldStart.isNotEmpty) {
          boldStart = boldStartExp2.allMatches(text);
          if (minStart == -1 || boldStart.first.start < minStart) {
            minStart = boldStart.first.start;
            end = boldStart.first.end;
            nextType = sBold;
          }
        }
        if (colorStart.isNotEmpty) {
          colorStart = colorStartExp2.allMatches(text);
          if (minStart == -1 || colorStart.first.start < minStart) {
            minStart = colorStart.first.start;
            end = colorStart.first.end;
            nextType = sColor;
            final colorStr = colorStart.first.namedGroup("text")!;
            final bgColorStr = colorStart.first.namedGroup("bgcolor");
            nextFontColor = ColorConverter.fromString(colorStr);
            if (bgColorStr != null) {
              nextBgColor = ColorConverter.fromString(bgColorStr);
            }
          }
        }
      } else {
        Iterable<RegExpMatch> boldStart = List<RegExpMatch>.empty();
        Iterable<RegExpMatch> italicStart = List<RegExpMatch>.empty();
        Iterable<RegExpMatch> lineThroughStart = List<RegExpMatch>.empty();
        Iterable<RegExpMatch> colorStart = List<RegExpMatch>.empty();
        Iterable<RegExpMatch> boldEnd = List<RegExpMatch>.empty();
        Iterable<RegExpMatch> italicEnd = List<RegExpMatch>.empty();
        Iterable<RegExpMatch> lineThroughEnd = List<RegExpMatch>.empty();
        Iterable<RegExpMatch> colorEnd = List<RegExpMatch>.empty();

        if (state & sBold == sBold) {
          boldEnd = boldEndExp.allMatches(text);
        }
        if (state & sBold == 0) {
          boldStart = boldStartExp.allMatches(text);
        }
        if (state & sItalic == sItalic) {
          italicEnd = italicEndExp.allMatches(text);
        }
        if (state & sItalic == 0) {
          italicStart = italicStartExp.allMatches(text);
        }
        if (state & sLineThrough == sLineThrough) {
          lineThroughEnd = lineThroughEndExp.allMatches(text);
        }
        if (state & sLineThrough == 0) {
          italicStart = italicStartExp.allMatches(text);
        }
        if (state & sColor == sColor) {
          colorEnd = colorEndExp.allMatches(text);
        }
        if (state & sColor == 0) {
          colorStart = colorStartExp.allMatches(text);
        }

        if (italicStart.isNotEmpty) {
          italicStart = italicStartExp2.allMatches(text);
          if (minStart == -1 || italicStart.first.start < minStart) {
            minStart = italicStart.first.start;
            end = italicStart.first.end;
            nextType = sItalic;
          }
        }
        if (italicEnd.isNotEmpty) {
          if (minStart == -1 || italicEnd.first.start < minStart) {
            minStart = italicEnd.first.start;
            end = italicEnd.first.end;
            nextType = ~sItalic;
          }
        }
        if (boldStart.isNotEmpty) {
          boldStart = boldStartExp2.allMatches(text);
          if (minStart == -1 || boldStart.first.start < minStart) {
            minStart = boldStart.first.start;
            end = boldStart.first.end;
            nextType = sBold;
          }
        }
        if (boldEnd.isNotEmpty) {
          if (minStart == -1 || boldEnd.first.start < minStart) {
            minStart = boldEnd.first.start;
            end = boldEnd.first.end;
            nextType = ~sBold;
          }
        }
        if (lineThroughStart.isNotEmpty) {
          lineThroughStart = lineThroughStartExp2.allMatches(text);
          if (minStart == -1 || lineThroughStart.first.start < minStart) {
            minStart = lineThroughStart.first.start;
            end = lineThroughStart.first.end;
            nextType = sLineThrough;
          }
        }
        if (lineThroughEnd.isNotEmpty) {
          if (minStart == -1 || lineThroughEnd.first.start < minStart) {
            minStart = lineThroughEnd.first.start;
            end = lineThroughEnd.first.end;
            nextType = ~sLineThrough;
          }
        }
        if (colorStart.isNotEmpty) {
          colorStart = colorStartExp2.allMatches(text);
          if (minStart == -1 || colorStart.first.start < minStart) {
            minStart = colorStart.first.start;
            end = colorStart.first.end;
            nextType = sColor;
            final colorStr = colorStart.first.namedGroup("text")!;
            final bgColorStr = colorStart.first.namedGroup("bgcolor");
            nextFontColor = ColorConverter.fromString(colorStr);
            if (bgColorStr != null) {
              nextBgColor = ColorConverter.fromString(bgColorStr);
            }
          }
        }
        if (colorEnd.isNotEmpty) {
          minStart = colorEnd.first.start;
          end = colorEnd.first.end;
          nextType = ~sColor;
          nextFontColor = defaultFontColor;
          nextBgColor = defaultBgColor;
        }
      }

      TextStyle textStyle = normalText;
      if (state & sBold == sBold) {
        textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
      }
      if (state & sItalic == sItalic) {
        textStyle = textStyle.copyWith(fontStyle: FontStyle.italic);
      }
      if (state & sLineThrough == sLineThrough) {
        textStyle = textStyle.copyWith(decoration: TextDecoration.lineThrough);
      }
      if (state & sColor == sColor) {
        textStyle =
            textStyle.copyWith(color: fontColor, backgroundColor: bgColor);
      }

      fontColor = nextFontColor;
      bgColor = nextBgColor;

      if (minStart != -1) {
        inlineSpans
            .add(TextSpan(text: text.substring(0, minStart), style: textStyle));
      } else {
        inlineSpans.add(TextSpan(text: text, style: textStyle));
        break;
      }

      if (nextType != 0) {
        if (nextType & 0x1 == 0x01) {
          state &= nextType;
        } else {
          state |= nextType;
        }
      }
      text = text.substring(end);
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
