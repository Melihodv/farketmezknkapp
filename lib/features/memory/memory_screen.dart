import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/user_model.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  bool _isListView = true;
  String? _activeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAllVisits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final visits = provider.allVisits;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
        ),
        title: Text(
          'Hafıza',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          // Toggle list/map (map simulated for now)
          GestureDetector(
            onTap: () => setState(() => _isListView = !_isListView),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    _isListView ? Icons.map_rounded : Icons.list_rounded,
                    color: AppTheme.accent,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _isListView ? 'Harita' : 'Liste',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStats(visits),
          _buildFilters(context, provider),
          Expanded(
            child: _isListView ? _buildList(visits, provider) : _buildMap(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<VisitModel> visits, AppProvider provider) {
    if (visits.isEmpty) return _buildEmptyState();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        return _buildVisitCard(context, visit, provider)
            .animate()
            .slideX(begin: -0.1, duration: 300.ms, delay: Duration(milliseconds: index * 50))
            .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
      },
    );
  }

  Widget _buildMap(AppProvider provider) {
    final visits = provider.allVisits;
    if (visits.isEmpty) return _buildEmptyState();

    // Kategori bazlı renkli marker'lar
    final markers = visits.map((v) {
      return Marker(
        markerId: MarkerId(v.placeId),
        position: LatLng(v.latitude ?? 41.0082, v.longitude ?? 28.9784),
        icon: BitmapDescriptor.defaultMarkerWithHue(_catMarkerHue(v.placeCategory)),
        infoWindow: InfoWindow(
          title: v.placeName,
          snippet: '${_catLabel(v.placeCategory)} • ${v.visitCount} kez',
        ),
      );
    }).toSet();

    final initialPos = visits.isNotEmpty && visits.first.latitude != null
        ? LatLng(visits.first.latitude!, visits.first.longitude!)
        : provider.currentPosition != null
            ? LatLng(provider.currentPosition!.latitude, provider.currentPosition!.longitude)
            : const LatLng(41.0082, 28.9784);

    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: initialPos, zoom: 12),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }

  double _catMarkerHue(String id) {
    switch (id) {
      case 'food':          return BitmapDescriptor.hueOrange;
      case 'coffee':        return BitmapDescriptor.hueYellow;
      case 'dessert':       return BitmapDescriptor.hueRose;
      case 'entertainment': return BitmapDescriptor.hueViolet;
      case 'outdoor':       return BitmapDescriptor.hueGreen;
      case 'culture':       return BitmapDescriptor.hueAzure;
      default:              return BitmapDescriptor.hueRed;
    }
  }

  String _catLabel(String id) {
    switch (id) {
      case 'food':          return 'Yemek';
      case 'coffee':        return 'Kafe';
      case 'dessert':       return 'Tatlı';
      case 'entertainment': return 'Eğlence';
      case 'outdoor':       return 'Dışarı';
      case 'culture':       return 'Kültür';
      default:              return 'Mekan';
    }
  }

  Widget _buildStats(List<VisitModel> visits) {
    final total = visits.length;
    final liked = visits.where((v) => v.positiveCount > 0).length;
    final disliked = visits.where((v) => v.isBlocked).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🗺️', '$total', 'Keşif'),
          _buildDivider(),
          _buildStatItem('👍', '$liked', 'Beğenilen'),
          _buildDivider(),
          _buildStatItem('🚫', '$disliked', 'Engellenen'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppTheme.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.cardBorder,
    );
  }

  Widget _buildFilters(BuildContext context, AppProvider provider) {
    final allFilters = [
      {'id': null, 'label': 'Tümü'},
      ...AppConstants.categories,
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: allFilters.length,
        itemBuilder: (context, index) {
          final filter = allFilters[index];
          final isActive = _activeFilter == filter['id'];

          return GestureDetector(
            onTap: () {
              setState(() => _activeFilter = filter['id'] as String?);
              provider.loadAllVisits(categoryFilter: filter['id'] as String?);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accent : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppTheme.accent : AppTheme.cardBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _catFilterIcon(filter['id'] as String?),
                    color: isActive ? Colors.white : AppTheme.accent,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter['label'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, VisitModel visit, AppProvider provider) {
    final catData = AppConstants.categories.firstWhere(
      (c) => c['id'] == visit.placeCategory,
      orElse: () => AppConstants.categories.first,
    );

    final isBlocked = visit.isBlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
      color: isBlocked ? AppTheme.error.withValues(alpha: 0.3) : AppTheme.cardBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGlow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_catIcon(visit.placeCategory), color: AppTheme.accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              visit.placeName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isBlocked
                                    ? AppTheme.textTertiary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (isBlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '🚫 Engellendi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${visit.visitCount} kez ziyaret',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Feedback chips
            Row(
              children: [
                if (visit.positiveCount > 0)
                  _buildFeedbackChip('👍 ${visit.positiveCount}', AppTheme.success),
                if (visit.positiveCount > 0 && visit.negativeCount > 0)
                  const SizedBox(width: 8),
                if (visit.negativeCount > 0)
                  _buildFeedbackChip('👎 ${visit.negativeCount}', AppTheme.error),
                const Spacer(),
                // Tekrar öner button
                GestureDetector(
                  onTap: () async {
                    await provider.resetPlaceToPool(visit.placeId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${visit.placeName} tekrar öneri havuzuna eklendi!',
                            style: GoogleFonts.plusJakartaSans(),
                          ),
                          backgroundColor: AppTheme.accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGlow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '🔄 Tekrar öner',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.accentGlow, shape: BoxShape.circle),
            child: const Icon(Icons.map_rounded, color: AppTheme.accent, size: 40),
          ),
          const SizedBox(height: 20),
          Text('Henüz gidilen yer yok', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Farketmez\'e sor ve yeni yerler keşfet!', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  IconData _catIcon(String id) {
    switch (id) {
      case 'food':          return Icons.restaurant_rounded;
      case 'coffee':        return Icons.local_cafe_rounded;
      case 'dessert':       return Icons.cake_rounded;
      case 'entertainment': return Icons.sports_esports_rounded;
      case 'outdoor':       return Icons.park_rounded;
      case 'culture':       return Icons.account_balance_rounded;
      default:              return Icons.place_rounded;
    }
  }

  IconData _catFilterIcon(String? id) {
    if (id == null) return Icons.grid_view_rounded;
    return _catIcon(id);
  }
}
