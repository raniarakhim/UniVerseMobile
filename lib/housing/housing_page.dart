import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/housing/widgets/housing_direction_icon.dart';
import 'package:diplomka/housing/housing_details_page.dart';
import 'package:diplomka/housing/housing_filter_page.dart';
import 'package:diplomka/housing/models/housing_filter_criteria.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:diplomka/housing/widgets/housing_list_card.dart';
import 'package:diplomka/housing/widgets/housing_location_map.dart';

class HousingPage extends StatefulWidget {
  const HousingPage({super.key});

  @override
  State<HousingPage> createState() => _HousingPageState();
}

class _HousingPageState extends State<HousingPage> {
  bool _searchExpanded = false;
  bool _showListSheet = false;
  bool _sheetFullScreen = false;
  HousingFilterCriteria _filters = HousingFilterCriteria.empty;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _listScrollController = ScrollController();

  /// Доля экрана для обычного (не полного) состояния панели — ниже = больше карты сверху.
  static const _sheetOpenFraction = 0.52;

  double _handleDragDelta = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final hasQuery = _searchController.text.trim().isNotEmpty;
    if (hasQuery && (!_showListSheet || !_searchExpanded)) {
      setState(() {
        _showListSheet = true;
        _searchExpanded = true;
        _sheetFullScreen = false;
      });
      return;
    }
    setState(() {});
  }

  void _onSheetPanStart() => _handleDragDelta = 0;

  void _onSheetPanUpdate(DragUpdateDetails details) {
    _handleDragDelta += details.delta.dy;
  }

  void _onSheetPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final pulledDown = _handleDragDelta > 6 || velocity > 150;
    final pulledUp = _handleDragDelta < -6 || velocity < -150;

    if (pulledDown) {
      if (_sheetFullScreen) {
        setState(() => _sheetFullScreen = false);
      } else if (_showListSheet) {
        _closeListSheet();
      }
    } else if (pulledUp && _showListSheet && !_sheetFullScreen) {
      setState(() => _sheetFullScreen = true);
    }
    _handleDragDelta = 0;
  }

  bool _onListScroll(ScrollNotification notification) {
    if (!_showListSheet) return false;

    if (notification is ScrollUpdateNotification && notification.dragDetails != null) {
      final atTop = notification.metrics.pixels <= notification.metrics.minScrollExtent + 0.5;
      final dy = notification.dragDetails!.delta.dy;
      if (atTop && dy > 0) {
        _handleDragDelta += dy;
      } else if (dy < 0) {
        _handleDragDelta = 0;
      }
    }

    if (notification is ScrollEndNotification && _handleDragDelta > 6) {
      _onSheetPanEnd(DragEndDetails(velocity: Velocity.zero));
    }
    return false;
  }

  Widget _sheetDragLine({required bool inside}) {
    return Container(
      width: 56,
      height: 4,
      decoration: BoxDecoration(
        color: inside ? const Color(0xFFD1D5DB) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: inside
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
    );
  }

  /// Верхняя зона: pan вверх/вниз переключает состояние панели.
  Widget _sheetDragSurface({
    required bool inside,
    required double height,
    bool showLine = true,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => _onSheetPanStart(),
      onPanUpdate: _onSheetPanUpdate,
      onPanEnd: _onSheetPanEnd,
      onPanCancel: () => _handleDragDelta = 0,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: showLine
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: inside ? 10 : 6),
                  child: _sheetDragLine(inside: inside),
                ),
              )
            : null,
      ),
    );
  }

  Widget _sheetHalfHeader(int count) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => _onSheetPanStart(),
      onPanUpdate: _onSheetPanUpdate,
      onPanEnd: _onSheetPanEnd,
      onPanCancel: () => _handleDragDelta = 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
            textAlign: TextAlign.left,
            TextSpan(
              children: [
                TextSpan(
                  text: '$count',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: HomeTheme.accentLight,
                  ),
                ),
                const TextSpan(
                  text: ' places nearby',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: HomeTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  List<HousingItem> get _filteredItems {
    final q = _searchController.text;
    return HousingItem.catalog.where((item) {
      return _filters.matches(item) && _filters.matchesSearch(item, q);
    }).toList();
  }

  void _openListSheet() {
    setState(() {
      _showListSheet = true;
      _searchExpanded = true;
      _sheetFullScreen = false;
    });
  }

  void _closeListSheet() {
    _searchFocus.unfocus();
    setState(() {
      _showListSheet = false;
      _searchExpanded = false;
      _sheetFullScreen = false;
    });
  }

  void _expandSearch() {
    setState(() => _searchExpanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  void _collapseSearch() {
    if (_showListSheet) return;
    setState(() => _searchExpanded = false);
    _searchFocus.unfocus();
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<HousingFilterCriteria?>(
      context,
      MaterialPageRoute(
        builder: (context) => HousingFilterPage(initial: _filters),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _filters = result);
    _openListSheet();
  }

  void _openDetails(HousingItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HousingDetailsPage(key: ValueKey(item.id), item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    final showOverlaySearch = !_sheetFullScreen && (_showListSheet || _searchExpanded);
    final media = MediaQuery.of(context);
    final sheetHeight = _showListSheet
        ? (_sheetFullScreen ? media.size.height : media.size.height * _sheetOpenFraction)
        : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          HousingLocationMap(
            markers: items.isEmpty ? HousingItem.catalog : items,
            expand: true,
            initialZoom: 12.5,
            showAddressLabel: false,
            interactive: !_sheetFullScreen,
            onMarkerTap: _openDetails,
          ),
          if (!(_showListSheet && _sheetFullScreen))
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _topBar(showSearchField: showOverlaySearch),
              ),
            ),
          if (_showListSheet && !_sheetFullScreen)
            Positioned(
              left: 0,
              right: 0,
              bottom: sheetHeight,
              height: 44,
              child: _sheetDragSurface(inside: false, height: 44),
            ),
          if (_showListSheet && !_sheetFullScreen)
            Positioned(
              right: 16,
              bottom: sheetHeight + 24,
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                child: _locationButton(),
              ),
            ),
          if (!_showListSheet)
            Positioned(
              right: 16,
              bottom: 100,
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                child: _locationButton(),
              ),
            ),
          if (_showListSheet) _listBottomSheet(items),
        ],
      ),
    );
  }

  Widget _topBar({required bool showSearchField}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: _expandableMapSearch(expanded: showSearchField),
          ),
        ),
        const SizedBox(width: 8),
        _mapFilterToggle(),
      ],
    );
  }

  /// Лупа справа → раскрывается влево; Stack + clip без overflow при анимации ширины.
  Widget _expandableMapSearch({required bool expanded}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: expanded ? maxW : 40,
          height: 40,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: HomeTheme.surfaceBackground,
            borderRadius: BorderRadius.circular(expanded ? 51 : 20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, box) {
              final showField = expanded && box.maxWidth > 72;
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: 0,
                    width: 40,
                    height: 40,
                    child: _searchLeadingIcon(expanded: expanded),
                  ),
                  if (showField)
                    Positioned(
                      left: 40,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: _searchTextInput(trailingPadding: 12),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _searchLeadingIcon({required bool expanded}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: expanded
            ? () {
                if (_searchController.text.isEmpty && !_showListSheet) {
                  _collapseSearch();
                }
              }
            : _expandSearch,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.search, size: 20, color: HomeTheme.accent),
        ),
      ),
    );
  }

  Widget _searchTextInput({double trailingPadding = 12}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onTap: _expandSearch,
            onChanged: (_) => _onSearchChanged(),
            style: const TextStyle(fontSize: 16, color: HomeTheme.primary),
            decoration: const InputDecoration(
              hintText: 'Search',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(fontSize: 16, color: HomeTheme.placeholder),
            ),
          ),
        ),
        if (_searchController.text.isNotEmpty)
          GestureDetector(
            onTap: () {
              _searchController.clear();
              _onSearchChanged();
            },
            child: Padding(
              padding: EdgeInsets.only(right: trailingPadding),
              child: const Icon(Icons.close, size: 18, color: HomeTheme.placeholder),
            ),
          )
        else
          SizedBox(width: trailingPadding),
      ],
    );
  }

  Widget _searchFieldRow() {
    return Row(
      children: [
        _searchLeadingIcon(expanded: true),
        Expanded(child: _searchTextInput(trailingPadding: 0)),
      ],
    );
  }

  Widget _searchField({Key? key}) {
    return Container(
      key: key,
      height: 40,
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(51),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _searchFieldRow(),
    );
  }

  Widget _circleButton(IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: HomeTheme.surfaceBackground,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: HomeTheme.accent),
        ),
      ),
    );
  }

  Widget _mapFilterToggle() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleSegment(
            icon: Icons.map_outlined,
            selected: true,
            onTap: _openListSheet,
          ),
          _toggleSegment(
            icon: Icons.tune,
            selected: false,
            onTap: _openFilter,
          ),
        ],
      ),
    );
  }

  Widget _toggleSegment({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? HomeTheme.accent : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(selected ? 30 : 20),
        side: selected
            ? const BorderSide(color: HomeTheme.companyTint, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: selected ? Colors.white : HomeTheme.accent,
          ),
        ),
      ),
    );
  }

  Widget _locationButton() {
    return Material(
      elevation: 3,
      shadowColor: Colors.black26,
      color: HomeTheme.surfaceBackground,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: _openListSheet,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Center(child: HousingDirectionIcon(size: 26)),
        ),
      ),
    );
  }

  Widget _listBottomSheet(List<HousingItem> items) {
    final media = MediaQuery.of(context);
    final sheetHeight = _sheetFullScreen
        ? media.size.height
        : media.size.height * _sheetOpenFraction;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        height: sheetHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: _sheetFullScreen
                      ? BorderRadius.zero
                      : const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: _sheetFullScreen
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    if (_sheetFullScreen) ...[
                      _sheetDragSurface(
                        inside: true,
                        height: media.padding.top + 52,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          children: [
                            Expanded(child: _searchField()),
                            const SizedBox(width: 8),
                            _circleButton(Icons.tune, onTap: _openFilter),
                          ],
                        ),
                      ),
                    ] else
                      _sheetHalfHeader(items.length),
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Ничего не найдено.\nИзмените поиск или фильтры.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: HomeTheme.tagMuted.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: _onListScroll,
                              child: ListView.separated(
                                controller: _listScrollController,
                                physics: const ClampingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                itemCount: items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return HousingListCard(
                                    item: item,
                                    highlighted: index == 1,
                                    onTap: () => _openDetails(item),
                                  );
                                },
                              ),
                            ),
                    ),
                    if (!_sheetFullScreen)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _closeListSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HomeTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                              ),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(height: media.padding.bottom + 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
