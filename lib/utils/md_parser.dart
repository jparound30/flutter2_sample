class MdElement {}

/// 見出し
class MdTitle extends MdElement {
  final int level;
  final String content;

  MdTitle({
    required this.level,
    required this.content,
  });
}

/// 箇条書き
class MdUnorderedList extends MdElement {
  final int level;
  final String content;

  MdUnorderedList({
    required this.level,
    required this.content,
  });
}

/// 番号付き箇条書き
class MdOrderedList extends MdElement {
  final int level;
  final String content;
  final int order;

  MdOrderedList({
    required this.level,
    required this.content,
    required this.order,
  });
}

class MdParser {
  static List<MdElement> parse(String content) {
    List<MdElement> result = List<MdElement>.empty(growable: true);
    var lines = content.split('\n');
    lines.forEach((line) {
      // 見出し
      if (line.startsWith('*')) {
        var level = 1;
        var s = "";
        for (s = line.substring(level);
        s.startsWith('*');
        level++, s = s.substring(1)) {}
        if (s.startsWith(' ')) {
          result.add(MdTitle(level: level, content: s.substring(1)));
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
        if (s.startsWith(' ')) {
          result.add(MdUnorderedList(level: level, content: s.substring(1)));
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
        if (s.startsWith(' ')) {
          var order = 1;
          if (result.isNotEmpty && result.last is MdOrderedList) {
            final ol = result.last as MdOrderedList;
            if (ol.level == level) {
              order = (result.last as MdOrderedList).order + 1;
            }
          }
          result.add(MdOrderedList(level: level, content: s.substring(1), order: order));
        }
        return;
      }
    });
    return result;
  }
}
