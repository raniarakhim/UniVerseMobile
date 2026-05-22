import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:url_launcher/url_launcher.dart';

/// Реальная карта OpenStreetMap (улицы Шымкента).
class HousingLocationMap extends StatelessWidget {
  const HousingLocationMap({
    super.key,
    this.item,
    this.markers = const [],
    this.height = 160,
    this.expand = false,
    this.interactive = true,
    this.initialZoom = 15,
    this.showAddressLabel = true,
    this.openExternalOnLabelTap = true,
    this.onMapTap,
    this.onMarkerTap,
  });

  /// Одно объявление (детали жилья).
  final HousingItem? item;

  /// Несколько меток (вкладка Housing).
  final List<HousingItem> markers;

  final double height;
  final bool expand;
  final bool interactive;
  final double initialZoom;
  final bool showAddressLabel;
  final bool openExternalOnLabelTap;
  final VoidCallback? onMapTap;
  final void Function(HousingItem item)? onMarkerTap;

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

  @override
  Widget build(BuildContext context) {
    final label = item?.mapAddress.isNotEmpty == true
        ? item!.mapAddress
        : (item?.address ?? '');

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
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.diplomka',
                  ),
                  MarkerLayer(
                    markers: _markerItems.map(_buildMarker).toList(),
                  ),
                ],
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
                            color: Colors.black.withValues(alpha: 0.15),
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

  Marker _buildMarker(HousingItem h) {
    return Marker(
      point: LatLng(h.latitude, h.longitude),
      width: 44,
      height: 44,
      child: GestureDetector(
        onTap: () {
          if (onMarkerTap != null) {
            onMarkerTap!(h);
          } else {
            _openExternalMap(h);
          }
        },
        child: const Icon(
          Icons.location_on,
          color: Color(0xFF7C3AED),
          size: 44,
        ),
      ),
    );
  }
}
