import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/pages/guitar/tools/artist_jack_album_page.dart';
import 'package:guidetar/presentation/state/follow_state.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class ArtistJackPage extends StatefulWidget {
  const ArtistJackPage({super.key});

  @override
  State<ArtistJackPage> createState() => _ArtistJackPageState();
}

class _ArtistJackPageState extends State<ArtistJackPage> {
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

  void _toggleFollow() {
    FollowState.isFollowingJack.value = !FollowState.isFollowingJack.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 530,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/artist_jack_hero.png',
                          fit: BoxFit.cover,
                        ),
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
                                'Jack - J97',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                  letterSpacing: -2.6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '358,2 N người xem hằng tháng',
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
                  ),
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
                        ValueListenableBuilder<bool>(
                          valueListenable: FollowState.isFollowingJack,
                          builder: (context, followed, _) {
                            return GestureDetector(
                              onTap: _toggleFollow,
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                decoration: BoxDecoration(
                                  color: followed ? Colors.white : const Color(0xFFFF923E),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: followed
                                        ? const Color.fromRGBO(255, 255, 255, 0.75)
                                        : const Color.fromRGBO(0, 0, 0, 0.31),
                                  ),
                                  boxShadow: followed
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
                                child: Text(
                                  followed ? 'Đã theo dõi' : 'Theo dõi',
                                  style: GoogleFonts.manrope(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
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
                                builder: (_) => const ArtistJackAlbumPage(),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _PopularSongRow(
                          rank: '1',
                          title: 'Đứa Trẻ Mùa Đông Chí',
                          listens: '1.206.831 lượt nghe',
                          imageAsset: 'assets/images/artist_song_1.png',
                        ),
                        SizedBox(height: 8),
                        _PopularSongRow(
                          rank: '2',
                          title: 'Chúng Ta Rồi Sẽ Hạnh Phúc',
                          listens: '6.614.863 lượt nghe',
                          imageAsset: 'assets/images/artist_song_2.png',
                        ),
                        SizedBox(height: 8),
                        _PopularSongRow(
                          rank: '3',
                          title: 'Thiên Lý Ơi',
                          listens: '9.995.638 lượt nghe',
                          imageAsset: 'assets/images/artist_song_3.png',
                        ),
                        SizedBox(height: 8),
                        _PopularSongRow(
                          rank: '4',
                          title: 'Đom Đóm',
                          listens: '12.672.144 lượt nghe',
                          imageAsset: 'assets/images/artist_song_4.png',
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

class _PopularSongRow extends StatelessWidget {
  const _PopularSongRow({
    required this.rank,
    required this.title,
    required this.listens,
    required this.imageAsset,
  });

  final String rank;
  final String title;
  final String listens;
  final String imageAsset;

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
            child: Image.asset(
              imageAsset,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
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
