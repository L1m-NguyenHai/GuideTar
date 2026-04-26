import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class ArtistJackAlbumPage extends StatefulWidget {
  const ArtistJackAlbumPage({super.key});

  @override
  State<ArtistJackAlbumPage> createState() => _ArtistJackAlbumPageState();
}

class _ArtistJackAlbumPageState extends State<ArtistJackAlbumPage> {
  int _selectedNavIndex = 1;

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
    const songs = [
      _AlbumSong('Sóng gió', 'K-ICM, Jack', 'assets/images/artist_song_1.png'),
      _AlbumSong('Bạc Phận', 'K-ICM, Jack', 'assets/images/artist_song_2.png'),
      _AlbumSong('Đom đóm', 'Jack(J97)', 'assets/images/artist_song_4.png'),
      _AlbumSong('Thiên lý ơi', 'Jack(J97)', 'assets/images/artist_song_3.png'),
      _AlbumSong('Hoa Hải đường', 'Jack(J97)', 'assets/images/artist_song_2.png'),
      _AlbumSong('HOA DIÊN VĨ', 'Jack(J97)', 'assets/images/artist_song_1.png'),
      _AlbumSong('ĐỨA TRẺ MÙA ĐÔNG CHÍ', 'Jack(J97)', 'assets/images/artist_song_1.png'),
      _AlbumSong('Về bên anh', 'Jack(G5R)', 'assets/images/artist_song_2.png'),
      _AlbumSong('Hồng nhan', 'Jack(J97)', 'assets/images/artist_song_3.png'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 116),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color(0xFF121212),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
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
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFFF48C25),
                                  size: 24,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Hợp âm chuẩn',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.splineSans(
                                  color: Colors.white,
                                  fontSize: 34 / 2,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.6,
                                  height: 32 / 24,
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(244, 140, 37, 0.2),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color.fromRGBO(244, 140, 37, 0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.person_outline_rounded,
                                color: Color(0xFFF48C25),
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Tìm kiếm bài hát, nghệ sĩ',
                                style: GoogleFonts.splineSans(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                    child: Text(
                      'Album Jack(J97)',
                      style: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 28 / 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      children: [
                        for (final song in songs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _AlbumSongRow(song: song),
                          ),
                      ],
                    ),
                  ),
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

class _AlbumSong {
  const _AlbumSong(this.title, this.artist, this.imageAsset);

  final String title;
  final String artist;
  final String imageAsset;
}

class _AlbumSongRow extends StatelessWidget {
  const _AlbumSongRow({required this.song});

  final _AlbumSong song;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              song.imageAsset,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.splineSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 24 / 16,
                  ),
                ),
                Text(
                  song.artist,
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
          const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}
