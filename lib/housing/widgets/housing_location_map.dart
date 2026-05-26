import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/services/saved_housing_service.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:diplomka/housing/widgets/housing_map_pins.dart';
import 'package:url_launcher/url_launcher.dart';

/// Карта жилья — тёмный стиль (Carto Dark) и метки по Figma.
class HousingLocationMap extends StatelessWidget {
  const HousingLocationMap({
    super.key,
    this.item,
    this.markers = const [],
    this.highlightedId,
    this.height = 160,
    this.expand = false,
    this.interactive = true,
    this.initialZoom = 15,
    this.showAddressLabel = true,
    this.openExternalOnLabelTap = true,
    this.onMapTap,
    this.onMarkerTap,
  });

  final HousingItem? item;
  final List<HousingItem> markers;
  final String? highlightedId;
  final double height;
  final bool expand;
  final bool interactive;
  final double initialZoom;
  final bool showAddressLabel;
  final bool openExternalOnLabelTap;
  final VoidCallback? onMapTap;
  final void Function(HousingItem item)? onMarkerTap;

  /// Тёмная карта (бесплатные тайлы Carto).
  static const _darkTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
  static const _tileSubdomains = ['a', 'b', 'c', 'd'];

  static const _shymkentCenter = LatLng(42.3154, 69.5869);

  LatLng get _center {
    if (item != null) return LatLng(item!.latitude, item!.longitude);
    if (markers.isNotEmpty) {
      return LatLng(markers.first.latitude, markers.first.longitude);
    }
    return _shymkentCenter;
  }

  List<HousingItem> get _markerItems {
    if (item != null) return [item!];
    return markers;
  }

  Future<void> _openExternalMap(HousingItem target) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${target.latitude},${target.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _pinLabel(HousingItem h) {
    final t = h.title.trim();
    if (t.isEmpty) return 'A';
    return t[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final label = item?.mapAddress.isNotEmpty == true
        ? item!.mapAddress
        : (item?.address ?? '');
    final savedService = SavedHousingService.instance;
    final primaryId = highlightedId ??
        (item?.id ?? (_markerItems.isNotEmpty ? _markerItems.first.id : null));

    final mapStack = Stack(
      children: [
        AbsorbPointer(
          absorbing: onMapTap != null,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: initialZoom,
              interactionOptions: InteractionOptions(
                flags: interactive && onMapTap == null
                    ? InteractiveFlag.all
                    : InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _darkTileUrl,
                subdomains: _tileSubdomains,
                userAgentPackageName: 'com.example.diplomka',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              MarkerLayer(
                markers: [
                  for (var i = 0; i < _markerItems.length; i++)
                    _buildMarker(
                      _markerItems[i],
                      isPrimary: _markerItems[i].id == primaryId,
                      isSaved: savedService.isSaved(_markerItems[i].id),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (expand)
          const Positioned(
            left: 4,
            bottom: 4,
            child: Text(
              '© OpenStreetMap · CARTO',
              style: TextStyle(fontSize: 9, color: Colors.white38),
            ),
          ),
        if (onMapTap != null)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onMapTap,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        if (showAddressLabel && label.isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item != null && openExternalOnLabelTap
                    ? () => _openExternalMap(item!)
                    : null,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: HomeTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                      if (item != null && openExternalOnLabelTap) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.open_in_new, size: 12, color: Colors.white70),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (expand) {
      return SizedBox.expand(child: mapStack);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: mapStack,
      ),
    );
  }

  Marker _buildMarker(
    HousingItem h, {
    required bool isPrimary,
    required bool isSaved,
  }) {
    Widget pin;
    double w;
    double hSize;

    if (isSaved) {
      pin = const HousingBookmarkMapPin();
      w = 28;
      hSize = 28;
    } else if (isPrimary) {
      pin = HousingPrimaryMapPin(label: _pinLabel(h));
      w = 56;
      hSize = 72;
    } else {
      pin = const HousingListingMapPin();
      w = 14;
      hSize = 14;
    }

    return Marker(
      point: LatLng(h.latitude, h.longitude),
      width: w,
      height: hSize,
      alignment: isPrimary ? Alignment.bottomCenter : Alignment.center,
      child: GestureDetector(
        onTap: () {
          if (onMarkerTap != null) {
            onMarkerTap!(h);
          } else {
            _openExternalMap(h);
          }
        },
        child: pin,
      ),
    );
  }
}
