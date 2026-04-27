import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/backend_api.dart';
import 'package:guidetar/presentation/pages/guitar/tools/catalog_song_chord_page.dart';
import 'package:guidetar/presentation/state/follow_state.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class ChordBookPage extends StatefulWidget {
  const ChordBookPage({super.key});

  @override
  State<ChordBookPage> createState() => _ChordBookPageState();
}

class _ChordBookPageState extends State<ChordBookPage> {
  int _selectedNavIndex = 1;
  late final Future<List<Map<String, dynamic>>> _recommendedFuture;
  late final Future<List<Map<String, dynamic>>> _artistsFuture;

  @override
  void initState() {
    super.initState();
    _recommendedFuture = BackendApi.getCatalogRecommendedSongs(limit: 10);
    _artistsFuture = BackendApi.getCatalogArtists(limit: 20);
  }

  void _onNavChanged(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChordHeader(),
                  SizedBox(height: 16),
                  _RecommendedSection(recommendedFuture: _recommendedFuture),
                  SizedBox(height: 24),
                  _ArtistSection(artistsFuture: _artistsFuture),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: HomeBottomNavbar(
                  selectedIndex: _selectedNavIndex,
                  onChanged: _onNavChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChordHeader extends StatelessWidget {
  const _ChordHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Hợp âm juẩn',
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      height: 32 / 24,
                    ),
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(244, 140, 37, 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color.fromRGBO(244, 140, 37, 0.3)),
                ),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset('assets/icons/chord_filter_icon.svg'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.fromLTRB(40, 14, 12, 14),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tìm tên bài hát, ca sĩ hoặc gì cũng được...',
                  style: GoogleFonts.splineSans(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12.5,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: SvgPicture.asset('assets/icons/chord_search_icon.svg'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection({required this.recommendedFuture});

  final Future<List<Map<String, dynamic>>> recommendedFuture;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Đề xuất',
            style: GoogleFonts.splineSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 224,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: recommendedFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <Map<String, dynamic>>[];
              if (items.isNotEmpty) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final title = (item['title'] ?? '').toString();
                    final artist = (item['artist'] ?? '').toString();
                    final imageUrl = (item['thumbnail_url'] ?? '').toString();
                    final hasYoutube = (item['youtube_url'] ?? '').toString().isNotEmpty;
                    final tag = hasYoutube ? 'youtube' : 'hợp âm';
                    final tagColor = hasYoutube ? const Color(0xFFDC2626) : const Color(0xFFF97316);

                    return _RecommendCard(
                      imageUrl: imageUrl,
                      title: title,
                      subtitle: artist,
                      tag: tag,
                      tagColor: tagColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CatalogSongChordPage(song: item),
                          ),
                        );
                      },
                    );
                  },
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Text(
                    'Chưa tải được dữ liệu bài hát từ database. Hãy kiểm tra backend rồi mở lại trang.',
                    style: GoogleFonts.splineSans(
                      color: const Color(0xFFD1D5DB),
                      fontSize: 13,
                      height: 18 / 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecommendCard extends StatelessWidget {
  const _RecommendCard({
    this.imageAsset,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    this.onTap,
  });

  final String? imageAsset;
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 256,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 256,
              height: 144,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (imageUrl != null && imageUrl!.isNotEmpty)
                        ? Image.network(
                            imageUrl!,
                            width: 256,
                            height: 144,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              imageAsset ?? 'assets/images/chord_reco_song_gio.png',
                              width: 256,
                              height: 144,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            imageAsset ?? 'assets/images/chord_reco_song_gio.png',
                            width: 256,
                            height: 144,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.splineSans(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          height: 15 / 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.splineSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 24 / 16,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.splineSans(
                color: Colors.white,
                fontSize: 12,
                height: 16 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistSection extends StatelessWidget {
  const _ArtistSection({required this.artistsFuture});

  final Future<List<Map<String, dynamic>>> artistsFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: artistsFuture,
      builder: (context, snapshot) {
        final artistItems = snapshot.data ?? const <Map<String, dynamic>>[];
        if (artistItems.isNotEmpty) {
          final cards = artistItems
              .map(
                (item) => _SquareCardData(
                  title: (item['artist_name'] ?? '').toString(),
                  circleImage: true,
                  imageUrl: (item['image_url'] ?? '').toString(),
                ),
              )
              .toList(growable: false);

          return _SquareCardSection(
            title: 'Nghệ sĩ yêu thích của bạn',
            cards: cards,
          );
        }

        return ValueListenableBuilder<bool>(
          valueListenable: FollowState.isFollowingJack,
          builder: (context, isFollowingJack, _) {
            final cards = <_SquareCardData>[
              if (isFollowingJack)
                const _SquareCardData(
                  title: 'Jack - J97',
                  circleImage: true,
                  imageAsset: 'assets/images/chord_artist_jack_followed.png',
                ),
              const _SquareCardData(
                title: 'Sơn Tùng M-TP',
                circleImage: true,
                imageAsset: 'assets/images/chord_artist_sontung.png',
              ),
              const _SquareCardData(
                title: 'Alan Walker',
                circleImage: true,
                imageAsset: 'assets/images/chord_artist_alanwalker.png',
              ),
            ];

            return _SquareCardSection(
              title: 'Nghệ sĩ yêu thích của bạn',
              cards: cards,
            );
          },
        );
      },
    );
  }
}

class _SquareCardSection extends StatelessWidget {
  const _SquareCardSection({required this.title, required this.cards});

  final String title;
  final List<_SquareCardData> cards;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: GoogleFonts.splineSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 204.5,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _SquareCard(data: cards[index]),
          ),
        ),
      ],
    );
  }
}

class _SquareCardData {
  const _SquareCardData({
    required this.title,
    required this.circleImage,
    this.imageAsset,
    this.imageUrl,
  });

  final String? imageAsset;
  final String? imageUrl;
  final String title;
  final bool circleImage;
}

class _SquareCard extends StatelessWidget {
  const _SquareCard({required this.data});

  final _SquareCardData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(data.circleImage ? 90 : 12),
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: (data.imageUrl != null && data.imageUrl!.isNotEmpty)
                        ? Image.network(
                            data.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              data.imageAsset ?? 'assets/images/profile_user_avatar.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            data.imageAsset ?? 'assets/images/profile_user_avatar.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                  if (!data.circleImage)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), Color(0x99000000)],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 160,
            child: Text(
              data.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: data.circleImage ? TextAlign.center : TextAlign.left,
              style: GoogleFonts.splineSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
