import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/services/app_preferences.dart';
import '../../data/services/auth_service.dart';

/// Profile Screen
/// Display and edit user profile information
class ProfileScreen extends StatefulWidget {
  final Future<String?> Function()? imagePickerAction;

  const ProfileScreen({super.key, this.imagePickerAction});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedGender;
  String? _photoPath;
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _genders = ['Laki-laki', 'Perempuan', 'Lainnya'];

  ImageProvider<Object>? _buildPhotoProvider(String? photoUrl) {
    final normalized = photoUrl?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(normalized);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(normalized);
    }

    final file = File(normalized);
    if (!file.existsSync()) {
      return null;
    }

    return FileImage(file);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Load from preferences or auth service
    _nameController.text =
        AppPreferences.userDisplayName ?? AuthService.displayName ?? '';
    _emailController.text = AppPreferences.userEmail ?? AuthService.email ?? '';
    _whatsappController.text = AppPreferences.userWhatsapp ?? '';

    final age = AppPreferences.userAge;
    _ageController.text = age != null ? age.toString() : '';

    _selectedGender = AppPreferences.userGender;
    _photoPath = AppPreferences.userPhotoUrl ?? AuthService.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<String?> _pickProfileImage() async {
    final picker = widget.imagePickerAction ?? _defaultImagePicker;
    return picker();
  }

  Future<String?> _defaultImagePicker() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    return file?.path;
  }

  Future<void> _selectPhoto() async {
    if (!_isEditing || _isLoading) return;

    try {
      final path = await _pickProfileImage();
      if (!mounted || path == null || path.trim().isEmpty) return;

      setState(() {
        _photoPath = path;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Save to preferences
        await AppPreferences.setUserDisplayName(_nameController.text.trim());
        if (!AuthService.isLoggedIn) {
          await AppPreferences.setUserEmail(_emailController.text.trim());
        }
        await AppPreferences.setUserWhatsapp(_whatsappController.text.trim());
        await AppPreferences.setUserPhotoUrl(_photoPath);

        final age = int.tryParse(_ageController.text.trim());
        await AppPreferences.setUserAge(age);

        await AppPreferences.setUserGender(_selectedGender);

        if (!mounted) return;

        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan!'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.isLoggedIn;
    final photoProvider = _buildPhotoProvider(_photoPath);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit_outlined),
            )
          else
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? _selectPhoto : null,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            foregroundImage: photoProvider,
                            onForegroundImageError: photoProvider == null
                                ? null
                                : (_, __) {},
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _selectPhoto,
                                customBorder: const CircleBorder(),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing24),

                  // Login status badge
                  if (isLoggedIn)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing12,
                        vertical: AppSizes.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSizes.spacing8),
                          Text(
                            'Login dengan Google',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing12,
                        vertical: AppSizes.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSizes.spacing8),
                          Text(
                            'Mode Tamu',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSizes.spacing24),

                  // Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nama',
                    hint: 'Masukkan nama Anda',
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Masukkan email Anda',
                    enabled: _isEditing && !isLoggedIn,
                    keyboardType: TextInputType.emailAddress,
                    helperText: isLoggedIn ? 'Email dari akun Google' : null,
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // WhatsApp Field
                  _buildTextField(
                    controller: _whatsappController,
                    label: 'Nomor WhatsApp',
                    hint: 'Contoh: 08123456789',
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Age Field
                  _buildTextField(
                    controller: _ageController,
                    label: 'Usia',
                    hint: 'Contoh: 25',
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Gender Dropdown
                  _buildDropdownField(
                    label: 'Jenis Kelamin',
                    value: _selectedGender,
                    items: _genders,
                    enabled: _isEditing,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSizes.spacing32),

                  // Cancel button when editing
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _loadUserData(); // Reset changes
                          });
                        },
                        child: const Text('Batal'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool enabled = true,
    TextInputType? keyboardType,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            filled: !enabled,
            fillColor: enabled ? null : Theme.of(context).colorScheme.surface,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required bool enabled,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSizes.spacing8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: !enabled,
            fillColor: enabled ? null : Theme.of(context).colorScheme.surface,
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
