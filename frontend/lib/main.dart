import 'package:flutter/material.dart';
import 'package:guidetar/config/theme.dart';
import 'package:guidetar/presentation/pages/app_root_page.dart';

void main() {
  runApp(const MyApp());
}

class _AnalyzeSessionNotifier extends ChangeNotifier {
  bool _isProcessing = false;
  bool _isDone = false;
  String? _errorMessage;
  String? _fileName;
  String? _thumbnailUrl;
  bool _isYoutubeSource = false;
  String _processingStep = 'Đang chuẩn bị dữ liệu âm thanh...';
  int _elapsedSeconds = 0;

  bool get isProcessing => _isProcessing;
  bool get isDone => _isDone;
  String? get errorMessage => _errorMessage;
  String? get fileName => _fileName;
  String? get thumbnailUrl => _thumbnailUrl;
  bool get isYoutubeSource => _isYoutubeSource;
  String get processingStep => _processingStep;
  int get elapsedSeconds => _elapsedSeconds;

  void startAnalyze(
    String fileName,
    String? thumbnailUrl,
    bool isYoutube,
  ) {
    _isProcessing = true;
    _isDone = false;
    _errorMessage = null;
    _fileName = fileName;
    _thumbnailUrl = thumbnailUrl;
    _isYoutubeSource = isYoutube;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  void updateProgress(String step, int elapsed) {
    _processingStep = step;
    _elapsedSeconds = elapsed;
    notifyListeners();
  }

  void finishAnalyzeSuccess() {
    _isProcessing = false;
    _isDone = true;
    _errorMessage = null;
    notifyListeners();
  }

  void finishAnalyzeError(String message) {
    _isProcessing = false;
    _errorMessage = message;
    notifyListeners();
  }

  void dismissPopup() {
    _isDone = false;
    _isProcessing = false;
    _errorMessage = null;
    notifyListeners();
  }

  void resetAll() {
    _isProcessing = false;
    _isDone = false;
    _errorMessage = null;
    _fileName = null;
    _thumbnailUrl = null;
    _isYoutubeSource = false;
    _elapsedSeconds = 0;
    notifyListeners();
  }
}

final _analyzeSessionNotifier = _AnalyzeSessionNotifier();

_AnalyzeSessionNotifier getAnalyzeSessionNotifier() => _analyzeSessionNotifier;

// ignore: library_private_types_in_public_api
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuideTar',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Stack(
        children: [
          child!,
          Positioned(
            right: 16,
            bottom: 92,
            child: AnimatedBuilder(
              animation: _analyzeSessionNotifier,
              builder: (context, _) {
                if (!_analyzeSessionNotifier.isProcessing &&
                    !_analyzeSessionNotifier.isDone &&
                    _analyzeSessionNotifier.errorMessage == null) {
                  return const SizedBox.shrink();
                }
                return _GlobalAnalyzePopup(notifier: _analyzeSessionNotifier);
              },
            ),
          ),
        ],
      ),
      home: const AppRootPage(),
    );
  }
}

class _GlobalAnalyzePopup extends StatelessWidget {
  const _GlobalAnalyzePopup({required this.notifier});

  final _AnalyzeSessionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final statusText = notifier.isProcessing
        ? 'Đang xử lý'
        : notifier.errorMessage != null
            ? 'Xử lý thất bại'
            : notifier.isDone
                ? 'Đã xử lý xong'
                : 'AI DeChord';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF20201F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.16)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.35),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notifier.fileName ?? 'Chưa chọn',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFADAAAA),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => notifier.dismissPopup(),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
            if (notifier.isProcessing) ...[
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notifier.processingStep,
                    style: const TextStyle(
                      color: Color(0xFFDFDFDF),
                      fontSize: 11,
                      height: 16 / 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      backgroundColor: const Color(0xFF2D2D2D),
                      valueColor: AlwaysStoppedAnimation(
                        notifier.elapsedSeconds > 120 ? Colors.red : const Color(0xFFFF923E),
                      ),
                      value: (notifier.elapsedSeconds.toDouble() / 300).clamp(0, 1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${notifier.elapsedSeconds}s',
                    style: const TextStyle(
                      color: Color(0xFF8A8A8A),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ] else if (notifier.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                notifier.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFFFB885),
                  fontSize: 11,
                  height: 15 / 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
