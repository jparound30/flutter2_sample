import 'package:flutter/material.dart';
import 'package:flutter2_sample/providers/credential_info.dart';
import 'package:flutter2_sample/utils/color_converter.dart';
import 'package:provider/provider.dart';

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

/// 表セル
class MdCell extends MdElement {
  bool columnHeader;
  bool rowHeader;
  bool firstRow;
  bool firstColumn;

  MdCell({
    required String content,
    this.columnHeader = false,
    this.rowHeader = false,
    this.firstRow = false,
    this.firstColumn = false,
  }) : super(content: content);
}

// 表
class MdTable extends MdElement {
  late List<List<MdCell>> cellLists;

  MdTable() : super(content: "") {
    cellLists = List<List<MdCell>>.empty(growable: true);
  }
}

class MdParser {
  static final openCodeBlockRegExp = RegExp("^{code.*}\$");
  static final closeCodeBlockRegExp = RegExp("^{/code.*}");
  static final tableRowExp = RegExp(r'^\|.*\|(h?)');

  static List<MdElement> parse(String content) {
    List<MdElement> result = List<MdElement>.empty(growable: true);
    var lines = content.split('\n');
    final quoteLines = List<String>.empty(growable: true);
    final quoteLinesWithTag = List<String>.empty(growable: true);
    final codeLines = List<String>.empty(growable: true);
    MdTable? table;

    for (var line in lines) {
      final isTableRow = tableRowExp.hasMatch(line);
      if (!isTableRow && table != null) {
        result.add(table);
        table = null;
      }

      // 引用文
      if (quoteLinesWithTag.isEmpty) {
        if (line.startsWith('>')) {
          quoteLines.add(line.substring(1));
          continue;
        } else if (quoteLines.isNotEmpty) {
          var mdQuoteBlock = MdQuoteBlock(content: quoteLines.join("\n"));
          result.add(mdQuoteBlock);
          quoteLines.clear();
        }
      }
      if (quoteLinesWithTag.isEmpty && line == "{quote}") {
        quoteLinesWithTag.add("");
        continue;
      } else if (quoteLinesWithTag.isNotEmpty && line == "{/quote}") {
        MdQuoteBlock mdQuoteBlock;
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
        continue;
      } else if (quoteLinesWithTag.isNotEmpty) {
        quoteLinesWithTag.add(line);
        continue;
      }

      // コードブロック
      if (codeLines.isEmpty && openCodeBlockRegExp.hasMatch(line)) {
        codeLines.add("");
        continue;
      } else if (codeLines.isNotEmpty && closeCodeBlockRegExp.hasMatch(line)) {
        MdCodeBlock mdCodeBlock;
        if (codeLines.length == 1) {
          mdCodeBlock = MdCodeBlock(content: "");
        } else {
          mdCodeBlock = MdCodeBlock(
              content: codeLines.getRange(1, codeLines.length).join("\n"));
        }
        result.add(mdCodeBlock);
        codeLines.clear();
        continue;
      } else if (codeLines.isNotEmpty) {
        codeLines.add(line);
        continue;
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
        continue;
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
        continue;
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
        continue;
      }

      if (isTableRow) {
        var row = List<MdCell>.empty(growable: true);
        var isFirstRow = false;
        var isFirstColumn = true;
        if (table == null) {
          table = MdTable();
          isFirstRow = true;
        }
        var isHeaderLine = line.endsWith("h");
        var cellContents = line.split(r"|");

        cellContents.skip(1).take(cellContents.length - 2).forEach((e) {
          MdCell cell;
          final contentStr = e.trim();
          if (contentStr.startsWith("~")) {
            cell = MdCell(
              columnHeader: isHeaderLine,
              content: contentStr.substring(1).trim(),
              rowHeader: true,
              firstRow: isFirstRow,
              firstColumn: isFirstColumn,
            );
          } else {
            cell = MdCell(
              columnHeader: isHeaderLine,
              content: contentStr,
              firstRow: isFirstRow,
              firstColumn: isFirstColumn,
            );
          }
          row.add(cell);
          isFirstColumn = false;
        });
        table.cellLists.add(row);
        continue;
      }
      if (result.isNotEmpty && result.last.runtimeType == MdElement) {
        var newLine = "${result.last.content}\n$line";
        result.removeLast();
        result.add(MdElement(content: newLine));
      } else {
        result.add(MdElement(content: line));
      }
    }
    if (table != null) {
      result.add(table);
    }

    return result;
  }

  static const int sNone = 0x00000000;
  static const int sBold = 0x00000200;
  static const int sItalic = 0x00000400;
  static const int sLineThrough = 0x00001000;
  static const int sColor = 0x00002000;

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
  static final imageStartExp = RegExp(r'#image\((?<name>[^()]+?)\)');
  static final imageEndExp = RegExp(r'\)');

  // TODO リファクタ必須
  static RichText toRichText(
      BuildContext context, TextStyle baseStyle, MdElement el) {
    List<InlineSpan> inlineSpans = List<InlineSpan>.empty(growable: true);
    final normalText = baseStyle;

    // TODO 動作確認用に決め打ち 要検討
    const issueIdorKey = "APITEST-2";
    const attachmentId = "6167186";
    // TODO 外部から渡す、などに変えるべき
    final credentialInfo = Provider.of<CredentialInfo>(context);
    final space = credentialInfo.space!;
    final apiKey = credentialInfo.apiKey!;

    var text = el.content;
    int state = sNone;

    int nextType = 0;

    final defaultFontColor = normalText.color ?? Colors.black;
    final defaultBgColor = normalText.backgroundColor ?? Colors.white;
    Color fontColor = defaultFontColor;
    Color bgColor = defaultBgColor;
    Color nextFontColor = fontColor;
    Color nextBgColor = bgColor;
    WidgetSpan? image; // 添付ファイル画像保持用

    while (true) {
      int minStart = -1;
      int end = -1;

      if (state == sNone) {
        Iterable<RegExpMatch> boldStart = boldStartExp.allMatches(text);
        Iterable<RegExpMatch> italicStart = italicStartExp.allMatches(text);
        Iterable<RegExpMatch> lineThroughStart =
            lineThroughStartExp.allMatches(text);
        var colorStart = colorStartExp.allMatches(text);
        var imageStart = imageStartExp.allMatches(text);

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
        if (imageStart.isNotEmpty) {
          // TODO ファイル画像表示widget生成の共通化
          if (minStart == -1 || imageStart.first.start < minStart) {
            minStart = imageStart.first.start;
            end = imageStart.first.end;
            // TODO nameから添付ファイルのidを割り出すように変更必要
            final name = imageStart.first.namedGroup("name");
            final url =
                "https://$space/api/v2/issues/$issueIdorKey/attachments/$attachmentId?apiKey=$apiKey";
            image = WidgetSpan(child: Image.network(url));
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

        Iterable<RegExpMatch> imageStart = imageStartExp.allMatches(text);

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
        if (imageStart.isNotEmpty) {
          // TODO ファイル画像表示widget生成の共通化
          if (minStart == -1 || imageStart.first.start < minStart) {
            minStart = imageStart.first.start;
            end = imageStart.first.end;
            // TODO nameから添付ファイルのidを割り出すように変更必要
            final name = imageStart.first.namedGroup("name");
            final url =
                "https://$space/api/v2/issues/$issueIdorKey/attachments/$attachmentId?apiKey=$apiKey";
            image = WidgetSpan(child: Image.network(url));
          }
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
        if (image != null) {
          inlineSpans.add(image);
          image = null;
        }
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
      // asciiだけのセルとマルチバイト(CJKフォント？)が混在しているセルが
      // 1行にある場合に、ボーダーのレンダリングがズレる
      // strutStyleを設定しかつfontSizeをテキストに使うフォントサイズより大きくすると
      // 回避できる
      // TODO web/iosで再現する。engine or frameworkのコード確認してみる
      strutStyle: StrutStyle.fromTextStyle(
        normalText,
        fontSize: normalText.fontSize! + 2.0,
      ),
    );

    return ret;
  }

  static Widget buildFromMdElements(
    BuildContext context,
    List<MdElement> elements,
  ) {
    List<Widget> children = List<Widget>.empty(growable: true);
    for (var element in elements) {
      // TODO 共通のmarginを生成するコンポーネントを全てに噛ませたほうがいいかも？
      final normalText = Theme.of(context).textTheme.bodyMedium!;
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
        final text = MdParser.toRichText(context, textStyle, element);
        if (element.level == 1) {
          final pad = Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.green,
                  width: 3.0,
                ),
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: text,
          );
          children.add(pad);
        } else if (element.level == 2) {
          final pad = Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.green,
                  width: 1.0,
                ),
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: text,
          );
          children.add(pad);
        } else {
          final e = Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: text,
          );
          children.add(e);
        }
        continue;
      }

      // 箇条書き
      if (element is MdUnorderedList) {
        final indent = (element.level - 1) * 16;
        final Widget widget;
        final isCheckList = element is MdUnorderedCheckList;
        const checkedIcon = Icon(Icons.check_box, color: Colors.blue);
        const uncheckedIcon = Icon(Icons.check_box_outline_blank);
        const margin = SizedBox(width: 8);
        final lineThrough = normalText.copyWith(
          color: Colors.grey.shade400,
          decoration: TextDecoration.lineThrough,
        );

        switch (element.level) {
          case 1:
            widget = Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
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
                    const Icon(Icons.circle, size: 8),
                  margin,
                  if (isCheckList && (element as MdUnorderedCheckList).checked)
                    MdParser.toRichText(context, lineThrough, element)
                  else
                    MdParser.toRichText(context, normalText, element),
                ],
              ),
            );
            children.add(widget);
            break;
          case 2:
            widget = Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
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
                    const Icon(Icons.radio_button_unchecked, size: 10),
                  margin,
                  if (isCheckList && (element as MdUnorderedCheckList).checked)
                    MdParser.toRichText(context, lineThrough, element)
                  else
                    MdParser.toRichText(context, normalText, element),
                ],
              ),
            );
            children.add(widget);
            break;
          case 3:
          default:
            widget = Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
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
                    const Icon(Icons.stop, size: 12),
                  margin,
                  if (isCheckList && (element as MdUnorderedCheckList).checked)
                    MdParser.toRichText(context, lineThrough, element)
                  else
                    MdParser.toRichText(context, normalText, element),
                ],
              ),
            );
            children.add(widget);
            break;
        }
        continue;
      }

      // 番号付き箇条書き
      if (element is MdOrderedList) {
        final indent = (element.level - 1) * 16;
        final Widget widget;
        final isCheckList = element is MdOrderedCheckList;
        const checkedIcon = Icon(Icons.check_box, color: Colors.blue);
        const uncheckedIcon = Icon(Icons.check_box_outline_blank);
        const margin = SizedBox(width: 8);
        final lineThrough = normalText.copyWith(
          color: Colors.grey.shade400,
          decoration: TextDecoration.lineThrough,
        );
        widget = Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.only(left: indent.toDouble()),
          child: Row(
            children: [
              Text("${element.order}."),
              margin,
              if (isCheckList && (element as MdOrderedCheckList).checked)
                checkedIcon
              else if (isCheckList &&
                  !((element as MdOrderedCheckList).checked))
                uncheckedIcon,
              if (isCheckList) margin,
              if (isCheckList && (element as MdOrderedCheckList).checked)
                MdParser.toRichText(context, lineThrough, element)
              else
                MdParser.toRichText(context, normalText, element),
            ],
          ),
        );
        children.add(widget);
        continue;
      }

      // 引用文
      if (element is MdQuoteBlock) {
        final textStyle = normalText.copyWith(color: Colors.grey.shade600);
        final pad = Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.grey.shade400,
                width: 3.0,
              ),
            ),
          ),
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Text(element.content, style: textStyle),
        );
        children.add(pad);
        continue;
      }

      // コードブロック
      if (element is MdCodeBlock) {
        final block = Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
            color: Colors.grey.shade100,
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Text(element.content, style: normalText),
        );
        children.add(block);
        continue;
      }

      // 表
      // TODO styling
      if (element is MdTable) {
        const defaultBorder = BorderSide(); // TODO should be customizable?
        var maxColumnCount = 0;
        final List<TableRow> tableCells = element.cellLists.map((row) {
          if (maxColumnCount < row.length) {
            maxColumnCount = row.length;
          }
          final List<Widget> rowWidgets = row.map<Widget>((e) {
            Color? bgColor;
            if (e.columnHeader || e.rowHeader) {
              bgColor = Theme.of(context)
                  .dataTableTheme
                  .headingRowColor
                  ?.resolve(Set<MaterialState>.identity());
            }
            final BorderSide top;
            final BorderSide left;
            top = e.firstRow ? defaultBorder : BorderSide.none;
            left = e.firstColumn ? defaultBorder : BorderSide.none;
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: top,
                  left: left,
                  bottom: defaultBorder,
                  right: defaultBorder,
                ),
                color: bgColor,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              child: MdParser.toRichText(context, normalText, e),
            );
          }).toList(growable: true);
          return TableRow(children: rowWidgets);
        }).toList();
        // must be equal each column count of each rows.
        for (var element in tableCells) {
          for (; element.children!.length < maxColumnCount;) {
            element.children!.add(const SizedBox());
          }
        }

        final table = Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: tableCells,
        );
        final block = Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: table,
            ),
          ),
        );
        children.add(block);
        continue;
      }

      //
      if (element is MdElement) {
        children.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: MdParser.toRichText(context, normalText, element),
        ));
        continue;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
