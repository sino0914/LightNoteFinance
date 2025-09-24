class AppConstants {
  static const String appName = 'Light Note Finance';

  static const int defaultDailySummaryCount = 10;
  static const int maxDailySummaryCount = 15;
  static const int watchAdPoints = 10;

  static const Map<String, int> purchasePrices = {
    'bookmarkFeature': 100,
    'highlightFeature': 150,
    'chooseBooks': 200,
    'extraDailySummary': 50,
  };

  static const List<String> weekdays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  static const List<String> weekdaysShort = [
    '日',
    '一',
    '二',
    '三',
    '四',
    '五',
    '六'
  ];
}

class HiveBoxNames {
  static const String userBox = 'user_box';
  static const String booksBox = 'books_box';
  static const String summariesBox = 'summaries_box';
  static const String settingsBox = 'settings_box';
}

class Routes {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String bookList = '/';
  static const String summary = '/summary';
  static const String history = '/history';
  static const String points = '/points';
}