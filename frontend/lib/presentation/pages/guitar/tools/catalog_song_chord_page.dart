import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CatalogSongChordPage extends StatelessWidget {
  const CatalogSongChordPage({
    super.key,
    required this.song,
  });

  final Map<String, dynamic> song;

  String _valueOf(String key) => (song[key] ?? '').toString().trim();

  Future<void> _openExternalUrl(String rawUrl) async {
    final url = rawUrl.trim();
    if (url.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final title = _valueOf('title');
    final artist = _valueOf('artist');
    final youtubeUrl = _valueOf('youtube_url');
    final sourceUrl = _valueOf('source_url');
    final thumbnailUrl = _valueOf('thumbnail_url');
    final chordSet = _valueOf('chord_set');
    final lyrics = _valueOf('lyrics');

    final chords = chordSet
        .split('|')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Text(
          'Trang hợp âm',
          style: GoogleFonts.splineSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: thumbnailUrl.isNotEmpty
                    ? Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _ThumbnailFallback(),
                      )
                    : const _ThumbnailFallback(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title.isEmpty ? 'Bài hát chưa có tiêu đề' : title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.splineSans(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              artist.isEmpty ? 'Đang cập nhật nghệ sĩ' : artist,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.splineSans(
                color: const Color(0xFFF59E0B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (youtubeUrl.isNotEmpty)
                  _ActionChipButton(
                    label: 'Mở YouTube',
                    icon: Icons.open_in_new_rounded,
                    onTap: () => _openExternalUrl(youtubeUrl),
                  ),
                if (sourceUrl.isNotEmpty)
                  _ActionChipButton(
                    label: 'Mở hợp âm gốc',
                    icon: Icons.music_note_rounded,
                    onTap: () => _openExternalUrl(sourceUrl),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (chords.isNotEmpty) ...[
              Text(
                'Bộ hợp âm',
                style: GoogleFonts.splineSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chords
                    .map(
                      (chord) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          chord,
                          style: GoogleFonts.splineSans(
                            color: const Color(0xFFF9FAFB),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'Lời bài hát',
              style: GoogleFonts.splineSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Text(
                lyrics.isNotEmpty
                    ? lyrics
                    : 'Database hiện chưa có lyrics chi tiết cho bài này. Bạn có thể bấm "Mở hợp âm gốc" để xem nội dung đầy đủ.',
                style: GoogleFonts.splineSans(
                  color: const Color(0xFFE5E7EB),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF27272A),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF3F3F46)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFF59E0B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.splineSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1F2937),
      child: const Center(
        child: Icon(Icons.music_note_rounded, size: 44, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}
