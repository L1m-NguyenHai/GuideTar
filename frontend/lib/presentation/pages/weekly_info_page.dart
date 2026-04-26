import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/backend_api.dart';

class WeeklyInfoPage extends StatefulWidget {
  const WeeklyInfoPage({super.key});

  @override
  State<WeeklyInfoPage> createState() => _WeeklyInfoPageState();
}

class _WeeklyInfoPageState extends State<WeeklyInfoPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _weekly;

  @override
  void initState() {
    super.initState();
    _loadWeekly();
  }

  Future<void> _loadWeekly() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await BackendApi.getWeeklyAnalytics();
      if (!mounted) {
        return;
      }
      setState(() {
        _weekly = data;
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

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) {
      return '${m}m';
    }
    return '${h}h ${m}m';
  }

  String _shortDate(String value) {
    if (value.length >= 10) {
      return value.substring(5);
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = ((_weekly?['total_minutes']) ?? 0) as int;
    final days = ((_weekly?['days']) ?? const []) as List;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0D),
        elevation: 0,
        title: Text(
          'Thông tin tài khoản',
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFE5E2E0),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFFFA366),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadWeekly,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF20201E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TUẦN NÀY',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFDEC1AF),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatMinutes(totalMinutes),
                          style: GoogleFonts.spaceGrotesk(
                            color: const Color(0xFFE5E2E0),
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (days.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20201E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final item in days)
                            Expanded(
                              child: _BarItem(
                                dateLabel: _shortDate(
                                  (item['date'] ?? '').toString(),
                                ),
                                minutes:
                                    ((item['practice_minutes']) ?? 0) as int,
                                maxMinutes: days
                                    .map(
                                      (e) =>
                                          ((e['practice_minutes']) ?? 0) as int,
                                    )
                                    .fold<int>(1, (a, b) => a > b ? a : b),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Chi tiết từng ngày',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFFE5E2E0),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final item in days) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A29),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              (item['date'] ?? '').toString(),
                              style: GoogleFonts.manrope(
                                color: const Color(0xFFE5E2E0),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            _formatMinutes(
                              ((item['practice_minutes']) ?? 0) as int,
                            ),
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFFF57C00),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.dateLabel,
    required this.minutes,
    required this.maxMinutes,
  });

  final String dateLabel;
  final int minutes;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final ratio = maxMinutes <= 0
        ? 0.0
        : (minutes / maxMinutes).clamp(0, 1).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: ratio == 0 ? 2 : (ratio * 120),
                decoration: BoxDecoration(
                  color: const Color(0xFFF57C00),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dateLabel,
            style: GoogleFonts.manrope(
              color: const Color(0xFFDEC1AF),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
