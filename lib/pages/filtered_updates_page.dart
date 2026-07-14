import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../core/models/update_model.dart'; // adjust path to match your project

class FilteredUpdatesPage extends StatefulWidget {
  final String type;       // e.g. 'attendance', 'internal', 'timetable'
  final String title;      // e.g. 'Attendance'

  const FilteredUpdatesPage({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<FilteredUpdatesPage> createState() => _FilteredUpdatesPageState();
}

class _FilteredUpdatesPageState extends State<FilteredUpdatesPage> {
  bool _loading = true;
  String? _error;
  List<UpdateItem> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await http
          .get(Uri.parse(updatesApiUrl))
          .timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) {
        throw Exception('Server returned ${res.statusCode}');
      }

      final decoded = jsonDecode(res.body);
      // Adjust this line if your API wraps the list, e.g. decoded['data']
      final List rawList = decoded is List ? decoded : (decoded['data'] ?? []);

      final all = rawList
          .map((e) => UpdateItem.fromJson(e as Map<String, dynamic>))
          .toList();

      final filtered = all
          .where((u) => u.type.toLowerCase() == widget.type.toLowerCase())
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() { _items = filtered; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load updates. Please try again.'; _loading = false; });
    }
  }

  bool _isDark(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final style = typeStyleFor(widget.type);
    final isDark = _isDark(context);
    final scaffoldBg = isDark ? AppColors.darkBg : AppColors.bg;
    final headerBg = isDark ? AppColors.darkSurface : AppColors.white;
    final textColor = isDark ? AppColors.darkText : AppColors.text;
    final textSec = isDark ? AppColors.darkTextSec : AppColors.textSec;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(widget.title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: headerBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _fetch, textColor: textSec)
                : _items.isEmpty
                    ? _EmptyState(title: widget.title, icon: style.icon, textColor: textSec)
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _UpdateCard(item: _items[i], style: style),
                      ),
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final UpdateItem item;
  final TypeStyle style;
  const _UpdateCard({required this.item, required this.style});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkCard : AppColors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final text = isDark ? AppColors.darkText : AppColors.text;
    final textSec = isDark ? AppColors.darkTextSec : AppColors.textSec;
    final iconBg = isDark && style.darkBg != null ? style.darkBg! : style.lightBg;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(style.icon, color: style.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.title,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: text),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    if (item.isImportant)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.rose.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Important',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.rose)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.description,
                    style: TextStyle(fontSize: 12, color: textSec, height: 1.4),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(fullDateLabel(item.createdAt),
                    style: TextStyle(fontSize: 11, color: textSec)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color textColor;
  const _EmptyState({required this.title, required this.icon, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: textColor.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('No $title updates yet', style: TextStyle(fontSize: 14, color: textColor)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color textColor;
  const _ErrorState({required this.message, required this.onRetry, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 40, color: textColor),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(fontSize: 13, color: textColor)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
