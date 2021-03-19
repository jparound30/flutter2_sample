
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'myapp.dart';

void main() {
  Intl.defaultLocale = 'ja_JP';
  initializeDateFormatting('ja_JP', null).then((_) {
    runApp(MyApp());
  });
}

