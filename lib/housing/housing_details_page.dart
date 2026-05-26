import 'package:flutter/material.dart';
import 'package:diplomka/housing/contact_owner_page.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/widgets/network_cover_image.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:diplomka/housing/models/housing_photos.dart';
import 'package:diplomka/housing/widgets/housing_price_label.dart';
import 'package:diplomka/core/navigation/home_shell.dart';
import 'package:diplomka/housing/widgets/housing_location_map.dart';
import 'package:diplomka/core/services/saved_housing_service.dart';

class HousingDetailsPage extends StatefulWidget {
  const HousingDetailsPage({super.key, this.item = HousingItem.studioSksu});

  final HousingItem item;

  @override
  State<HousingDetailsPage> createState() => _HousingDetailsPageState();
}

class _HousingDetailsPageState extends State<HousingDetailsPage> {
  final _savedService = SavedHousingService.instance;
  final PageController _photoController = PageController();
  int _photoIndex = 0;

  @override
  void initState() {
    super.initState();
    _savedService.addListener(_onSavedChanged);
  }

  @override
  void dispose() {
    _savedService.removeListener(_onSavedChanged);
    _photoController.dispose();
    super.dispose();
  }

  void _onSavedChanged() {
    if (mounted) setState(() {});
  }

  bool get _isSaved => _savedService.isSaved(widget.item.id);

  void _toggleSave() => _savedService.toggle(widget.item.id);

  @override
  void didUpdateWidget(covariant HousingDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _photoIndex = 0;
      if (_photoController.hasClients) {
        _photoController.jumpToPage(0);
      }
    }
  }

  void _openHousingMapTab() {
    Navigator.pop(context);
    HomeShell.openHousingTab();
  }

  void _openContact() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactOwnerPage(item: widget.item)),
    );
  }

  void _openHousing(HousingItem item) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HousingDetailsPage(key: ValueKey(item.id), item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _heroHeader(item)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  HomeTheme.horizontalPadding,
                  16,
                  HomeTheme.horizontalPadding,
                  120,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _titleRow(item),
                    const SizedBox(height: 16),
                    _statsRow(item),
                    const SizedBox(height: 16),
                    _sectionTitle('Amenities'),
                    const SizedBox(height: 12),
                    _amenityChips(item.amenities),
                    const SizedBox(height: 16),
                    _sectionTitle('About'),
                    const SizedBox(height: 12),
                    Text(
                      item.about,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 18 / 14,
                        color: HomeTheme.tagMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Location'),
                    const SizedBox(height: 12),
                    HousingLocationMap(
                      item: item,
                      height: 160,
                      interactive: false,
                      openExternalOnLabelTap: false,
                      onMapTap: _openHousingMapTab,
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Owner'),
                    const SizedBox(height: 12),
                    _ownerCard(item),
                    if (_similarFor(item).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _sectionTitle('Similar Houses'),
                      const SizedBox(height: 12),
                      _similarHouses(_similarFor(item)),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            left: HomeTheme.horizontalPadding,
            right: HomeTheme.horizontalPadding,
            bottom: 24,
            child: _bottomActions(),
          ),
        ],
      ),
    );
  }

  List<HousingItem> _similarFor(HousingItem item) => HousingItem.similarTo(item);

  Widget _heroHeader(HousingItem item) {
    final photos = item.galleryPhotos;
    return SizedBox(
      height: 316,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.horizontal) {
                return true;
              }
              return false;
            },
            child: PageView.builder(
              controller: _photoController,
              physics: const PageScrollPhysics(),
              itemCount: photos.length,
              onPageChanged: (i) => setState(() => _photoIndex = i),
              itemBuilder: (_, index) => SizedBox.expand(
                child: NetworkCoverImage(
                  key: ValueKey('${item.id}-$index-${photos[index]}'),
                  url: photos[index],
                  fallbackPath: HousingPhotos.defaultCover,
                ),
              ),
            ),
          ),
          Positioned(
            left: HomeTheme.horizontalPadding,
            right: HomeTheme.horizontalPadding,
            top: MediaQuery.paddingOf(context).top + 12,
            child: Row(
              children: [
                _overlayBack(context),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HomeTheme.surfaceBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '· Available',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HomeTheme.primary,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (i) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _photoIndex ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlayBack(BuildContext context) {
    return Material(
      color: HomeTheme.surfaceBackground,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => Navigator.pop(context),
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.arrow_back_ios_new, size: 20, color: HomeTheme.primary),
        ),
      ),
    );
  }

  Widget _titleRow(HousingItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 31 / 24,
                  color: HomeTheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: HomeTheme.tagMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.address,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: HomeTheme.placeholder,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        HousingPriceLabel(
          price: item.price,
          amountFontSize: 20,
          periodFontSize: 14,
          amountFontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _statsRow(HousingItem item) {
    return Row(
      children: [
        _statCard(Icons.meeting_room_outlined, item.roomsLabel),
        const SizedBox(width: 8),
        _statCard(Icons.square_foot_outlined, item.areaLabel),
        const SizedBox(width: 8),
        _statCard(Icons.apartment_outlined, item.floorLabel),
      ],
    );
  }

  Widget _statCard(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: HomeTheme.surfaceBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: HomeTheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HomeTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: HomeTheme.primary,
      ),
    );
  }

  Widget _amenityChips(List<String> amenities) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: amenities.map((a) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: HomeTheme.accentSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            a,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: HomeTheme.accentLight,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _ownerCard(HousingItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openContact,
        borderRadius: BorderRadius.circular(16),
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: HomeTheme.primary,
            child: Text(
              item.ownerName.isNotEmpty ? item.ownerName[0] : '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.ownerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: HomeTheme.primary,
                  ),
                ),
                Text(
                  item.ownerRole,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: HomeTheme.tagMuted.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          _socialIcon(Icons.chat, const Color(0xFF25D366), _openContact),
          const SizedBox(width: 8),
          _socialIcon(Icons.send, const Color(0xFF229ED9), _openContact),
        ],
      ),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _similarHouses(List<HousingItem> items) {
    return SizedBox(
      height: 208,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final h = items[index];
          final priceLabel = h.priceShort.isNotEmpty ? h.priceShort : h.price;
          return SizedBox(
            width: 178,
            height: 208,
            child: Material(
              color: HomeTheme.surfaceBackground,
              borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openHousing(h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 112,
                          width: 178,
                          child: NetworkCoverImage(
                            url: h.coverPhoto,
                            fallbackPath: HousingPhotos.defaultCover,
                          ),
                        ),
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              size: 14,
                              color: HomeTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              h.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: HomeTheme.primary,
                              ),
                            ),
                            Text(
                              h.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              priceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bottomActions() {
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: _toggleSave,
            icon: Icon(
              _isSaved ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: HomeTheme.primary,
            ),
            label: const Text(
              'Save',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.primary),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: HomeTheme.chipInactive,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _openContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                ),
              ),
              child: const Text(
                'Contact Landlord',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

