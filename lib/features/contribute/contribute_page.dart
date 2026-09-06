import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ─── Constants ──────────────────────────────────────────────────────────────
const int _kMaxFileBytes = 10 * 1024 * 1024; // 10 MB
const String _kContributeEmail = 'support@myarivon.in';
const String _kBaseUrl = 'https://myarivon.in/api/contribute';

const List<String> kDepartments = [
  'CSE', 'IT', 'ECE', 'EEE', 'MECH', 'CIVIL', 'AI & DS', 'AI & ML', 'EIE', 'CSBS', 'Other',
];

const List<String> kDocumentTypes = [
  'Lecture Notes', 'Question Paper', 'Study Notes', 'Lab Manual', 'Syllabus', 'Other',
];

// ─── Service ────────────────────────────────────────────────────────────────
class ContributionService {
  static Future<bool> submitCredits({
    required String subjectName,
    required String subjectCode,
    required String department,
    required int credits,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_kBaseUrl/credits'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subjectName': subjectName,
          'subjectCode': subjectCode,
          'department': department,
          'credits': credits,
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) return false;
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> submitDocument({
    required String subjectName,
    required String subjectCode,
    required String department,
    required String docType,
    required File file,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_kBaseUrl/notes'));
      request.fields['subjectName'] = subjectName;
      request.fields['subjectCode'] = subjectCode;
      request.fields['department']  = department;
      request.fields['docType']     = docType;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send();
      final response  = await http.Response.fromStream(streamed);
      if (response.statusCode != 200 && response.statusCode != 201) return false;
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}

// ─── Main Page ────────────────────────────────────────────────────────────────
class ContributePage extends StatefulWidget {
  const ContributePage({super.key});

  @override
  State<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const Color _accent = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor     = isDark ? const Color(0xFF0B1220) : const Color(0xFFF1F5F9);
    final cardColor   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white            : const Color(0xFF0F172A);
    final textSec     = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 15, color: textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contribute',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          )),
                      Text('Help fellow students — add credits or share notes',
                          style: TextStyle(fontSize: 12, color: textSec)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Tab bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: textSec,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  splashBorderRadius: BorderRadius.circular(10),
                  tabs: const [
                    Tab(text: 'Credits'),
                    Tab(text: 'Notes & QP'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Tab views ───────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _CreditsTab(),
                  _NotesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared field wrapper ───────────────────────────────────────────────────
Widget _fieldLabel(BuildContext context, String label) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF8A8FA8),
        )),
  );
}

InputDecoration _fieldDecoration(BuildContext context, {IconData? icon, String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFA0A6B8)),
    prefixIcon: icon != null
        ? Icon(icon, color: const Color(0xFF6C63FF), size: 20)
        : null,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  );
}

BoxDecoration _fieldBox(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F6FA),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      width: 1.5,
    ),
  );
}

// ─── Credits Tab ────────────────────────────────────────────────────────────
class _CreditsTab extends StatefulWidget {
  const _CreditsTab();

  @override
  State<_CreditsTab> createState() => _CreditsTabState();
}

class _CreditsTabState extends State<_CreditsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  String? _department;
  int? _credits;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_department == null || _credits == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select department and credits')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await ContributionService.submitCredits(
      subjectName: _nameController.text.trim(),
      subjectCode: _codeController.text.trim(),
      department:  _department!,
      credits:     _credits!,
    );
    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks! Submitted for review.'),
          backgroundColor: Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _formKey.currentState!.reset();
      _nameController.clear();
      _codeController.clear();
      setState(() { _department = null; _credits = null; });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit. Try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel(context, 'SUBJECT NAME'),
            Container(
              decoration: _fieldBox(context),
              child: TextFormField(
                controller: _nameController,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                decoration: _fieldDecoration(context,
                    icon: Icons.menu_book_rounded, hint: 'e.g. Data Structures'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel(context, 'SUBJECT CODE'),
            Container(
              decoration: _fieldBox(context),
              child: TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                decoration: _fieldDecoration(context,
                    icon: Icons.tag_rounded, hint: 'e.g. CS3301'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel(context, 'DEPARTMENT'),
            Container(
              decoration: _fieldBox(context),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  initialValue: _department,
                  decoration: _fieldDecoration(context, icon: Icons.account_balance_outlined),
                  hint: const Text('Select department',
                      style: TextStyle(fontSize: 14, color: Color(0xFFA0A6B8))),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                  items: kDepartments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() => _department = v),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel(context, 'CREDITS'),
            Container(
              decoration: _fieldBox(context),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<int>(
                  initialValue: _credits,
                  decoration: _fieldDecoration(context, icon: Icons.star_border_rounded),
                  hint: const Text('Select credits',
                      style: TextStyle(fontSize: 14, color: Color(0xFFA0A6B8))),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                  items: [0, 1, 2, 3, 4, 5]
                      .map((c) => DropdownMenuItem(value: c, child: Text('$c Credit${c == 1 ? '' : 's'}')))
                      .toList(),
                  onChanged: (v) => setState(() => _credits = v),
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Submit',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: 0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notes / QP Tab ─────────────────────────────────────────────────────────
class _NotesTab extends StatefulWidget {
  const _NotesTab();

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  String? _department;
  String? _docType;
  bool _isSubmitting = false;

  PlatformFile? _pickedFile;
  bool _fileTooLarge = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    setState(() {
      _pickedFile   = file;
      _fileTooLarge = file.size > _kMaxFileBytes;
    });
  }

  Future<void> _emailInstead() async {
    final subject = Uri.encodeComponent(
        'File contribution: ${_nameController.text.trim().isEmpty ? "Subject" : _nameController.text.trim()}');
    final body = Uri.encodeComponent(
        'Subject Name: ${_nameController.text.trim()}\n'
        'Subject Code: ${_codeController.text.trim()}\n'
        'Department: ${_department ?? ""}\n'
        'Document Type: ${_docType ?? ""}\n\n'
        '(Please attach your file to this email)');
    final uri = Uri.parse('mailto:$_kContributeEmail?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please email your file to $_kContributeEmail')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_department == null || _docType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select department and document type')),
      );
      return;
    }
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach a file')),
      );
      return;
    }
    if (_fileTooLarge) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File exceeds 10MB — please email it instead')),
      );
      return;
    }
    if (_pickedFile!.path == null) return;

    setState(() => _isSubmitting = true);
    final success = await ContributionService.submitDocument(
      subjectName: _nameController.text.trim(),
      subjectCode: _codeController.text.trim(),
      department:  _department!,
      docType:     _docType!,
      file:        File(_pickedFile!.path!),
    );
    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks! Uploaded for review.'),
          backgroundColor: Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _formKey.currentState!.reset();
      _nameController.clear();
      _codeController.clear();
      setState(() { _department = null; _docType = null; _pickedFile = null; _fileTooLarge = false; });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed. Try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec     = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel(context, 'SUBJECT NAME'),
            Container(
              decoration: _fieldBox(context),
              child: TextFormField(
                controller: _nameController,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                decoration: _fieldDecoration(context,
                    icon: Icons.menu_book_rounded, hint: 'e.g. Data Structures'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel(context, 'SUBJECT CODE'),
            Container(
              decoration: _fieldBox(context),
              child: TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                decoration: _fieldDecoration(context,
                    icon: Icons.tag_rounded, hint: 'e.g. CS3301'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel(context, 'DEPARTMENT'),
            Container(
              decoration: _fieldBox(context),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  initialValue: _department,
                  decoration: _fieldDecoration(context, icon: Icons.account_balance_outlined),
                  hint: const Text('Select department',
                      style: TextStyle(fontSize: 14, color: Color(0xFFA0A6B8))),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                  items: kDepartments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() => _department = v),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel(context, 'DOCUMENT TYPE'),
            Container(
              decoration: _fieldBox(context),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  initialValue: _docType,
                  decoration: _fieldDecoration(context, icon: Icons.description_outlined),
                  hint: const Text('Select type',
                      style: TextStyle(fontSize: 14, color: Color(0xFFA0A6B8))),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                  items: kDocumentTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _docType = v),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel(context, 'FILE (MAX 10MB)'),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _fileTooLarge
                        ? Colors.redAccent
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: 1.5,
                  ),
                ),
                child: _pickedFile == null
                    ? Row(
                        children: [
                          const Icon(Icons.upload_file_rounded,
                              color: Color(0xFF6C63FF), size: 22),
                          const SizedBox(width: 12),
                          Text('Tap to attach a file',
                              style: TextStyle(fontSize: 14, color: textSec)),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(Icons.insert_drive_file_rounded,
                              color: _fileTooLarge ? Colors.redAccent : const Color(0xFF6C63FF),
                              size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_pickedFile!.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
                                const SizedBox(height: 2),
                                Text(_formatSize(_pickedFile!.size),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: _fileTooLarge ? Colors.redAccent : textSec)),
                              ],
                            ),
                          ),
                          Icon(Icons.close_rounded, size: 18, color: textSec)
                              .let((icon) => GestureDetector(
                                    onTap: () => setState(() {
                                      _pickedFile   = null;
                                      _fileTooLarge = false;
                                    }),
                                    child: icon,
                                  )),
                        ],
                      ),
              ),
            ),

            if (_fileTooLarge) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'File is larger than 10MB. Please email it to us instead.',
                            style: TextStyle(fontSize: 12, color: textSec, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _emailInstead,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.mail_outline_rounded, size: 14, color: Color(0xFF6C63FF)),
                                SizedBox(width: 5),
                                Text('Email instead',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF6C63FF))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: (_isSubmitting || _fileTooLarge) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  disabledBackgroundColor: const Color(0xFF6C63FF).withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Submit',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: 0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tiny extension used for the inline close-icon tap target above ─────────
extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
