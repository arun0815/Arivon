import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../../core/models/update_models.dart'; // adjust path to match your project

// ─── Theme helpers ────────────────────────────────────────────────────────────
bool _isDark(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark;

Color _scaffold(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBg : AppColors.bg;

Color _header(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkSurface : AppColors.white;

Color _surface(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkCard : AppColors.white;

Color _border(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBorder : AppColors.border;

Color _text(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkText : AppColors.text;

Color _textSec(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkTextSec : AppColors.textSec;

Color _label(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkTextTert : AppColors.textTert;

Color _iconBg(BuildContext ctx, Color iconColor, Color lightBg, Color? darkBg) {
  if (!_isDark(ctx)) return lightBg;
  if (darkBg != null) return darkBg;
  return iconColor.withOpacity(0.15);
}

// ─── Updates Tab ──────────────────────────────────────────────────────────────
class UpdatesTab extends StatefulWidget {
  const UpdatesTab({super.key});

  @override
  State<UpdatesTab> createState() => _UpdatesTabState();
}

class _UpdatesTabState extends State<UpdatesTab> {
  String _activeFilter = 'All';
  late Future<List<UpdateItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchUpdates();
  }

  Future<List<UpdateItem>> _fetchUpdates() async {
    final res = await http
        .get(Uri.parse(updatesApiUrl))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Failed to load updates (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['data'] as List<dynamic>? ?? [])
        .map((e) => UpdateItem.fromJson(e as Map<String, dynamic>))
        .toList();

    // Newest first
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> _refresh() async {
    final next = _fetchUpdates();
    setState(() => _future = next);
    await next;
  }

  List<UpdateItem> _applyFilter(List<UpdateItem> items) {
    if (_activeFilter == 'All') return items;
    return items
        .where((i) => i.typeLabel.toLowerCase() == _activeFilter.toLowerCase())
        .toList();
  }

  Map<String, List<UpdateItem>> _grouped(List<UpdateItem> items) {
    final map = <String, List<UpdateItem>>{};
    for (final item in items) {
      final label = sectionLabel(item.createdAt);
      map.putIfAbsent(label, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffold(context),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<UpdateItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  _buildHeader(context, []),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                children: [
                  _buildHeader(context, []),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off_rounded,
                                size: 40, color: _textSec(context)),
                            const SizedBox(height: 12),
                            Text('Couldn\'t load updates',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _text(context))),
                            const SizedBox(height: 6),
                            Text('${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12, color: _textSec(context))),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refresh,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final all = snapshot.data ?? [];
            final filtered = _applyFilter(all);
            final grouped = _grouped(filtered);
            final sectionKeys = grouped.keys.toList();

            return Column(
              children: [
                _buildHeader(context, all),
                Expanded(
                  child: filtered.isEmpty
                      ? RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Text('📭',
                                          style: TextStyle(fontSize: 36)),
                                      const SizedBox(height: 12),
                                      Text('No $_activeFilter updates',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _textSec(context))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(18, 16, 18, 24),
                            itemCount: sectionKeys.length,
                            itemBuilder: (_, i) {
                              final key = sectionKeys[i];
                              return _SectionWidget(
                                title: key,
                                items: grouped[key]!,
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<UpdateItem> all) {
    final types = <String>{};
    for (final item in all) {
      types.add(item.typeLabel);
    }
    final filters = ['All', ...types.toList()..sort()];
    if (!filters.contains(_activeFilter)) _activeFilter = 'All';

    return Container(
      color: _header(context),
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Updates',
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: _text(context),
                        letterSpacing: -0.5)),
                const SizedBox(height: 3),
                Text('Stay in the loop',
                    style: TextStyle(fontSize: 13, color: _textSec(context))),
                const SizedBox(height: 14),
              ],
            ),
          ),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = filters[i];
                final active = _activeFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : _scaffold(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? Colors.white : _textSec(context),
                        )),
                  ),
                );
              },
            ),
          ),
          Container(height: 1, color: _border(context)),
        ],
      ),
    );
  }
}

// ─── Section ──────────────────────────────────────────────────────────────────
class _SectionWidget extends StatelessWidget {
  final String title;
  final List<UpdateItem> items;
  const _SectionWidget({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(title.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _label(context),
                      letterSpacing: 1.1)),
              const SizedBox(width: 10),
              Expanded(child: Divider(color: _border(context), height: 1)),
            ],
          ),
        ),
        ...items.map((item) => _UpdateCard(update: item)),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ─── Update Card ──────────────────────────────────────────────────────────────
class _UpdateCard extends StatelessWidget {
  final UpdateItem update;
  const _UpdateCard({required this.update});

  @override
  Widget build(BuildContext context) {
    final style = typeStyleFor(update.type);
    final tagBg = _iconBg(context, style.color, style.lightBg, style.darkBg);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UpdateDetailPage(update: update)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border(context)),
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: style.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (update.isImportant)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(Icons.priority_high_rounded,
                                        size: 14, color: AppColors.rose),
                                  ),
                                Expanded(
                                  child: Text(update.title,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _text(context),
                                          height: 1.3)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(update.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _textSec(context),
                                    height: 1.5)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: tagBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(update.typeLabel,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: style.color)),
                                ),
                                const Spacer(),
                                Icon(Icons.access_time_outlined,
                                    size: 11, color: _label(context)),
                                const SizedBox(width: 3),
                                Text(timeLabel(update.createdAt),
                                    style: TextStyle(
                                        fontSize: 10, color: _label(context))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(style.icon, color: style.color, size: 17),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Full Update Detail Page ───────────────────────────────────────────────────
class UpdateDetailPage extends StatelessWidget {
  final UpdateItem update;
  const UpdateDetailPage({super.key, required this.update});

  @override
  Widget build(BuildContext context) {
    final style = typeStyleFor(update.type);
    final tagBg = _iconBg(context, style.color, style.lightBg, style.darkBg);
    final body = update.content.trim().isNotEmpty
        ? update.content.trim()
        : update.description;

    return Scaffold(
      backgroundColor: _scaffold(context),
      appBar: AppBar(
        title: Text('Update',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _text(context))),
        backgroundColor: _header(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _text(context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border(context)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(style.icon, size: 14, color: style.color),
                      const SizedBox(width: 6),
                      Text(update.typeLabel,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: style.color)),
                    ],
                  ),
                ),
                if (update.isImportant) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _iconBg(context, AppColors.rose,
                          AppColors.roseSoft, AppColors.darkRoseSoft),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.priority_high_rounded,
                            size: 14, color: AppColors.rose),
                        const SizedBox(width: 4),
                        Text('Important',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.rose)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Text(update.title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _text(context),
                    letterSpacing: -0.4,
                    height: 1.3)),
            const SizedBox(height: 6),
            Text(fullDateLabel(update.createdAt),
                style: TextStyle(fontSize: 12, color: _label(context))),
            if (update.imageUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  update.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Container(height: 1, color: _border(context)),
            const SizedBox(height: 18),
            Text(body,
                style: TextStyle(
                    fontSize: 14,
                    color: _text(context),
                    height: 1.7)),
            if (update.link.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border(context)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link_rounded, size: 16, color: _textSec(context)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(update.link,
                          style: TextStyle(
                              fontSize: 12, color: _textSec(context)),
                          overflow: TextOverflow.ellipsis),
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
