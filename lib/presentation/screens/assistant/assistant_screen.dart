import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashly/core/api/api_client.dart';
import 'package:cashly/core/constants/api_constants.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/utils/format.dart';
import 'package:cashly/data/models/models.dart';

class _ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String text;
  final DateTime ts;

  _ChatMessage(
      {required this.id,
      required this.role,
      required this.text,
      required this.ts});
}

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _loading = false;
  String? _sessionId;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      id: '0',
      role: 'assistant',
      text:
          'Oi! Sou o assistente da Cashly 💜 Como posso te ajudar com suas finanças?',
      ts: DateTime.now(),
    ),
  ];

  static const _suggestions = [
    'Como estão meus gastos esse mês?',
    'Posso gastar R\$ 500 hoje?',
    'Onde posso economizar?',
    'Quanto preciso guardar pra viagem?',
  ];

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.length < 3 || _loading) return;

    final userMsg = _ChatMessage(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      text: trimmed,
      ts: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _loading = true;
    });
    _textCtrl.clear();
    _scrollToBottom();

    try {
      final res = await ApiClient.instance.post(
        ApiConstants.aiQuery,
        data: {
          'message': trimmed,
          if (_sessionId != null) 'session_id': _sessionId,
        },
      );
      final reply = AiReply.fromJson(res.data['data'] as Map<String, dynamic>);
      _sessionId = reply.sessionId;

      setState(() {
        _messages.add(_ChatMessage(
          id: reply.interactionId,
          role: 'assistant',
          text: reply.message,
          ts: DateTime.now(),
        ));
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          id: 'err_${DateTime.now().millisecondsSinceEpoch}',
          role: 'assistant',
          text: 'Não foi possível consultar o assistente. Tente novamente.',
          ts: DateTime.now(),
        ));
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: _messages.length + (_loading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) return _buildTypingIndicator();
                  return _buildMessage(_messages[i]);
                },
              ),
            ),
            if (_messages.length <= 1) _buildSuggestions(),
            _buildInput(bottomInset),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: CashlyColors.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assistente IA',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: CashlyColors.foreground)),
              Text('Insights sobre seu dinheiro',
                  style: TextStyle(
                      fontSize: 11, color: CashlyColors.mutedForeground)),
            ],
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: CashlyColors.success,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage msg) {
    final isUser = msg.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: CashlyColors.gradientPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isUser ? CashlyColors.gradientPrimary : null,
                color: isUser ? null : CashlyColors.surfaceElevated,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: CashlyColors.primary.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : CashlyColors.foreground,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CashlyFormat.time(msg.ts),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withOpacity(0.6)
                          : CashlyColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: CashlyColors.gradientPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CashlyColors.surfaceElevated,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _BouncingDot(delay: i * 120)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(color: CashlyColors.border, width: 0.5)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: _suggestions
            .map(
              (s) => GestureDetector(
                onTap: () => _send(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: CashlyColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CashlyColors.border),
                  ),
                  child: Text(s,
                      style: const TextStyle(
                          fontSize: 12,
                          color: CashlyColors.mutedForeground)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInput(double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(color: CashlyColors.border, width: 0.5)),
        color: CashlyColors.background,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              style:
                  const TextStyle(color: CashlyColors.foreground, fontSize: 14),
              maxLines: 4,
              minLines: 1,
              maxLength: 2000,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Pergunte sobre suas finanças...',
                hintStyle:
                    const TextStyle(color: CashlyColors.mutedForeground),
                filled: true,
                fillColor: CashlyColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:
                      const BorderSide(color: CashlyColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:
                      const BorderSide(color: CashlyColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: CashlyColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
              onSubmitted: _send,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _send(_textCtrl.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: CashlyColors.gradientPrimary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: CashlyColors.primary.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _loading
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: CashlyColors.mutedForeground,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
