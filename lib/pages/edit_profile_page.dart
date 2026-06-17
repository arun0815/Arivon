import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/profile_provider.dart';
import '../widgets/avatar_picker_sheet.dart';

class ProfileModel {
  String name;
  String email;
  String institute;
  String department;
  String semester;
  String? selectedAvatar;
  String? profileImg;
  

  ProfileModel({
    required this.name,
    required this.email,
    required this.institute,
    required this.department,
    required this.semester,
    this.selectedAvatar,
    this.profileImg,
  });
}

class EditProfilePage extends StatefulWidget {
  final ProfileModel profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _instituteController;
  late TextEditingController _departmentController;
  late TextEditingController _semesterController;

  String? _selectedAvatar; // asset path — locally stored
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController       = TextEditingController(text: widget.profile.name);
    _instituteController  = TextEditingController(text: widget.profile.institute);
    _departmentController = TextEditingController(text: widget.profile.department);
    _semesterController   = TextEditingController(text: widget.profile.semester);
    _selectedAvatar       = widget.profile.selectedAvatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instituteController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void _openAvatarPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerSheet(currentAvatar: _selectedAvatar),
    );
    // result == null means "Default" selected (clear avatar)
    // result == '' means cancelled (Navigator.pop with no value)
    if (result != null) {
      setState(() => _selectedAvatar = result.isEmpty ? null : result);
      if (mounted) {
        await context.read<ProfileProvider>().updateAvatar(
            _selectedAvatar);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }
    setState(() => _isSaving = true);

    final success = await context.read<ProfileProvider>().updateProfile(
      name:       _nameController.text.trim(),
      institute:  _instituteController.text.trim(),
      department: _departmentController.text.trim(),
      semester:   _semesterController.text.trim(),
    );

    setState(() => _isSaving = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update. Try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Avatar preview widget ─────────────────────────────────────────────────
  Widget _buildAvatar() {
    final profile = context.read<ProfileProvider>().profile;

    // Priority: locally selected asset > network profileImg > initial letter
    Widget avatarChild;
    if (_selectedAvatar != null && _selectedAvatar!.isNotEmpty) {
      // Local asset avatar selected
      avatarChild = Image.asset(
        _selectedAvatar!,
        width: 104, height: 104,
        fit: BoxFit.cover,
      );
    } else if (profile?.profileImg != null &&
        profile!.profileImg!.isNotEmpty) {
      // Google profile image
      avatarChild = Image.network(
        profile.profileImg!,
        width: 104, height: 104,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialAvatar(),
      );
    } else {
      avatarChild = _initialAvatar();
    }

    return GestureDetector(
      onTap: _openAvatarPicker,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Main avatar circle
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(_selectedAvatar),
              width: 104, height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 16, offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(child: avatarChild),
            ),
          ),
          // Camera icon badge
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            padding: const EdgeInsets.all(7),
            child: const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _initialAvatar() {
    final name = _nameController.text;
    return Container(
      color: const Color(0xFF6C63FF),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: const TextStyle(
            fontSize: 38, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.4,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF8A8FA8),
          )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon,
                color: const Color(0xFF6C63FF), size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18, fontWeight: FontWeight.w700,
          )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Avatar preview
            Center(child: _buildAvatar()),
            const SizedBox(height: 8),
            Text(
              'Tap to change photo',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF8A8FA8),
              ),
            ),
            const SizedBox(height: 32),

            _buildTextField(
              label: 'FULL NAME',
              controller: _nameController,
              icon: Icons.person_outline_rounded,
            ),
            _buildTextField(
              label: 'INSTITUTE',
              controller: _instituteController,
              icon: Icons.account_balance_outlined,
            ),
            _buildTextField(
              label: 'DEPARTMENT',
              controller: _departmentController,
              icon: Icons.bookmark_border_rounded,
            ),
            _buildTextField(
              label: 'SEMESTER',
              controller: _semesterController,
              icon: Icons.school_outlined,
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                    : const Text('Save Changes',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: 0.3)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
