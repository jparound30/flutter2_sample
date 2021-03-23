class MdElement {}

class MdTitle extends MdElement {
  final int level;
  final String content;

  MdTitle({
    required this.level,
    required this.content,
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
      }
    });
    return result;
  }
}
