import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:guidetar/data/auth_session.dart';
import 'package:guidetar/data/backend_api.dart';
import 'package:guidetar/presentation/pages/guitar/tools/dechord_result_page.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class DeChordPage extends StatefulWidget {
  const DeChordPage({super.key});

  @override
  State<DeChordPage> createState() => _DeChordPageState();
}

class _DeChordPageState extends State<DeChordPage> {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: '',
  );

  static const List<String> _processingSteps = [
    'Đang chuẩn bị dữ liệu âm thanh...',
    'Đang upload file lên AI backend...',
    'Đang tách beat với madmom...',
    'Đang nhận diện hợp âm bằng model...',
  ];

  int _selectedNavIndex = 1;
  bool _isProcessing = false;
  Timer? _processingTicker;
  int _processingElapsedSeconds = 0;
  int _processingStepIndex = 0;
  final TextEditingController _youtubeUrlController = TextEditingController();
  PlatformFile? _selectedFile;
  String? _selectedFileName;
  String? _processingThumbnailUrl;
  bool _processingIsYoutubeSource = false;
  String? _errorMessage;
  bool _isLoadingRecent = true;
  String? _recentError;
  List<Map<String, dynamic>> _recentAnalyses = const [];
  bool _deferRecentLoadUntilAnalyzeDone = false;

  @override
  void initState() {
    super.initState();
    if (_isProcessing) {
      _deferRecentLoadUntilAnalyzeDone = true;
      _startProcessingTicker();
    } else {
      _loadRecentAnalyses();
    }
  }

  @override
  void dispose() {
    _stopProcessingTicker();
    _youtubeUrlController.dispose();
    super.dispose();
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

  Future<void> _pickLocalSong() async {
    if (_isProcessing) return;

    try {
      FilePickerResult? selection = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['mp3'],
        withData: kIsWeb,
      );

      // Some plugin builds may not fully support extension filtering.
      // Fallback to generic picker so user can still choose a file.
      selection ??= await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
        withData: kIsWeb,
      );

      if (!mounted || selection == null || selection.files.isEmpty) {
        return;
      }

      final file = selection.files.first;
      setState(() {
        _selectedFile = file;
        _selectedFileName = file.name;
        _errorMessage = null;
        if (_youtubeUrlController.text.trim().isNotEmpty) {
          _youtubeUrlController.clear();
        }
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Không mở được trình chọn file trên thiết bị này (${error.code}). Vui lòng thử lại hoặc mở app Files/Storage.';
      });
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'File picker chưa được nạp trong bản chạy hiện tại. Vui lòng stop app và chạy lại full build.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không mở được trình chọn file. Vui lòng thử lại.';
      });
    }
  }

  Future<void> _analyzeSelectedSong() async {
    if (_isProcessing) return;

    final selected = _selectedFile;
    if (selected == null) {
      setState(() {
        _errorMessage = 'Vui lòng chọn file MP3 trước khi phân tích.';
      });
      return;
    }

    if (!selected.name.toLowerCase().endsWith('.mp3')) {
      setState(() {
        _errorMessage = 'Hiện tại AI DeChord MVP chỉ hỗ trợ MP3.';
      });
      return;
    }

    await _runAnalyzeFlow(
      selected: selected,
      displayName: selected.name,
      resultFileName: _selectedFileName,
      resultFilePath: _selectedFile?.path,
      resultFileBytes: _selectedFile?.bytes,
    );
  }

  Future<void> _analyzeYoutubeUrl() async {
    if (_isProcessing) return;

    final url = _youtubeUrlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập link YouTube trước khi phân tích.';
      });
      return;
    }

    if (!_looksLikeYoutubeUrl(url)) {
      setState(() {
        _errorMessage = 'Link YouTube không hợp lệ. Hãy dán link watch hoặc youtu.be.';
      });
      return;
    }

    final preview = await _fetchYoutubePreview(url);
    final title = preview?['title']?.toString();
    final thumbnail = preview?['thumbnail_url']?.toString();

    setState(() {
      _selectedFile = null;
      _selectedFileName = title?.isNotEmpty == true ? title : 'YouTube Video';
      _errorMessage = null;
    });

    await _runAnalyzeFlow(
      youtubeUrl: url,
      displayName: _selectedFileName ?? 'YouTube Video',
      resultFileName: _selectedFileName ?? 'YouTube Video',
      resultYoutubeUrl: url,
      resultThumbnailUrl: thumbnail,
      resultIsYoutubeSource: true,
    );
  }

  Future<void> _runAnalyzeFlow({
    PlatformFile? selected,
    String? youtubeUrl,
    required String displayName,
    String? resultFileName,
    String? resultFilePath,
    Uint8List? resultFileBytes,
    String? resultYoutubeUrl,
    String? resultThumbnailUrl,
    bool resultIsYoutubeSource = false,
  }) async {
    setState(() {
      _isProcessing = true;
      _selectedFileName = displayName;
      _processingThumbnailUrl = resultThumbnailUrl;
      _processingIsYoutubeSource = resultIsYoutubeSource;
      _errorMessage = null;
      _processingElapsedSeconds = 0;
      _processingStepIndex = 0;
    });

    _startProcessingTicker();

    try {
      final payload = await _analyzeWithFallback(selected: selected, youtubeUrl: youtubeUrl);
      final nextResult = DechordAnalyzeResult.fromJson(payload);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });
      _stopProcessingTicker();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DeChordResultPage(
            result: nextResult,
            fileName: resultFileName,
            filePath: resultFilePath,
            fileBytes: resultFileBytes,
            isYoutubeSource: resultIsYoutubeSource,
            youtubeUrl: resultYoutubeUrl,
            youtubeThumbnailUrl: resultThumbnailUrl,
          ),
        ),
      );

      if (mounted) {
        unawaited(_loadRecentAnalyses(silent: true));
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Request bị timeout. Kiểm tra backend rồi thử lại.';
        });
      }
      _stopProcessingTicker();
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      final fullMessage = '$message\nGợi ý: đảm bảo GuideTarBackend đang chạy ở cổng 8000.';
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = fullMessage;
        });
      }
      _stopProcessingTicker();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingThumbnailUrl = null;
          _processingIsYoutubeSource = false;
        });
      }
      if (_deferRecentLoadUntilAnalyzeDone) {
        _deferRecentLoadUntilAnalyzeDone = false;
        unawaited(_loadRecentAnalyses(silent: true));
      }
    }
  }

  void _startProcessingTicker() {
    _processingTicker?.cancel();
    _processingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isProcessing) return;

      _processingElapsedSeconds += 1;
      if (_processingElapsedSeconds % 4 == 0 && _processingStepIndex < _processingSteps.length - 1) {
        _processingStepIndex += 1;
      }

      if (_processingElapsedSeconds >= 300) {
        _isProcessing = false;
        _stopProcessingTicker();
        if (mounted) {
          setState(() {
            _errorMessage = 'Xử lý quá lâu (>300s). Vui lòng thử lại.';
          });
        }
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  void _stopProcessingTicker() {
    _processingTicker?.cancel();
    _processingTicker = null;
  }

  List<String> _candidateApiBaseUrls() {
    String normalize(String value) => value.endsWith('/') ? value.substring(0, value.length - 1) : value;

    final configured = _configuredBaseUrl.trim();
    if (configured.isNotEmpty) {
      return <String>[normalize(configured)];
    }

    final urls = <String>[];
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      urls.add('http://10.0.2.2:8000');
    }
    urls.add('http://localhost:8000');
    return urls.map(normalize).toSet().toList(growable: false);
  }

  Future<Map<String, dynamic>> _analyzeWithFallback({
    PlatformFile? selected,
    String? youtubeUrl,
  }) async {
    if (selected == null && (youtubeUrl == null || youtubeUrl.isEmpty)) {
      throw Exception('Thiếu dữ liệu phân tích. Hãy chọn file hoặc nhập link YouTube.');
    }

    Object? lastError;
    for (final baseUrl in _candidateApiBaseUrls()) {
      try {
        return await _sendAnalyzeRequest(baseUrl: baseUrl, selected: selected, youtubeUrl: youtubeUrl);
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ?? Exception('Không thể kết nối tới backend.');
  }

  Future<void> _loadRecentAnalyses({bool silent = false}) async {
    if (_isProcessing) {
      _deferRecentLoadUntilAnalyzeDone = true;
      return;
    }

    if (!silent) {
      setState(() {
        _isLoadingRecent = true;
        _recentError = null;
      });
    }

    try {
      final items = await BackendApi.getAnalyzeHistory();
      if (!mounted) return;
      setState(() {
        _recentAnalyses = items;
        _recentError = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _recentAnalyses = const [];
        _recentError = error.statusCode == 401
            ? 'Đăng nhập để xem lịch sử DeChord gần đây.'
            : error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recentAnalyses = const [];
        _recentError = 'Không tải được lịch sử gần đây.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecent = false;
        });
      }
    }
  }

  Future<void> _loadHistoryDetail(String analysisId) async {
    try {
      final payload = await BackendApi.getAnalyzeHistoryDetail(analysisId);
      final result = DechordAnalyzeResult.fromJson(payload);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DeChordResultPage(
            result: result,
            fileName: payload['source_name']?.toString(),
            filePath: null,
            fileBytes: null,
            isYoutubeSource: payload['source_type']?.toString() == 'youtube',
            youtubeUrl: payload['source_url']?.toString(),
            youtubeThumbnailUrl: null,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tải được kết quả: ${error.toString()}')),
      );
    }
  }

  String _formatRecentDate(dynamic value) {
    final parsed = DateTime.tryParse((value ?? '').toString());
    if (parsed == null) return '--/--';
    final local = parsed.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> _sendAnalyzeRequest({
    required String baseUrl,
    PlatformFile? selected,
    String? youtubeUrl,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/analyze'),
    );
    final accessToken = AuthSession.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    request.fields['include_logs'] = 'false';

    if (youtubeUrl != null && youtubeUrl.isNotEmpty) {
      request.fields['youtube_url'] = youtubeUrl;
    } else if (selected?.path != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          selected!.path!,
          filename: selected.name,
        ),
      );
    } else if (selected?.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          selected!.bytes!,
          filename: selected.name,
        ),
      );
    } else {
      throw Exception('Không có dữ liệu hợp lệ để gửi lên backend.');
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 300));
    final body = await streamedResponse.stream.bytesToString();

    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Backend không trả về object JSON hợp lệ.');
      }
      payload = decoded;
    } catch (error) {
      throw Exception('Backend trả về dữ liệu không hợp lệ: $error');
    }

    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      final backendError = payload['detail']?.toString() ?? 'Backend xử lý thất bại.';
      throw Exception(backendError);
    }

    return payload;
  }

  bool _looksLikeYoutubeUrl(String value) {
    final parsed = Uri.tryParse(value);
    if (parsed == null) return false;
    final host = parsed.host.toLowerCase();
    return host.contains('youtube.com') || host.contains('youtu.be');
  }

  Future<Map<String, dynamic>?> _fetchYoutubePreview(String url) async {
    try {
      final uri = Uri.https('www.youtube.com', '/oembed', {
        'url': url,
        'format': 'json',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final payload = jsonDecode(response.body);
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Phân Tích Hợp Âm AI',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.75,
                      height: 36 / 30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Biến bất kỳ bài hát nào thành sơ đồ hợp âm guitar trong giây lát.',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFADAAAA),
                      fontSize: 16,
                      height: 24 / 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _UploadCard(
                    selectedFileName: _selectedFileName,
                    onPickLocalSong: _pickLocalSong,
                    onAnalyze: _analyzeSelectedSong,
                  ),
                  const SizedBox(height: 16),
                  _LinkImportCard(
                    controller: _youtubeUrlController,
                    onAnalyze: _analyzeYoutubeUrl,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _InlineErrorCard(message: _errorMessage!),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bài hát đã xử lý gần đây',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 28 / 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: (_isLoadingRecent || _isProcessing) ? null : () => _loadRecentAnalyses(),
                        child: Text(
                          _isProcessing ? 'ĐANG XỬ LÝ' : 'LÀM MỚI',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFFF923E),
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingRecent)
                    const Center(child: CircularProgressIndicator())
                  else if (_recentError != null)
                    _InlineErrorCard(message: _recentError!)
                  else if (_recentAnalyses.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131313),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'Chưa có bài nào được xử lý gần đây.',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFADAAAA),
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    for (int i = 0; i < _recentAnalyses.length && i < 5; i++) ...[
                      GestureDetector(
                        onTap: () => _loadHistoryDetail(_recentAnalyses[i]['id']?.toString() ?? ''),
                        child: _RecentSongItem(
                          sourceType: (_recentAnalyses[i]['source_type'] ?? 'file').toString(),
                          title: (_recentAnalyses[i]['source_name'] ?? 'Bài hát không tên').toString(),
                          subtitle:
                              '${_formatRecentDate(_recentAnalyses[i]['created_at'])} • ${(_recentAnalyses[i]['chord_count'] ?? 0)} chords',
                        ),
                      ),
                      if (i < 4 && i < _recentAnalyses.length - 1) const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.verified,
                          title: 'Chính xác 99%',
                          description: 'Thuật toán AI tối ưu nhất hiện nay cho Guitar.',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.bolt,
                          title: 'Xử lý thần tốc',
                          description: 'Nhận kết quả chỉ trong vài giây.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  color: Color.fromRGBO(0, 0, 0, 0.45),
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 320,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF20201F),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.08)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 64,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: _SelectedFileCover(
                                      fileName: _selectedFileName,
                                      thumbnailUrl: _processingThumbnailUrl,
                                      isYoutubeSource: _processingIsYoutubeSource,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedFileName ?? 'Bài hát đã chọn',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 44,
                              width: 44,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.5,
                                valueColor: AlwaysStoppedAnimation(Color(0xFFFF923E)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _processingSteps[_processingStepIndex],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                color: const Color(0xFFDFDFDF),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_processingElapsedSeconds}s',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFF8A8A8A),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.selectedFileName,
    required this.onPickLocalSong,
    required this.onAnalyze,
  });

  final String? selectedFileName;
  final VoidCallback onPickLocalSong;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(32, 32, 31, 0.6),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 146, 62, 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.upload_file, color: Color(0xFFFF923E), size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            'Tải lên tệp MP3',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MVP hiện hỗ trợ định dạng MP3. Kích thước tối đa 20MB.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: const Color(0xFFADAAAA),
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 14),
          if (selectedFileName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF131313),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.06)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note_rounded, color: Color(0xFFFF923E), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedFileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (selectedFileName != null) const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onPickLocalSong,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        selectedFileName == null ? 'Duyệt Tệp Local' : 'Đổi file',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onAnalyze,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF923E), Color(0xFFF97F06)],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        'Phân tích ngay',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF4D2300),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkImportCard extends StatelessWidget {
  const _LinkImportCard({
    required this.controller,
    required this.onAnalyze,
  });

  final TextEditingController controller;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, color: Color(0xFFFF923E), size: 18),
              const SizedBox(width: 10),
              Text(
                'Nhập qua đường dẫn',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              style: GoogleFonts.manrope(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Dán link YouTube tại đây...',
                hintStyle: GoogleFonts.manrope(
                  color: const Color(0xFF767575),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAnalyze,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF923E), Color(0xFFF97F06)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Analyze Link YouTube',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF4D2300),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: 0.4,
            child: Row(
              children: [
                Image.asset('assets/images/dechord_youtube_icon.png', width: 20, height: 20),
                const SizedBox(width: 6),
                Text(
                  'YOUTUBE',
                  style: GoogleFonts.manrope(color: Colors.white, fontSize: 10, letterSpacing: 1),
                ),
                const SizedBox(width: 16),
                Image.asset('assets/images/dechord_spotify_icon.png', width: 20, height: 20),
                const SizedBox(width: 6),
                Text(
                  'SPOTIFY',
                  style: GoogleFonts.manrope(color: Colors.white, fontSize: 10, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 146, 62, 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 146, 62, 0.25)),
      ),
      child: Text(
        message,
        style: GoogleFonts.manrope(
          color: const Color(0xFFFFB885),
          fontSize: 13,
          height: 19 / 13,
        ),
      ),
    );
  }
}

class _SelectedFileCover extends StatelessWidget {
  const _SelectedFileCover({
    required this.fileName,
    required this.thumbnailUrl,
    required this.isYoutubeSource,
  });

  final String? fileName;
  final String? thumbnailUrl;
  final bool isYoutubeSource;

  @override
  Widget build(BuildContext context) {
    if (isYoutubeSource && thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildFallback(),
            ),
            Container(
              color: const Color.fromRGBO(0, 0, 0, 0.25),
            ),
            const Center(
              child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28),
            ),
          ],
        ),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    final safeName = (fileName ?? 'Audio').trim();
    final initials = safeName.isEmpty ? 'A' : safeName[0].toUpperCase();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A2A17), Color(0xFF9A4D14), Color(0xFFDB7C2D)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -10,
              top: -8,
              child: Text(
                initials,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color.fromRGBO(255, 255, 255, 0.18),
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSongItem extends StatelessWidget {
  const _RecentSongItem({
    required this.sourceType,
    required this.title,
    required this.subtitle,
  });

  final String sourceType;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isYoutube = sourceType.toLowerCase() == 'youtube';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 146, 62, 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isYoutube ? Icons.play_circle_fill_rounded : Icons.music_note_rounded,
              color: const Color(0xFFFF923E),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFADAAAA),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 146, 62, 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isYoutube ? 'YouTube' : 'Local',
              style: GoogleFonts.manrope(
                color: const Color(0xFFFF923E),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF923E), size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.manrope(
              color: const Color(0xFFADAAAA),
              fontSize: 12,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
