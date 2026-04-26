import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/backend_api.dart';
import 'package:guidetar/presentation/pages/support_page.dart';

import 'package:guidetar/presentation/pages/edit_profile_page.dart';
import 'package:guidetar/presentation/pages/favorite_list.dart';
import 'package:guidetar/presentation/pages/weekly_info_page.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedNavIndex = 2;
  bool _isLoadingProfile = true;
  String? _profileError;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });
    try {
      final profile = await BackendApi.getMe();
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = profile;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _profileError = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0D),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 76, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeaderSection(
                    displayName: (_profile?['display_name'] ?? '').toString(),
                    username: (_profile?['username'] ?? '').toString(),
                    rankLabel: (_profile?['rank_label'] ?? '').toString(),
                    avatarUrl: (_profile?['avatar_url'] ?? '').toString(),
                    isLoading: _isLoadingProfile,
                  ),
                  if (_profileError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _profileError!,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFFA366),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WeeklyInfoPage(),
                        ),
                      );
                    },
                    child: const _StreakSection(),
                  ),
                  const SizedBox(height: 24),
                  const _FavoritesSection(),
                  const SizedBox(height: 28),
                  const _RecentLessonsSection(),
                  const SizedBox(height: 28),
                  const _PersonalNotesSection(),
                  const SizedBox(height: 20),
                  const _ProfileSettingsSection(),
                ],
              ),
            ),
            const _ProfileTopBar(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: HomeBottomNavbar(
                  selectedIndex: _selectedNavIndex,
                  onChanged: (index) {
                    if (index == 0) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      return;
                    }
                    setState(() {
                      _selectedNavIndex = index;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar();

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
              const SizedBox(width: 16),
              Text(
                'Thông tin tài khoản',
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
              const SizedBox(width: 8),
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

class _ProfileHeaderSection extends StatelessWidget {
  const _ProfileHeaderSection({
    required this.displayName,
    required this.username,
    required this.rankLabel,
    required this.avatarUrl,
    required this.isLoading,
  });

  final String displayName;
  final String username;
  final String rankLabel;
  final String avatarUrl;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 128,
            height: 128,
            child: Stack(
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2A2A29),
                      width: 4,
                    ),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.asset(
                            'assets/images/profile_user_avatar.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/profile_user_avatar.png',
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 22.5,
                      height: 22.5,
                      child: _SafeSvgAsset(
                        'assets/icons/profile_camera_badge.svg',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isLoading
                ? 'Đang tải...'
                : (displayName.isNotEmpty ? displayName : username),
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.9,
              height: 40 / 36,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A29),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color.fromRGBO(87, 66, 53, 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF97F08),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  rankLabel.isNotEmpty ? rankLabel.toUpperCase() : 'MEMBER',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFDEC1AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakSection extends StatelessWidget {
  const _StreakSection();

  @override
  Widget build(BuildContext context) {
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const states = [1, 1, 1, 1, 2, 0, 0];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF20201E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ĐỘNG LỰC HIỆN TẠI',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFDEC1AF),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.2,
                      height: 16 / 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 36 / 30,
                      ),
                      children: const [
                        TextSpan(text: 'Chuỗi '),
                        TextSpan(
                          text: '14 ngày',
                          style: TextStyle(color: Color(0xFFF97F08)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 44,
                height: 46.5,
                child: _SafeSvgAsset('assets/icons/profile_streak_mark.svg'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (i) {
              final int state = states[i];
              final bool isToday = state == 2;
              final bool isDone = state == 1;
              final bool isFuture = state == 0;

              return Column(
                children: [
                  Text(
                    days[i],
                    style: GoogleFonts.manrope(
                      color: isToday
                          ? const Color(0xFFF97F08)
                          : (isFuture
                                ? const Color.fromRGBO(222, 193, 175, 0.4)
                                : const Color(0xFFDEC1AF)),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 15 / 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFFF97F08)
                          : (isDone
                                ? const Color.fromRGBO(249, 127, 8, 0.42)
                                : const Color(0xFF2A2A29)),
                      borderRadius: BorderRadius.circular(12),
                      border: isToday
                          ? Border.all(
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                              width: 2,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: isFuture
                        ? Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(222, 193, 175, 0.2),
                              shape: BoxShape.circle,
                            ),
                          )
                        : SizedBox(
                            width: 13.58,
                            height: 10.02,
                            child: _SafeSvgAsset(
                              'assets/icons/profile_check.svg',
                            ),
                          ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FavoritesSection extends StatelessWidget {
  const _FavoritesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách yêu thích',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 28 / 20,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FavoriteListPage(),
                  ),
                );
              },
              child: Text(
                'XEM TẤT CẢ',
                style: GoogleFonts.manrope(
                  color: const Color(0xFFFFB786),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  height: 16 / 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 216,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _FavoriteSongCard(
                imageAsset: 'assets/images/profile_favorite_1.png',
                title: 'Sóng Gió',
                artist: 'K-ICM x Jack',
              ),
              SizedBox(width: 8),
              _FavoriteSongCard(
                imageAsset: 'assets/images/profile_favorite_2.png',
                title: 'Đom đóm',
                artist: 'K-ICM x Jack',
              ),
              SizedBox(width: 8),
              _FavoriteSongCard(
                imageAsset: 'assets/images/profile_favorite_3.png',
                title: 'Bạc phận',
                artist: 'K-ICM x Jack',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FavoriteSongCard extends StatelessWidget {
  const _FavoriteSongCard({
    required this.imageAsset,
    required this.title,
    required this.artist,
  });

  final String imageAsset;
  final String title;
  final String artist;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 144,
              height: 144,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(imageAsset, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(0, 0, 0, 0),
                          Color.fromRGBO(0, 0, 0, 0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
            ),
          ),
          Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: const Color(0xFFDEC1AF),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentLessonsSection extends StatelessWidget {
  const _RecentLessonsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bài học gần đây',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                height: 24 / 16,
              ),
            ),
            Text(
              'XEM TẤT CẢ',
              style: GoogleFonts.manrope(
                color: const Color(0xFFFFB786),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                height: 20 / 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _RecentCourseCard(
          imageAsset: 'assets/images/profile_recent_1.png',
          title: 'Giới thiệu về piano',
          progress: 0.2,
          progressText: '20%',
        ),
        const SizedBox(height: 20),
        const _RecentCourseCard(
          imageAsset: 'assets/images/profile_recent_2.png',
          title: 'Sóng gió',
          subtitle: 'Sóng gió | ICM x Jack | Official Music',
          progress: 0.88,
          progressText: '88%',
        ),
      ],
    );
  }
}

class _RecentCourseCard extends StatelessWidget {
  const _RecentCourseCard({
    required this.imageAsset,
    required this.title,
    required this.progress,
    required this.progressText,
    this.subtitle,
  });

  final String imageAsset;
  final String title;
  final String? subtitle;
  final double progress;
  final String progressText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF20201E),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 192,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(imageAsset, fit: BoxFit.cover),
                _SafeSvgAsset('assets/icons/profile_recent_overlay.svg'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
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
                if (subtitle == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18.33,
                          height: 13.33,
                          child: _SafeSvgAsset(
                            'assets/icons/profile_meta_lessons.svg',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '12 Bài học',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFA9ABB3),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 24 / 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 10,
                          height: 15,
                          child: _SafeSvgAsset(
                            'assets/icons/profile_meta_songs.svg',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '4 Bài hát',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFA9ABB3),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 24 / 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFDEC1AF),
                        fontSize: 14,
                        height: 20 / 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PROGRESS',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFDEC1AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        height: 16 / 12,
                      ),
                    ),
                    Text(
                      progressText,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFFB786),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: const Color(0xFF353533),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFF97F08),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalNotesSection extends StatelessWidget {
  const _PersonalNotesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ghi chú cá nhân',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 28 / 20,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A29),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: _SafeSvgAsset('assets/icons/profile_add_note.svg'),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'THÊM GHI CHÚ',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFFFB786),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _NoteCard(
          title: '24 THÁNG 10 • LUYỆN TẬP',
          body:
              'Tập trung vào sức mạnh của ngón út cho chuyển động Fmaj7. Giữ ngón cái thấp trên cần đàn.',
          borderColor: Color.fromRGBO(255, 183, 134, 0.4),
        ),
        const SizedBox(height: 12),
        const _NoteCard(
          title: '23 THÁNG 10 • NGUỒN CẢM HỨNG',
          body:
              "Hãy tham khảo cách Miles Davis chơi solo trong 'So What' để có trải nghiệm ứng tấu giai điệu tốt hơn.",
          borderColor: Color.fromRGBO(146, 204, 255, 0.4),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'XEM TẤT CẢ GHI CHÚ',
            style: GoogleFonts.manrope(
              color: const Color(0xFFDEC1AF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              height: 16 / 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.title,
    required this.body,
    required this.borderColor,
  });

  final String title;
  final String body;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1A),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFDEC1AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 16 / 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 16,
                height: 4,
                child: _SafeSvgAsset('assets/icons/profile_more_h.svg'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: GoogleFonts.manrope(
              color: const Color(0xFFE5E2E0),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 22.75 / 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingsSection extends StatelessWidget {
  const _ProfileSettingsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color.fromRGBO(87, 66, 53, 0.1))),
      ),
      child: Column(
        children: [
          const _SettingRow(
            iconAsset: 'assets/icons/profile_setting.svg',
            text: 'Cài đặt ứng dụng',
          ),
          const _SettingRow(
            iconAsset: 'assets/icons/profile_policy.svg',
            text: 'Điều khoản & chính sách',
          ),
          _SettingRow(
            iconAsset: 'assets/icons/profile_support.svg',
            text: 'Hỗ trợ',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SupportPage()));
            },
          ),
          const SizedBox(height: 8),
          const Opacity(
            opacity: 0.6,
            child: Text(
              'ĐĂNG XUẤT',
              style: TextStyle(
                color: Color(0xFFFAC38A),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                height: 20 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.iconAsset, required this.text, this.onTap});

  final String iconAsset;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20.1,
                    height: 20,
                    child: _SafeSvgAsset(iconAsset),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    text,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 24 / 16,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 4.317,
                height: 7,
                child: _SafeSvgAsset('assets/icons/profile_chevron_right.svg'),
              ),
            ],
          ),
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
