import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/housing/housing_details_page.dart';
import 'package:diplomka/housing/housing_filter_page.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:diplomka/housing/widgets/housing_list_card.dart';
import 'package:diplomka/housing/widgets/housing_map_background.dart';

class HousingPage extends StatefulWidget {
  const HousingPage({super.key});

  @override
  State<HousingPage> createState() => _HousingPageState();
}

class _HousingPageState extends State<HousingPage> {
  bool _searchExpanded = false;
  bool _showListSheet = false;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _expandSearch() {
    setState(() => _searchExpanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  void _collapseSearch() {
    setState(() => _searchExpanded = false);
    _searchFocus.unfocus();
  }

  Future<void> _openFilter() async {
    final applied = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const HousingFilterPage()),
    );
    if (applied == true && mounted) {
      setState(() => _showListSheet = true);
    }
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
    return Scaffold(
      body: Stack(
        children: [
          HousingMapBackground(onMarkerTap: _openDetails),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _topBar(),
            ),
          ),
          Positioned(
            right: 16,
            bottom: _showListSheet ? 200 : 100,
            child: _locationButton(),
          ),
          if (_showListSheet) _listBottomSheet(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        Expanded(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              ),
              child: _searchExpanded
                  ? _searchField(key: const ValueKey('housing-search'))
                  : const SizedBox(key: ValueKey('housing-search-collapsed')),
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          child: _searchExpanded
              ? _circleButton(
                  Icons.close,
                  key: const ValueKey('close'),
                  onTap: _collapseSearch,
                )
              : _circleButton(
                  Icons.search,
                  key: const ValueKey('search'),
                  onTap: _expandSearch,
                ),
        ),
        const SizedBox(width: 8),
        _mapFilterToggle(),
      ],
    );
  }

  Widget _searchField({Key? key}) {
    return Container(
      key: key,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(51),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: HomeTheme.accent),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              style: const TextStyle(fontSize: 16, color: HomeTheme.tagMuted),
              decoration: const InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(fontSize: 16, color: HomeTheme.tagMuted),
              ),
              onSubmitted: (_) => _collapseSearch(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, {Key? key, required VoidCallback onTap}) {
    return Material(
      key: key,
      color: HomeTheme.surfaceBackground,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 24, color: HomeTheme.accent),
        ),
      ),
    );
  }

  Widget _mapFilterToggle() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleSegment(
            icon: Icons.map_outlined,
            selected: true,
            onTap: () {},
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
            size: 24,
            color: selected ? Colors.white : HomeTheme.accent,
          ),
        ),
      ),
    );
  }

  Widget _locationButton() {
    return Material(
      color: HomeTheme.surfaceBackground,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {},
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.near_me, size: 22, color: HomeTheme.accent),
        ),
      ),
    );
  }

  Widget _listBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 56,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${HousingItem.nearbyList.length}',
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
                            color: HomeTheme.accentLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: HousingItem.nearbyList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = HousingItem.nearbyList[index];
                    return HousingListCard(
                      item: item,
                      highlighted: index == 1,
                      onTap: () => _openDetails(item),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showListSheet = false),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
