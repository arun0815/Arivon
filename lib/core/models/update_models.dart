import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // adjust path to match your project structure

// ─── API config ───────────────────────────────────────────────────────────────
// TODO: point this at your real backend endpoint.
const String updatesApiUrl = 'https://myarivon.in/api/updates';

// ─── Model ────────────────────────────────────────────────────────────────────
class UpdateItem {
  final String id;
  final String title;
  final String description;
  final String content;
  final String type;
  final String imageUrl;
  final String link;
  final bool isImportant;
  final DateTime createdAt;

  const UpdateItem({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.type,
    required this.imageUrl,
    required this.link,
    required this.isImportant,
    required this.createdAt,
  });

  factory UpdateItem.fromJson(Map<String, dynamic> json) {
    return UpdateItem(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      type: (json['type'] ?? 'general').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      link: (json['link'] ?? '').toString(),
      isImportant: json['isImportant'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  String get typeLabel =>
      type.isEmpty ? 'General' : '${type[0].toUpperCase()}${type.substring(1)}';
}

// ─── Type → style mapping ──────────────────────────────────────────────────────
class TypeStyle {
  final Color color;
  final Color lightBg;
  final Color? darkBg;
  final IconData icon;
  const TypeStyle(this.color, this.lightBg, this.darkBg, this.icon);
}

TypeStyle typeStyleFor(String type) {
  switch (type.toLowerCase()) {
    case 'marks':
      return TypeStyle(AppColors.amber, AppColors.amberSoft,
          AppColors.darkAmberSoft, Icons.star_outline_rounded);
    case 'notes':
      return TypeStyle(AppColors.primary, AppColors.primarySoft,
          AppColors.darkPrimarySoft, Icons.book_outlined);
    case 'results':
      return TypeStyle(AppColors.success, AppColors.successSoft,
          AppColors.darkSuccessSoft, Icons.emoji_events_outlined);
    case 'exams':
      return TypeStyle(AppColors.rose, AppColors.roseSoft,
          AppColors.darkRoseSoft, Icons.calendar_today_outlined);
    default:
      return TypeStyle(AppColors.violet, AppColors.violetSoft,
          AppColors.darkVioletSoft, Icons.campaign_outlined);
  }
}

// ─── Date helpers ─────────────────────────────────────────────────────────────
const months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String sectionLabel(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dt.year, dt.month, dt.day);
  final diff = today.difference(date).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return 'This Week';
  return '${months[dt.month - 1]} ${dt.year}';
}

String timeLabel(DateTime dt) {
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String fullDateLabel(DateTime dt) =>
    '${months[dt.month - 1]} ${dt.day}, ${dt.year} · ${timeLabel(dt)}';
