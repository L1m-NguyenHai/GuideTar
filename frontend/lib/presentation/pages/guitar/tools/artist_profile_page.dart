import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/data/backend_api.dart';
import 'package:guidetar/presentation/pages/guitar/tools/artist_songs_page.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class ArtistProfilePage extends StatefulWidget {
  const ArtistProfilePage({
    super.key,
    required this.artistName,
    this.imageUrl,
  });

  final String artistName;
  final String? imageUrl;

  @override
  State<ArtistProfilePage> createState() => _ArtistProfilePageState();
}

class _ArtistProfilePageState extends State<ArtistProfilePage> {
  int _selectedNavIndex = 1;
  late Future<Map<String, dynamic>> _detailFuture;
  bool _isUpdatingFollow = false;
  bool? _isFollowing;

  @override
  void initState() {
    super.initState();
    _detailFuture = BackendApi.getArtistDetail(widget.artistName);
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

  Future<void> _toggleFollow(String artistName) async {
    if (_isUpdatingFollow) return;

    final nextValue = !(_isFollowing ?? false);
    setState(() {
      _isUpdatingFollow = true;
    });

    try {
      if (nextValue) {
        await BackendApi.followArtist(artistName);
      } else {
        await BackendApi.unfollowArtist(artistName);
      }
      if (!mounted) return;
      setState(() {
        _isFollowing = nextValue;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingFollow = false;
        });
      }
    }
  }

  Widget _buildCover(Map<String, dynamic> data) {
    final imageUrl = (data['image_url'] ?? widget.imageUrl ?? '').toString();
    final artistName = (data['artist_name'] ?? widget.artistName).toString();
    final followersCount = (data['followers_count'] ?? 0).toString();
    final songCount = (data['song_count'] ?? 0).toString();

    return SizedBox(
      height: 530,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildGradientFallback(artistName),
            )
          else
            _buildGradientFallback(artistName),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.16),
                  Color.fromRGBO(0, 0, 0, 0.88),
                ],
                stops: [0.12, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
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
          ),
          Positioned(
            left: 32,
            right: 32,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artistName,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: -2.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$followersCount người theo dõi • $songCount bài hát',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientFallback(String artistName) {
    final fallbackInitial = artistName.trim().isNotEmpty
        ? String.fromCharCode(artistName.trim().runes.first).toUpperCase()
        : '?';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF0E0E0E)],
        ),
      ),
      child: Center(
        child: Text(
          fallbackInitial,
          style: GoogleFonts.manrope(
            color: const Color(0xFFFF923E),
            fontSize: 96,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _detailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF923E)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Không tải được trang nghệ sĩ.',
                      style: GoogleFonts.splineSans(color: Colors.white),
                    ),
                  );
                }

                final data = snapshot.data ?? <String, dynamic>{};
                final artistName = (data['artist_name'] ?? widget.artistName).toString();
                final popularSongs = (data['popular_songs'] as List<dynamic>? ?? const <dynamic>[])
                    .map((item) => Map<String, dynamic>.from(item as Map))
                    .toList(growable: false);
                final initialFollowing = (data['is_following'] as bool?) ?? false;
                if (_isFollowing == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _isFollowing == null) {
                      setState(() {
                        _isFollowing = initialFollowing;
                      });
                    }
                  });
                }
                final isFollowing = _isFollowing ?? initialFollowing;

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCover(data),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF923E),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFF1A1A1A),
                                  size: 34,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: _isUpdatingFollow ? null : () => _toggleFollow(artistName),
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                decoration: BoxDecoration(
                                  color: isFollowing ? Colors.white : const Color(0xFFFF923E),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isFollowing
                                        ? const Color.fromRGBO(255, 255, 255, 0.75)
                                        : const Color.fromRGBO(0, 0, 0, 0.31),
                                  ),
                                  boxShadow: isFollowing
                                      ? const [
                                          BoxShadow(
                                            color: Color.fromRGBO(0, 0, 0, 0.35),
                                            blurRadius: 8,
                                            offset: Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: _isUpdatingFollow
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                      )
                                    : Text(
                                        isFollowing ? 'Đã theo dõi' : 'Theo dõi',
                                        style: GoogleFonts.manrope(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 50,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF923E),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(Icons.more_horiz, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Phổ biến',
                              style: GoogleFonts.splineSans(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ArtistSongsPage(
                                      artistName: artistName,
                                      songs: popularSongs,
                                    ),
                                  ),
                                );
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                'XEM TẤT CẢ',
                                style: GoogleFonts.splineSans(
                                  color: const Color(0xFFFF923E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            if (popularSongs.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Chưa có bài hát nổi bật cho nghệ sĩ này.',
                                  style: GoogleFonts.splineSans(color: Colors.white),
                                ),
                              )
                            else
                              ...popularSongs.asMap().entries.map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _PopularSongRow(
                                        rank: '${entry.key + 1}',
                                        title: (entry.value['title'] ?? '').toString(),
                                        listens: (entry.value['artist'] ?? '').toString(),
                                        imageUrl: (entry.value['thumbnail_url'] ?? '').toString(),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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

class _PopularSongRow extends StatelessWidget {
  const _PopularSongRow({
    required this.rank,
    required this.title,
    required this.listens,
    required this.imageUrl,
  });

  final String rank;
  final String title;
  final String listens;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: Text(
              rank,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF57534E),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: const Color(0xFF2A2A2A),
                      child: const Icon(Icons.music_note, color: Colors.white54),
                    ),
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFF2A2A2A),
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.splineSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  listens,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF78716C),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Color(0xFF78716C), size: 16),
        ],
      ),
    );
  }
}
