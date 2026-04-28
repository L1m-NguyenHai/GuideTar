import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class CatalogSongChordPage extends StatefulWidget {
  const CatalogSongChordPage({super.key, required this.song});

  final Map<String, dynamic> song;

  @override
  State<CatalogSongChordPage> createState() => _CatalogSongChordPageState();
}

class _CatalogSongChordPageState extends State<CatalogSongChordPage> {
  static const String _amChordImageAsset = 'assets/images/am_chord_board.png';
  static const String _em7ChordImageAsset = 'assets/images/em7_chord_board.png';

  int _selectedNavIndex = 1;
  YoutubePlayerController? _youtubeController;

  String _valueOf(String key) => (widget.song[key] ?? '').toString().trim();

  String get _title => _valueOf('title');
  String get _artist => _valueOf('artist');
  String get _youtubeUrl => _valueOf('youtube_url');
  String get _sourceUrl => _valueOf('source_url');
  String get _thumbnailUrl => _valueOf('thumbnail_url');
  String get _keyOriginal => _valueOf('key_original');
  String get _rhythmName => _valueOf('rhythm_name');
  String get _note => _valueOf('note').isNotEmpty ? _valueOf('note') : _valueOf('lyric_note_text');
  String get _chordSet => _valueOf('chord_set');
  String get _lyrics => _valueOf('lyrics');

  @override
  void initState() {
    super.initState();
    _initYoutubeController();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _initYoutubeController() {
    final videoId = YoutubePlayer.convertUrlToId(_youtubeUrl);
    if (videoId == null || videoId.isEmpty) {
      return;
    }

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        hideControls: false,
        controlsVisibleAtStart: true,
        enableCaption: false,
      ),
    );
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

  void _showAmChordBoard() {
    _showChordBoard(chordLabel: '[Am]', imageAsset: _amChordImageAsset);
  }

  void _showEm7ChordBoard() {
    _showChordBoard(chordLabel: '[Em7]', imageAsset: _em7ChordImageAsset);
  }

  void _showChordBoard({required String chordLabel, String? imageAsset}) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.55),
      builder: (dialogContext) {
        return Material(
          color: Colors.transparent,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(dialogContext).pop(),
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: () {},
                child: Container(
                  width: 183,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 183,
                        child: Text(
                          chordLabel,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.splineSans(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 23 / 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (imageAsset != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            imageAsset,
                            width: 183,
                            height: 221,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 183,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Chưa có ảnh hợp âm cho $chordLabel',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.splineSans(
                              color: Colors.black,
                              fontSize: 14,
                              height: 20 / 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleChordTap(String chord) {
    final normalized = chord.toLowerCase();
    if (normalized.contains('em7')) {
      _showEm7ChordBoard();
      return;
    }

    if (normalized.contains('am')) {
      _showAmChordBoard();
      return;
    }

    _showChordBoard(chordLabel: '[$chord]');
  }

  List<String> _availableChords() {
    final set = <String>[];
    for (final raw in _chordSet.split('|')) {
      final chord = raw.trim();
      if (chord.isNotEmpty && !set.contains(chord)) {
        set.add(chord);
      }
    }
    return set;
  }

  String _toneLabel() {
    if (_keyOriginal.isNotEmpty) {
      return '[${_keyOriginal.toUpperCase()}]';
    }
    final chords = _availableChords();
    if (chords.isNotEmpty) {
      return '[${chords.first}]';
    }
    return '[--]';
  }

  String _rhythmLabel() {
    if (_rhythmName.isNotEmpty) {
      final n = _rhythmName.toLowerCase();
      if (n.contains('balad') || n.contains('ballad') || n.contains('balad')) {
        return 'Ballad';
      }
      return _rhythmName;
    }
    return 'Ballad';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SongHeader(
                    title: _title,
                    artist: _artist,
                    sourceUrl: _sourceUrl,
                  ),
                  const SizedBox(height: 14),
                  _MetaGrid(
                    toneLabel: _toneLabel(),
                    rhythmLabel: _rhythmLabel(),
                  ),
                  const SizedBox(height: 16),
                  // toolbar first (Đổi tone etc.) then the media/video below it
                  const _ToolBar(),
                  const SizedBox(height: 16),
                  _MediaCard(
                    youtubeController: _youtubeController,
                    youtubeUrl: _youtubeUrl,
                    thumbnailUrl: _thumbnailUrl,
                    title: _title,
                    artist: _artist,
                  ),
                  if (_note.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _note,
                        style: GoogleFonts.splineSans(
                          color: const Color(0xFFE6FFFFFF),
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _LyricsSection(
                    note: _note,
                    lyrics: _lyrics,
                    onChordTap: _handleChordTap,
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

class _SongHeader extends StatelessWidget {
  const _SongHeader({
    required this.title,
    required this.artist,
    required this.sourceUrl,
  });

  final String title;
  final String artist;
  final String sourceUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.translucent,
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isEmpty ? 'Bài hát' : title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.splineSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  height: 32 / 24,
                ),
              ),
              GestureDetector(
                onTap: sourceUrl.isEmpty
                    ? null
                    : () {
                        Navigator.of(context).maybePop();
                      },
                child: Text(
                  artist.isEmpty ? 'Đang cập nhật' : artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.splineSans(
                    color: const Color(0xFFF79633),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    height: 28 / 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF20201F),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 11.7,
                height: 11.1,
                child: SvgPicture.asset('assets/icons/songgio_rating_star.svg'),
              ),
              const SizedBox(width: 4),
              Text(
                'DB',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
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
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.toneLabel, required this.rhythmLabel});

  final String toneLabel;
  final String rhythmLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetaCard(
            label: 'Tone',
            value: toneLabel,
            valueColor: const Color(0xFFFF923E),
            iconAsset: 'assets/icons/songgio_meta_tone.svg',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MetaCard(
            label: 'Điệu',
            value: rhythmLabel,
            valueColor: Colors.white,
            iconAsset: 'assets/icons/songgio_meta_style.svg',
          ),
        ),
      ],
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.iconAsset,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 79,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFADAAAA),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    height: 15 / 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: valueColor,
                    fontSize: label == 'Tone' ? 20 : 18,
                    fontWeight: label == 'Tone' ? FontWeight.w800 : FontWeight.w700,
                    height: 28 / (label == 'Tone' ? 20 : 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 18, height: 21, child: SvgPicture.asset(iconAsset)),
        ],
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  const _MediaCard({
    required this.youtubeController,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.artist,
  });

  final YoutubePlayerController? youtubeController;
  final String youtubeUrl;
  final String thumbnailUrl;
  final String title;
  final String artist;

  @override
  Widget build(BuildContext context) {
    final hasYoutube = youtubeController != null;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 335,
            height: 171,
            child: hasYoutube
                ? YoutubePlayer(
                    controller: youtubeController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: const Color(0xFFFF923E),
                    progressColors: const ProgressBarColors(
                      playedColor: Color(0xFFFF923E),
                      handleColor: Color(0xFFFF923E),
                      bufferedColor: Color.fromRGBO(255, 255, 255, 0.35),
                      backgroundColor: Color.fromRGBO(255, 255, 255, 0.2),
                    ),
                    aspectRatio: 16 / 9,
                    onReady: () {},
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      thumbnailUrl.isNotEmpty
                          ? Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/chord_reco_song_gio.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/chord_reco_song_gio.png',
                              fit: BoxFit.cover,
                            ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(0, 0, 0, 0.2),
                                Color.fromRGBO(0, 0, 0, 0.06),
                                Color.fromRGBO(0, 0, 0, 0.6),
                              ],
                              stops: [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(0, 0, 0, 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Center(
                            child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title.isEmpty ? 'Video YouTube' : title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 32 / 12,
          ),
        ),
        if (artist.isNotEmpty)
          Text(
            artist,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: const Color(0xFFADAAAA),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 18 / 11,
            ),
          ),
        if (!hasYoutube && youtubeUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Không đọc được video id từ link YouTube.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: const Color(0xFFE0E0E0),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _ToolBar extends StatelessWidget {
  const _ToolBar();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(60, 60, 60, 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: const [
            _PillButton(
              iconAsset: 'assets/icons/songgio_btn_transpose.svg',
              label: 'Đổi tone',
              active: false,
            ),
            SizedBox(width: 8),
            _PillButton(
              iconAsset: 'assets/icons/songgio_btn_autoscroll.svg',
              label: 'Tự động cuộn',
              active: false,
            ),
            SizedBox(width: 8),
            _PillButton(
              iconAsset: 'assets/icons/songgio_btn_chord.svg',
              label: 'Hợp âm',
              active: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.iconAsset,
    required this.label,
    required this.active,
  });

  final String iconAsset;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color.fromRGBO(255, 146, 62, 0.1) : const Color.fromRGBO(87, 87, 87, 0.44),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          SizedBox(width: 10.5, height: 10.5, child: SvgPicture.asset(iconAsset)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: active ? const Color(0xFFFF923E) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _LyricsSection extends StatelessWidget {
  const _LyricsSection({
    required this.note,
    required this.lyrics,
    required this.onChordTap,
  });

  final String note;
  final String lyrics;
  final ValueChanged<String> onChordTap;

  @override
  Widget build(BuildContext context) {
    final cleanedLyrics = _stripDuplicatedLeadingNote(lyrics: lyrics, note: note);
    final blocks = _parseLyricsBlocks(cleanedLyrics);
    if (blocks.isEmpty) {
      return Text(
        'Database hiện chưa có lyrics chi tiết cho bài này.',
        style: GoogleFonts.splineSans(
          color: const Color(0xFFE6FFFFFF),
          fontSize: 16,
          height: 29.25 / 18,
          letterSpacing: 0.45,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks
          .map(
            (block) => block.title == null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: block.lines
                          .map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: _ChordLine(parts: _parseLyricLine(line), onChordTap: onChordTap),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _BorderLyricsBlock(
                      title: block.title!,
                      lines: block.lines.map(_parseLyricLine).toList(growable: false),
                      onChordTap: onChordTap,
                    ),
                  ),
          )
          .toList(growable: false),
    );
  }
}

class _LyricsBlockData {
  const _LyricsBlockData({required this.title, required this.lines});

  final String? title;
  final List<String> lines;
}

String _normalizeEscapedNewlines(String value) {
  return value.replaceAll('\\r\\n', '\n').replaceAll('\\n', '\n');
}

String _canonicalLine(String line) {
  return line.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _compactText(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('’', "'");
}

String _stripDuplicatedLeadingNote({required String lyrics, required String note}) {
  final normalizedLyrics = _normalizeEscapedNewlines(lyrics);
  final normalizedNote = _normalizeEscapedNewlines(note);
  if (normalizedLyrics.trim().isEmpty || normalizedNote.trim().isEmpty) {
    return normalizedLyrics;
  }

  final lyricLines = normalizedLyrics.split('\n').toList(growable: true);
  final noteLines = normalizedNote
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);

  if (noteLines.isEmpty || lyricLines.isEmpty) {
    return normalizedLyrics;
  }

  final noteCompact = _compactText(noteLines.join('\n'));
  if (noteCompact.isEmpty) {
    return normalizedLyrics;
  }

  final prefixLines = <String>[];
  for (final line in lyricLines) {
    if (line.trim().isEmpty) {
      if (prefixLines.isNotEmpty) {
        prefixLines.add(line);
      }
      continue;
    }

    prefixLines.add(line);
    final prefixCompact = _compactText(prefixLines.join('\n'));
    if (prefixCompact == noteCompact) {
      final deduped = lyricLines.sublist(prefixLines.length);
      while (deduped.isNotEmpty && deduped.first.trim().isEmpty) {
        deduped.removeAt(0);
      }
      return deduped.join('\n');
    }

    if (!noteCompact.startsWith(prefixCompact)) {
      break;
    }
  }

  var lyricIndex = 0;
  var noteIndex = 0;

  while (noteIndex < noteLines.length && lyricIndex < lyricLines.length) {
    if (lyricLines[lyricIndex].trim().isEmpty) {
      lyricIndex++;
      continue;
    }

    if (_canonicalLine(lyricLines[lyricIndex]) == _canonicalLine(noteLines[noteIndex])) {
      lyricIndex++;
      noteIndex++;
      continue;
    }

    break;
  }

  if (noteIndex == noteLines.length) {
    final deduped = lyricLines.sublist(lyricIndex);
    while (deduped.isNotEmpty && deduped.first.trim().isEmpty) {
      deduped.removeAt(0);
    }
    return deduped.join('\n');
  }

  return normalizedLyrics;
}

List<_LyricsBlockData> _parseLyricsBlocks(String lyrics) {
  // normalize escaped newline sequences (e.g. "\\n" stored in DB) to real newlines
  final normalized = _normalizeEscapedNewlines(lyrics);
  final lines = normalized.split('\n');
  final blocks = <_LyricsBlockData>[];
  String? currentTitle;
  final currentLines = <String>[];
  var sawHeading = false;
  var sawBlankLine = false;

  void flush() {
    if (currentTitle != null || currentLines.isNotEmpty) {
      blocks.add(_LyricsBlockData(title: currentTitle, lines: List<String>.from(currentLines)));
    }
    currentTitle = null;
    currentLines.clear();
  }

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      sawBlankLine = true;
      if (currentTitle != null || currentLines.isNotEmpty) {
        flush();
      }
      continue;
    }

    if (_looksLikeHeading(line)) {
      sawHeading = true;
      flush();
      currentTitle = _formatHeading(line);
      continue;
    }

    currentLines.add(rawLine);
  }

  flush();

  // If source has no explicit section markers, split long lyrics into readable stanzas.
  if (!sawHeading && !sawBlankLine) {
    return _chunkPlainLyricsIntoStanzas(blocks);
  }

  return blocks;
}

List<_LyricsBlockData> _chunkPlainLyricsIntoStanzas(List<_LyricsBlockData> blocks) {
  final plainLines = <String>[];
  for (final block in blocks) {
    if (block.title == null) {
      plainLines.addAll(block.lines.where((line) => line.trim().isNotEmpty));
    }
  }

  if (plainLines.length <= 4) {
    return blocks;
  }

  const stanzaSize = 4;
  final chunked = <_LyricsBlockData>[];
  for (var i = 0; i < plainLines.length; i += stanzaSize) {
    final end = (i + stanzaSize < plainLines.length) ? i + stanzaSize : plainLines.length;
    chunked.add(_LyricsBlockData(title: null, lines: plainLines.sublist(i, end)));
  }

  return chunked;
}

bool _looksLikeHeading(String line) {
  final normalized = line.replaceAll(':', '').trim();
  if (normalized.isEmpty) {
    return false;
  }

  final headingPattern = RegExp(
    r'^(verse|chorus|pre-chorus|pre chorus|bridge|intro|outro|rap|hook)(\s*\d+)?$',
    caseSensitive: false,
  );
  if (headingPattern.hasMatch(normalized)) {
    return true;
  }

  if (line.endsWith(':') && line.length <= 40) {
    return true;
  }

  final lettersOnly = normalized.replaceAll(RegExp(r'[^A-Za-zÀ-ỹ]'), '');
  return lettersOnly.isNotEmpty && lettersOnly == lettersOnly.toUpperCase() && normalized.length <= 30;
}

String _formatHeading(String line) {
  return line.replaceAll(':', '').trim().toUpperCase();
}

List<_LyricPart> _parseLyricLine(String line) {
  final parts = <_LyricPart>[];
  final matches = RegExp(r'\[[^\]]+\]').allMatches(line);
  var cursor = 0;

  for (final match in matches) {
    if (match.start > cursor) {
      parts.add(_LyricPart(line.substring(cursor, match.start), false));
    }
    parts.add(_LyricPart(match.group(0) ?? '', true));
    cursor = match.end;
  }

  if (cursor < line.length) {
    parts.add(_LyricPart(line.substring(cursor), false));
  }

  if (parts.isEmpty) {
    parts.add(_LyricPart(line, false));
  }

  return parts;
}

class _LyricPart {
  const _LyricPart(this.text, this.isChord);

  final String text;
  final bool isChord;
}

class _ChordLine extends StatelessWidget {
  const _ChordLine({required this.parts, required this.onChordTap});

  final List<_LyricPart> parts;
  final ValueChanged<String> onChordTap;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: parts
            .map(
              (part) => part.isChord && _extractChordLabel(part.text) != null
                  ? WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: () => onChordTap(_extractChordLabel(part.text)!),
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          part.text,
                          style: GoogleFonts.splineSans(
                            color: const Color(0xE6FF923E),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 29.25 / 18,
                            letterSpacing: 0.45,
                          ),
                        ),
                      ),
                    )
                  : TextSpan(
                      text: part.text,
                      style: GoogleFonts.splineSans(
                        color: part.isChord ? const Color(0xE6FF923E) : const Color(0xE6FFFFFF),
                        fontSize: 18,
                        fontWeight: part.isChord ? FontWeight.w600 : FontWeight.w400,
                        height: 29.25 / 18,
                        letterSpacing: 0.45,
                      ),
                    ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _BorderLyricsBlock extends StatelessWidget {
  const _BorderLyricsBlock({
    required this.title,
    required this.lines,
    required this.onChordTap,
  });

  final String title;
  final List<List<_LyricPart>> lines;
  final ValueChanged<String> onChordTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 0, 8),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color.fromRGBO(255, 146, 62, 0.2), width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.splineSans(
              color: const Color(0xFFFF923E),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.8,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (parts) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _ChordLine(parts: parts, onChordTap: onChordTap),
            ),
          ),
        ],
      ),
    );
  }
}

String? _extractChordLabel(String text) {
  final match = RegExp(r'\[([A-G][#b]?(?:m|maj7|m7|7|sus2|sus4|dim|aug)?(?:/[A-G][#b]?)?)\]').firstMatch(text);
  return match?.group(1);
}
