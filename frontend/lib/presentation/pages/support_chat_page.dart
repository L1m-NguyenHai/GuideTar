import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/backend_api.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _introController;
  late final AnimationController _typingDotsController;

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      id: 'seed-incoming',
      text:
          'Chào bạn! Tôi là Lyra từ bộ phận Hỗ trợ của Guidetar. Tôi thấy bạn đang gặp chút sự cố với việc gia hạn gói Premium. Hôm nay tôi có thể giúp gì để trải nghiệm âm nhạc của bạn không bị gián đoạn?',
      time: '09:41 SA',
      fromAgent: true,
    ),
    const _ChatMessage(
      id: 'seed-outgoing',
      text:
          'Đúng vậy, giao dịch thanh toán của tôi đã thành công nhưng ứng dụng vẫn báo là tôi đang ở gói Miễn phí.',
      time: '09:42 SA',
      fromAgent: false,
    ),
  ];

  bool _isAgentTyping = true;
  bool _isBackendMode = false;
  String? _chatError;
  int _idSeed = 0;
  Timer? _replyTimer;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
    _typingDotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();

    _isBackendMode = BackendApi.supportConversationId.isNotEmpty;
    if (_isBackendMode) {
      _loadBackendMessages();
    } else {
      _isAgentTyping = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _introController.dispose();
    _typingDotsController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  String _formatTime(DateTime now) {
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final suffix = now.hour >= 12 ? 'CH' : 'SA';
    return '$hour:$minute $suffix';
  }

  String _buildAutoReply(String userText) {
    final normalized = userText.toLowerCase();
    if (normalized.contains('thanh toán') ||
        normalized.contains('premium') ||
        normalized.contains('miễn phí') ||
        normalized.contains('mien phi')) {
      return 'Cảm ơn bạn đã cung cấp thông tin. Mình đã gửi yêu cầu đồng bộ lại quyền lợi Premium, thường sẽ cập nhật trong 1-3 phút. Bạn giúp mình thử thoát ứng dụng và vào lại sau khoảng 1 phút nhé.';
    }
    if (normalized.contains('otp') || normalized.contains('mã')) {
      return 'Mình đã ghi nhận vấn đề OTP. Bạn vui lòng kiểm tra thư rác và đảm bảo số điện thoại đang hoạt động. Nếu vẫn chưa nhận được, mình có thể gửi lại mã thủ công cho bạn ngay.';
    }
    return 'Mình đã nhận được tin nhắn của bạn. Bạn mô tả thêm giúp mình thời điểm xảy ra lỗi và ảnh chụp màn hình, mình sẽ hỗ trợ ngay để bạn tiếp tục học không bị gián đoạn.';
  }

  Future<void> _loadBackendMessages() async {
    setState(() {
      _isAgentTyping = true;
      _chatError = null;
    });
    try {
      final rows = await BackendApi.getSupportMessages(
        BackendApi.supportConversationId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _messages
          ..clear()
          ..addAll(
            rows.map(
              (row) => _ChatMessage(
                id: (row['id'] ?? '').toString(),
                text: (row['message_text'] ?? '').toString(),
                time: _formatBackendTime((row['created_at'] ?? '').toString()),
                fromAgent: (row['sender_type'] ?? '').toString() != 'user',
              ),
            ),
          );
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _chatError = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAgentTyping = false;
        });
      }
    }
  }

  String _formatBackendTime(String value) {
    if (value.isEmpty) {
      return _formatTime(DateTime.now());
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return _formatTime(DateTime.now());
    }
    return _formatTime(parsed.toLocal());
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final now = DateTime.now();
    setState(() {
      _messages.add(
        _ChatMessage(
          id: 'user-${_idSeed++}',
          text: text,
          time: _formatTime(now),
          fromAgent: false,
        ),
      );
      _messageController.clear();
      _isAgentTyping = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    if (_isBackendMode) {
      try {
        await BackendApi.sendSupportMessage(
          conversationId: BackendApi.supportConversationId,
          messageText: text,
        );
        await _loadBackendMessages();
      } on ApiException catch (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isAgentTyping = false;
          _chatError = error.message;
        });
      }
      return;
    }

    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) {
        return;
      }
      final reply = _buildAutoReply(text);
      setState(() {
        _messages.add(
          _ChatMessage(
            id: 'agent-${_idSeed++}',
            text: reply,
            time: _formatTime(DateTime.now()),
            fromAgent: true,
          ),
        );
        _isAgentTyping = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  @override
  Widget build(BuildContext context) {
    final introOpacity = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF101010), Color(0xFF090909)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 64),
              child: FadeTransition(
                opacity: introOpacity,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 142),
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131313),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'HÔM NAY',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFADAAAA),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    for (final message in _messages) ...[
                      _AnimatedMessageBubble(message: message),
                      const SizedBox(height: 14),
                    ],
                    if (_chatError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _chatError!,
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFFFA366),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_isAgentTyping) ...[
                      _TypingBubble(controller: _typingDotsController),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SafeArea(bottom: false, child: _ChatTopBar()),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(14, 14, 14, 0.05),
                      Color.fromRGBO(14, 14, 14, 0.92),
                    ],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(32, 32, 31, 0.8),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color.fromRGBO(72, 72, 71, 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: Color(0xFFADAAAA),
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          onSubmitted: (_) {
                            _sendMessage();
                          },
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type a message...',
                            hintStyle: GoogleFonts.manrope(
                              color: const Color.fromRGBO(173, 170, 170, 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          _sendMessage();
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFD8B00),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Color(0xFF3C2000),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
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

class _ChatTopBar extends StatelessWidget {
  const _ChatTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.72)),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFDF7100),
              size: 17,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDF7100), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/guitar_toolkit_user_profile.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFF2B2B2A),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFFDF7100),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'BP_CSKH',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 26 * 0.7,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.45,
              ),
            ),
          ),
          const Icon(
            Icons.music_note_rounded,
            color: Color(0xFFDF7100),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            'GuideTar',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFF4F4F5),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.9,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF20201F),
            borderRadius: BorderRadius.circular(999),
          ),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final value = controller.value;
              return Row(
                children: [
                  _dot((value + 0.0) % 1),
                  const SizedBox(width: 4),
                  _dot((value + 0.2) % 1),
                  const SizedBox(width: 4),
                  _dot((value + 0.4) % 1),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dot(double t) {
    final opacity = t < 0.5 ? (0.35 + t) : (1.35 - t);
    return Opacity(
      opacity: opacity.clamp(0.35, 1),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFFF9F4A),
          shape: BoxShape.circle,
        ),
        child: SizedBox(width: 6, height: 6),
      ),
    );
  }
}

class _AnimatedMessageBubble extends StatefulWidget {
  const _AnimatedMessageBubble({required this.message});

  final _ChatMessage message;

  @override
  State<_AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<_AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(widget.message.fromAgent ? -0.06 : 0.06, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAgent = widget.message.fromAgent;
    final bubbleColor = isAgent
        ? const Color(0xFF20201F)
        : const Color(0xFFDF7100);
    final textColor = isAgent ? Colors.white : const Color(0xFF442100);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Align(
          alignment: isAgent ? Alignment.centerLeft : Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 331.5),
            child: Column(
              crossAxisAlignment: isAgent
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isAgent ? 0 : 16),
                      bottomRight: Radius.circular(isAgent ? 16 : 0),
                    ),
                  ),
                  child: Text(
                    widget.message.text,
                    style: GoogleFonts.plusJakartaSans(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.62,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(
                    left: isAgent ? 4 : 0,
                    right: isAgent ? 0 : 4,
                  ),
                  child: Text(
                    widget.message.time,
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFADAAAA),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.fromAgent,
  });

  final String id;
  final String text;
  final String time;
  final bool fromAgent;
}
