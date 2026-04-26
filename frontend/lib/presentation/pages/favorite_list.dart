import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/backend_api.dart';

class FavoriteListPage extends StatefulWidget {
  const FavoriteListPage({super.key});

  @override
  State<FavoriteListPage> createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  int _selectedTabIndex = 0; // 0 for Songs, 1 for Lessons
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _songs = const [];
  List<Map<String, dynamic>> _lessons = const [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        BackendApi.getFavoriteSongs(),
        BackendApi.getFavoriteLessons(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _songs = results[0];
        _lessons = results[1];
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0D),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const _FavoriteListHeader(),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab Switcher
                    _TabSwitcher(
                      selectedIndex: _selectedTabIndex,
                      onTabChanged: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                    ),
                    const Gap(32),
                    // Song/Lesson List
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      Text(
                        _error!,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFFFA366),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (_selectedTabIndex == 0)
                      _SongList(songs: _songs)
                    else
                      _LessonList(lessons: _lessons),
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

class _FavoriteListHeader extends StatelessWidget {
  const _FavoriteListHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: const Color(0xFF0E0E0D),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: _SafeSvgAsset('assets/icons/profile_back.svg'),
                ),
              ),
              const Gap(16),
              Text(
                'Danh sách yêu thích',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFE5E2E0),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 28 / 20,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 12,
                height: 18,
                child: _SafeSvgAsset('assets/icons/profile_logo_note.svg'),
              ),
              const Gap(8),
              Text(
                'GuideTar',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFF4F4F5),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  height: 28 / 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const _TabSwitcher({required this.selectedIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF20201E),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? const Color(0xFFF97F08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Bài hát',
                    style: GoogleFonts.manrope(
                      color: selectedIndex == 0
                          ? const Color(0xFF5B2A00)
                          : const Color(0xFFDEC1AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? const Color(0xFFF97F08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Bài học',
                    style: GoogleFonts.manrope(
                      color: selectedIndex == 1
                          ? const Color(0xFF5B2A00)
                          : const Color(0xFFDEC1AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongList extends StatelessWidget {
  const _SongList({required this.songs});

  final List<Map<String, dynamic>> songs;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Text(
        'Bạn chưa có bài hát yêu thích.',
        style: GoogleFonts.manrope(
          color: const Color(0xFFDEC1AF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        songs.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _FavoriteSongItem(
            title: (songs[index]['title'] ?? '').toString(),
            artist: (songs[index]['artist'] ?? '').toString(),
            imageUrl: (songs[index]['thumbnail_url'] ?? '').toString(),
          ),
        ),
      ),
    );
  }
}

class _FavoriteSongItem extends StatelessWidget {
  final String title;
  final String artist;
  final String imageUrl;

  const _FavoriteSongItem({
    required this.title,
    required this.artist,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF20201E).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Song Thumbnail
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const AssetImage('assets/images/profile_user_avatar.png')
                          as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Gap(16),
          // Song Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFFE5E2E0),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 28 / 18,
                  ),
                ),
                const Gap(4),
                Text(
                  artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFDEC1AF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          // Action Buttons
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: Handle favorite toggle
                },
                child: SizedBox(
                  width: 20,
                  height: 18.35,
                  child: _SafeSvgAsset('assets/icons/favorite_heart.svg'),
                ),
              ),
              const Gap(12),
              GestureDetector(
                onTap: () {
                  // TODO: Handle more options
                },
                child: SizedBox(
                  width: 4,
                  height: 16,
                  child: _SafeSvgAsset('assets/icons/more_options.svg'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  const _LessonList({required this.lessons});

  final List<Map<String, dynamic>> lessons;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return Text(
        'Bạn chưa có bài học yêu thích.',
        style: GoogleFonts.manrope(
          color: const Color(0xFFDEC1AF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        lessons.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _FavoriteLessonCard(
            title: (lessons[index]['title'] ?? '').toString(),
            lessons: 1,
            songs: null,
            imageUrl: (lessons[index]['thumbnail_url'] ?? '').toString(),
          ),
        ),
      ),
    );
  }
}

class _FavoriteLessonCard extends StatelessWidget {
  final String title;
  final int lessons;
  final int? songs;
  final String imageUrl;

  const _FavoriteLessonCard({
    required this.title,
    required this.lessons,
    required this.imageUrl,
    this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFF20201E)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            Container(
              width: double.infinity,
              height: 192,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage(
                              'assets/images/profile_user_avatar.png',
                            )
                            as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Course Info
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 28 / 20,
                              ),
                            ),
                            const Gap(8),
                            Row(
                              children: [
                                // Lessons count
                                SizedBox(
                                  width: 18.33,
                                  height: 13.33,
                                  child: _SafeSvgAsset(
                                    'assets/icons/profile_meta_lessons.svg',
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  '$lessons Bài học',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFA9ABB3),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 24 / 16,
                                  ),
                                ),
                                // Songs count (if available)
                                if (songs != null) ...[
                                  const Gap(16),
                                  SizedBox(
                                    width: 10,
                                    height: 15,
                                    child: _SafeSvgAsset(
                                      'assets/icons/profile_meta_songs.svg',
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    '$songs Bài hát',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFA9ABB3),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 24 / 16,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      // Action Buttons
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // TODO: Handle favorite toggle
                            },
                            child: SizedBox(
                              width: 20,
                              height: 18.35,
                              child: _SafeSvgAsset(
                                'assets/icons/favorite_heart.svg',
                              ),
                            ),
                          ),
                          const Gap(12),
                          GestureDetector(
                            onTap: () {
                              // TODO: Handle more options
                            },
                            child: SizedBox(
                              width: 4,
                              height: 16,
                              child: _SafeSvgAsset(
                                'assets/icons/more_options.svg',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafeSvgAsset extends StatelessWidget {
  const _SafeSvgAsset(this.assetPath);

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => Center(
        child: Icon(
          Icons.image_not_supported,
          size: 16,
          color: const Color(0xFF717171),
        ),
      ),
    );
  }
}
