import 'package:flutter/widgets.dart';

class CredentialInfo with ChangeNotifier {
  String? _space;
  String? _apiKey;

  String? get space => _space;

  String? get apiKey => _apiKey;

  set space(String? s) {
    _space = s;
    notifyListeners();
  }

  set apiKey(String? s) {
    _apiKey = s;
    notifyListeners();
  }
}
