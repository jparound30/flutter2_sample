import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter2_sample/launch_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'env_vars.dart';
import 'providers/credential_info.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("START: " + defaultTargetPlatform.toString());
    // PaginatedDataTableのヘッダ行部分の背景色を設定
    var dataTableThemeData = ThemeData.dark().dataTableTheme.copyWith(
      headingRowColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.18);
        },
      ),
    );

    // Naviratorでの遷移時のアニメーションを指定（flutter/packages/flutter/lib/src/material/page_transitions_theme.dart）
    const Map<TargetPlatform, PageTransitionsBuilder> _defaultBuilders = <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
    };

    return ChangeNotifierProvider<CredentialInfo>(
      create: (_) {
        if (EnvVars.apiKey.isNotEmpty && EnvVars.spaceName.isNotEmpty) {
          return CredentialInfo(
              space: EnvVars.spaceName, apiKey: EnvVars.apiKey);
        }
        return CredentialInfo();
      },
      child: MaterialApp(
        title: 'Backlog Alternate',
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,

            // textTheme: GoogleFonts.mPlus1pTextTheme(),
            textTheme: GoogleFonts.notoSansTextTheme(),
            dataTableTheme: dataTableThemeData,
            pageTransitionsTheme: PageTransitionsTheme(builders: _defaultBuilders)
        ),
        home: LaunchScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
