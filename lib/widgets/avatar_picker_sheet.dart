import 'package:flutter/material.dart';

const List<_AvatarOption> _avatarOptions = [
  _AvatarOption(label: 'Avatar 1', assetPath: 'assets/avatars/img1.webp'),
  _AvatarOption(label: 'Avatar 2', assetPath: 'assets/avatars/img2.webp'),
  _AvatarOption(label: 'Avatar 3', assetPath: 'assets/avatars/img3.webp'),
  _AvatarOption(label: 'Avatar 4', assetPath: 'assets/avatars/img4.webp'),
];

class _AvatarOption {
  final String label;
  final String assetPath;
  const _AvatarOption({required this.label, required this.assetPath});
}

class AvatarPickerSheet extends StatefulWidget {
  final String? currentAvatar;
  const AvatarPickerSheet({super.key, this.currentAvatar});

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentAvatar;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textSec= isDark ? const Color(0xFF94A3B8) : const Color(0xFF8A8FA8);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // ── Large preview of selected avatar ──────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _selected != null
                ? Container(
                    key: ValueKey(_selected),
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6C63FF), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                          blurRadius: 16, spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        _selected!,
                        width: 100, height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    key: const ValueKey('default'),
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6C63FF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                          blurRadius: 16, spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('A',
                        style: TextStyle(fontSize: 38,
                          color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            _selected != null
                ? _avatarOptions
                    .firstWhere((o) => o.assetPath == _selected,
                        orElse: () => const _AvatarOption(
                            label: 'Avatar', assetPath: ''))
                    .label
                : 'Default',
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: textSec),
          ),
          const SizedBox(height: 20),

          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose Avatar',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Avatar grid ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Default option
              _buildTile(
                key: 'default',
                isDark: isDark,
                child: Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6C63FF),
                  ),
                  child: const Center(
                    child: Text('A',
                      style: TextStyle(fontSize: 24,
                        color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                label: 'Default',
                isSelected: _selected == null,
                onTap: () => setState(() => _selected = null),
              ),
              // Asset avatars
              ..._avatarOptions.map((option) => _buildTile(
                key: option.assetPath,
                isDark: isDark,
                child: ClipOval(
                  child: Image.asset(
                    option.assetPath,
                    width: 64, height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                label: option.label,
                isSelected: _selected == option.assetPath,
                onTap: () => setState(() => _selected = option.assetPath),
              )),
            ],
          ),

          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Apply',
                style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
              style: TextStyle(color: textSec,
                fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required String key,
    required bool isDark,
    required Widget child,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 68, height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.35),
                      blurRadius: 10, spreadRadius: 2)]
                  : [],
            ),
            child: ClipOval(child: child),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? const Color(0xFF6C63FF)
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF8A8FA8)),
            ),
          ),
        ],
      ),
    );
  }
}
