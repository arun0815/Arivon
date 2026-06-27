import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';

// ─── API Config ───────────────────────────────────────────────────────────────
// Pass these via --dart-define at build time — never hardcode secrets
const _kApiUrl    = String.fromEnvironment('CONTACT_API_URL');
const _kApiSecret = String.fromEnvironment('CONTACT_API_SECRET');

// ─── Theme helpers ────────────────────────────────────────────────────────────
bool _isDark(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark;

Color _scaffold(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBg : AppColors.bg;

Color _surface(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkCard : AppColors.white;

Color _header(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkSurface : AppColors.white;

Color _border(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBorder : AppColors.border;

Color _text(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkText : AppColors.text;

Color _textSec(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkTextSec : AppColors.textSec;

Color _textTert(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkTextTert : AppColors.textTert;

Color _inputFill(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBg : const Color(0xFFF8FAFC);

Color _inputBorder(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBorderLight : AppColors.border;

// ─── Page ─────────────────────────────────────────────────────────────────────
class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();

  String _position = 'Student';
  bool _sending    = false;
  bool _sent       = false;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _messageError;

  final _positions = ['Student', 'Faculty', 'Developer', 'Other'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError    = _nameCtrl.text.trim().isEmpty ? 'Name is required' : null;
      _emailError   = !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                          .hasMatch(_emailCtrl.text.trim())
                      ? 'Enter a valid email' : null;
      _phoneError   = _phoneCtrl.text.trim().length < 10
                      ? 'Enter a valid phone number' : null;
      _messageError = _messageCtrl.text.trim().length < 10
                      ? 'Message too short (min 10 chars)' : null;
    });
    return [_nameError, _emailError, _phoneError, _messageError]
        .every((e) => e == null);
  }

  Future<void> _send() async {
    if (!_validate()) return;
    setState(() => _sending = true);

    try {
      final response = await http
          .post(
            Uri.parse(_kApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent':   'ArivonApp/1.0',  // must match backend check
              'x-api-secret': _kApiSecret,       // secret header
            },
            body: jsonEncode({
              'name':      _nameCtrl.text.trim(),
              'email':     _emailCtrl.text.trim(),
              'phone':     _phoneCtrl.text.trim(),
              'position':  _position,
              'message':   _messageCtrl.text.trim(),
              'honeypot':  '',  // always empty — bots fill this
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        setState(() { _sending = false; _sent = true; });
      } else if (response.statusCode == 429) {
        setState(() => _sending = false);
        _showError('Too many requests. Please try again after 1 hour.');
      } else if (response.statusCode == 504) {
        setState(() => _sending = false);
        _showError('Server took too long. Please try again.');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() => _sending = false);
        _showError('Request blocked. Please update the app.');
      } else {
        setState(() => _sending = false);
        _showError(body['message'] as String? ?? 'Failed to send. Please try again.');
      }
    } on TimeoutException {
      setState(() => _sending = false);
      _showError('Connection timed out. Please try again.');
    } on Exception {
      setState(() => _sending = false);
      _showError('No internet connection. Please try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffold(context),
      body: SafeArea(
        child: _sent
            ? _SuccessView(onBack: () => Navigator.pop(context))
            : Column(
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Container(
                    color: _header(context),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: _scaffold(context),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: _border(context)),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 15, color: _text(context)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact Us',
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: _text(context))),
                            Text('We usually reply within 24 hours',
                                style: TextStyle(
                                    fontSize: 11, color: _textSec(context))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Info banner ──────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'This form is for reporting app bugs or business inquiries. '
                                    'For academic queries, contact your college directly.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _isDark(context)
                                          ? AppColors.primaryMid
                                          : AppColors.primaryDark,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Form card ────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _surface(context),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _border(context)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel(label: 'Full Name'),
                                _InputField(
                                  controller: _nameCtrl,
                                  hint: 'e.g. Arun Kumar',
                                  error: _nameError,
                                  prefix: Icons.person_outline_rounded,
                                  onChanged: (_) =>
                                      setState(() => _nameError = null),
                                ),

                                const SizedBox(height: 16),

                                const _FieldLabel(label: 'Email Address'),
                                _InputField(
                                  controller: _emailCtrl,
                                  hint: 'e.g. arun@gmail.com',
                                  error: _emailError,
                                  prefix: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) =>
                                      setState(() => _emailError = null),
                                ),

                                const SizedBox(height: 16),

                                const _FieldLabel(label: 'Phone Number'),
                                _InputField(
                                  controller: _phoneCtrl,
                                  hint: 'e.g. 9876543210',
                                  error: _phoneError,
                                  prefix: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  onChanged: (_) =>
                                      setState(() => _phoneError = null),
                                ),

                                const SizedBox(height: 16),

                                const _FieldLabel(label: 'Your Role'),
                                _DropdownField(
                                  value: _position,
                                  items: _positions,
                                  onChanged: (v) =>
                                      setState(() => _position = v!),
                                ),

                                const SizedBox(height: 16),

                                const _FieldLabel(label: 'Your Message'),
                                _InputField(
                                  controller: _messageCtrl,
                                  hint: 'Describe your issue or query in detail...',
                                  error: _messageError,
                                  prefix: Icons.chat_bubble_outline_rounded,
                                  maxLines: 5,
                                  onChanged: (_) =>
                                      setState(() => _messageError = null),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Send button ──────────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _sending ? null : _send,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor:
                                    AppColors.primary.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: _sending
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5))
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded,
                                            color: Colors.white, size: 18),
                                        SizedBox(width: 10),
                                        Text('Send Message',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Center(
                            child: Text(
                              'Your info is only used to respond to your message.',
                              style: TextStyle(
                                  fontSize: 11, color: _textSec(context)),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Success Screen ───────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final VoidCallback onBack;
  const _SuccessView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 40, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            Text('Message Sent!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _text(context))),
            const SizedBox(height: 10),
            Text(
              "Thanks for reaching out. We'll get back\nto you within 24 hours.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: _textSec(context), height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Go Back',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isDark(context)
                  ? AppColors.darkText
                  : const Color(0xFF334155))),
    );
  }
}

// ─── Input Field ──────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? error;
  final IconData prefix;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.error,
    required this.prefix,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError     = error != null;
    final fillColor    = _inputFill(context);
    final normalBorder = _inputBorder(context);
    final errorColor   = AppColors.rose;

    final borderColor = hasError ? errorColor : normalBorder;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
          color: hasError ? errorColor : AppColors.primary, width: 1.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: _text(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: _textTert(context)),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(prefix,
                  size: 18,
                  color: hasError ? errorColor : _textTert(context)),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 14 : 0,
            ),
            border:             inputBorder,
            enabledBorder:      inputBorder,
            focusedBorder:      focusedBorder,
            errorBorder:        inputBorder,
            focusedErrorBorder: focusedBorder,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.error_outline_rounded, size: 13, color: errorColor),
              const SizedBox(width: 4),
              Text(error!,
                  style: TextStyle(fontSize: 12, color: errorColor)),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Dropdown Field ───────────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _inputFill(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _inputBorder(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: _surface(context),
          style: TextStyle(fontSize: 14, color: _text(context)),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: _textTert(context)),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
