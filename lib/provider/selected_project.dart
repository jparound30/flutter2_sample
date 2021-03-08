import 'package:flutter/widgets.dart';
import 'package:flutter2_sample/activities.dart';

class SelectedProject with ChangeNotifier {
  Project? _project;

  Project? get project => _project;

  set project(Project? p) {
    _project = p;
    notifyListeners();
  }
}
