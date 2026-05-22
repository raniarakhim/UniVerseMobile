/// Связь с главным экраном (вкладки нижней навигации).
class HomeShell {
  HomeShell._();

  static void Function(int index)? _switchTab;
  static void Function()? _resetHomeCategory;
  static void Function()? _openJobsFromHome;
  static void Function()? _openEventsFromHome;
  static void Function()? _openHomeTab;

  static void bind({
    required void Function(int index) switchTab,
    required void Function() resetHomeCategory,
    required void Function() openJobsFromHome,
    required void Function() openEventsFromHome,
    required void Function() openHomeTab,
  }) {
    _switchTab = switchTab;
    _resetHomeCategory = resetHomeCategory;
    _openJobsFromHome = openJobsFromHome;
    _openEventsFromHome = openEventsFromHome;
    _openHomeTab = openHomeTab;
  }

  static void unbind({
    required void Function(int index) switchTab,
    required void Function() resetHomeCategory,
    required void Function() openJobsFromHome,
    required void Function() openEventsFromHome,
    required void Function() openHomeTab,
  }) {
    if (_switchTab == switchTab) _switchTab = null;
    if (_resetHomeCategory == resetHomeCategory) _resetHomeCategory = null;
    if (_openJobsFromHome == openJobsFromHome) _openJobsFromHome = null;
    if (_openEventsFromHome == openEventsFromHome) _openEventsFromHome = null;
    if (_openHomeTab == openHomeTab) _openHomeTab = null;
  }

  /// Вкладка Housing (большая карта).
  static void openHousingTab() {
    _switchTab?.call(2);
  }

  static void openJobsFromHome() => _openJobsFromHome?.call();

  static void openEventsFromHome() => _openEventsFromHome?.call();

  static void openHomeTab() => _openHomeTab?.call();
}
