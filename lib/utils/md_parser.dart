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

class MdParser {
  static List<MdElement> parse(String content) {
    List<MdElement> result = List<MdElement>.empty(growable: true);
    var lines = content.split('\n');
    final quoteLines = List<String>.empty(growable: true);
    lines.forEach((line) {
      // 引用文
      if (line.startsWith('>')) {
        quoteLines.add(line.substring(1));
        return;
      } else if (quoteLines.isNotEmpty){
        var mdQuoteBlock = MdQuoteBlock(content: quoteLines.join("\n"));
        result.add(mdQuoteBlock);
        quoteLines.clear();
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
        final text = Text(
          element.content,
          style: textStyle,
        );
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
        switch (element.level) {
          case 1:
            widget = Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.only(left: indent.toDouble()),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8,),
                  SizedBox(width: 8,),
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
                  Icon(Icons.radio_button_unchecked, size: 10,),
                  SizedBox(width: 8,),
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
                Icon(Icons.stop, size: 12,),
                SizedBox(width: 8,),
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
        widget = Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.only(left: indent.toDouble()),
          child: Row(
            children: [
              Text(element.order.toString() + "."),
              SizedBox(width: 8,),
              Text(element.content),
            ],
          ),
        );
        children.add(widget);
        return;
      }

      //
      if (element is MdElement) {
        children.add(Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            element.content,
            style: normalText,
          ),
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
