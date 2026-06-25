import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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

// ─── Model ────────────────────────────────────────────────────────────────────
class FeedbackEntry {
  final String name;
  final String department;
  final double rating; // 0 - 5
  final String content;
  final String imageUrl;

  const FeedbackEntry({
    required this.name,
    required this.department,
    required this.rating,
    required this.content,
    required this.imageUrl,
  });
}

// ─── Sample data (replace with API data later) ────────────────────────────────
const _feedbacks = [
  FeedbackEntry(
    name: 'Priya Dharshini',
    department: 'CSE · III Year',
    rating: 5,
    content:
        'Arivon made checking my internal marks and attendance so much easier. The GPA calculator saved me a lot of time before exams.',
    imageUrl: 'https://images.pexels.com/photos/35401526/pexels-photo-35401526.jpeg',
  ),
  FeedbackEntry(
    name: 'Karthik Raja',
    department: 'ECE · IV Year',
    rating: 4.5,
    content:
        'Really clean app. The result page redesign looks great and loads faster than the official portal during result day rush.',
    imageUrl: 'https://images.unsplash.com/photo-1620510625142-b45cbb784397?q=80&w=386&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ),
  FeedbackEntry(
    name: 'Divya Sree',
    department: 'IT · II Year',
    rating: 5,
    content:
        'Love the daily quote feature, it keeps me motivated. Also the cut-off calculator helped me a lot during admissions season.',
    imageUrl: 'https://plus.unsplash.com/premium_photo-1664121799890-b5605834b72a?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ),
  FeedbackEntry(
    name: 'Mohammed Aslam',
    department: 'Mechanical · III Year',
    rating: 4,
    content:
        'Notes section has everything I need before exams. Would be great to get notifications when new notes are uploaded.',
    imageUrl: 'https://images.unsplash.com/photo-1553658024-39485fea1f16?q=80&w=464&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ),
  FeedbackEntry(
    name: 'Sandhiya M',
    department: 'EEE · I Year',
    rating: 4.5,
    content:
        'As a first year student, the onboarding and dark mode are great touches. The app feels very polished for a student project.',
    imageUrl: 'https://plus.unsplash.com/premium_vector-1711987375329-6babe1ec0351?q=80&w=580&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ),
  FeedbackEntry(
    name: 'Arun Prasath',
    department: 'CSE · IV Year',
    rating: 5,
    content:
        'The percentage and credit calculators are spot on with Anna University regulations. Saved me from manual calculation mistakes.',
    imageUrl: 'https://images.unsplash.com/photo-1618641986557-1ecd230959aa?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ),
  FeedbackEntry(
    name: 'Lakshmi Narayanan',
    department: 'Civil · II Year',
    rating: 4,
    content:
        'Good app overall. Sometimes the result page takes a while to load during high traffic but it always works eventually.',
    imageUrl: 'https://images.unsplash.com/photo-1593085512500-5d55148d6f0d?q=80&w=580&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ),
  FeedbackEntry(
    name: 'Nivetha R',
    department: 'IT · III Year',
    rating: 5,
    content:
        'The notice board keeps me updated on exam schedules and circulars without having to check multiple WhatsApp groups.',
    imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ),
  FeedbackEntry(
    name: 'Gokul Krishna',
    department: 'ECE · I Year',
    rating: 4.5,
    content:
        'Super helpful for a junior like me. The timetable and attendance calculator are things I use almost every day.',
    imageUrl: 'https://static.wikitide.net/deathbattlewiki/1/10/Portrait.satorugojo.png',
  ),
  FeedbackEntry(
    name: 'Swetha Balaji',
    department: 'CSE · II Year',
    rating: 5,
    content:
        'Easily the best student app for Anna University students. Clean UI, fast, and exactly the tools we actually need.',
    imageUrl: 'https://i.pinimg.com/736x/36/90/3a/36903a763c4e9deaa8083dc7048a1454.jpg',
  ),
];

// ─── Feedback Page ──────────────────────────────────────────────────────────────
class FeedbackTab extends StatelessWidget {
  const FeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    final avgRating = _feedbacks.fold<double>(0, (sum, f) => sum + f.rating) /
        _feedbacks.length;

    return Scaffold(
      backgroundColor: _scaffold(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, avgRating),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                itemCount: _feedbacks.length,
                itemBuilder: (_, i) => _FeedbackCard(entry: _feedbacks[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double avgRating) {
    return Container(
      color: _header(context),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _border(context), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Feedback',
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: _text(context),
                  letterSpacing: -0.5)),
          const SizedBox(height: 3),
          Row(
            children: [
              Text('What students are saying',
                  style: TextStyle(fontSize: 13, color: _textSec(context))),
              const SizedBox(width: 8),
              _StarRating(rating: avgRating, size: 13),
              const SizedBox(width: 4),
              Text(avgRating.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _text(context))),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Feedback Card ────────────────────────────────────────────────────────────
class _FeedbackCard extends StatelessWidget {
  final FeedbackEntry entry;
  const _FeedbackCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primarySoft,
                backgroundImage: NetworkImage(entry.imageUrl),
                onBackgroundImageError: (_, __) {},
                child: entry.imageUrl.isEmpty
                    ? Text(
                        entry.name.isNotEmpty ? entry.name[0] : '?',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _text(context))),
                    const SizedBox(height: 2),
                    Text(entry.department,
                        style:
                            TextStyle(fontSize: 11.5, color: _textSec(context))),
                  ],
                ),
              ),
              _StarRating(rating: entry.rating, size: 14),
            ],
          ),
          const SizedBox(height: 10),
          Text(entry.content,
              style: TextStyle(
                  fontSize: 12.5, color: _text(context), height: 1.55)),
        ],
      ),
    );
  }
}

// ─── Star Rating ──────────────────────────────────────────────────────────────
class _StarRating extends StatelessWidget {
  final double rating; // 0 - 5
  final double size;
  const _StarRating({required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final diff = rating - i;
        IconData icon;
        if (diff >= 1) {
          icon = Icons.star_rounded;
        } else if (diff >= 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        return Icon(icon, size: size, color: AppColors.amber);
      }),
    );
  }
}
