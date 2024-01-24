import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, Map<String, dynamic>> _localizedValues = {
    'en': {
      'title': 'Sudoku Solver',
      'clear': 'CLEAR',
      'calculate': 'CALCULATE',
      'tips':
          'Tap the grid to enter 1-9 numbers, and then tap the calculate button to get the result',
      'getAnsTips': (int tryCnt) {
        return 'The system tried $tryCnt ${tryCnt > 1 ? 'times' : 'time'} hard ';
      },
      'noAns': 'found no solution to this question',
      'tellRes': 'just to tell you the result',
    },
    'zh': {
      'title': '数独计算器',
      'clear': '清空',
      'calculate': '计算',
      'tips': '点击格子输入 1-9 的数字，输入完成后，点击计算按钮获取结果',
      'getAnsTips': (int tryCnt) {
        return '系统努力尝试了 $tryCnt 次';
      },
      'noAns': '发现此题无解',
      'tellRes': '只为告诉你结果'
    },
  };

  String get tellRes => _localizedValues[locale.languageCode]?['tellRes'];

  String get noAns => _localizedValues[locale.languageCode]?['noAns'];

  String getAnsTips(int tryCnt) =>
      _localizedValues[locale.languageCode]?['getAnsTips'](tryCnt);

  String get title => _localizedValues[locale.languageCode]?['title'];

  String get tips => _localizedValues[locale.languageCode]?['tips'];

  String get clear => _localizedValues[locale.languageCode]?['clear'];

  String get calculate => _localizedValues[locale.languageCode]?['calculate'];
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
