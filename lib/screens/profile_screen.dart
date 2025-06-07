import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../models/user.dart';
import '../utils/user_prefs.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;

  File? _profileImage;
  String? _selectedAvatar;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  static const List<String> _avatars = [
    '😊',
    '😎',
    '🤗',
    '😍',
    '🥳',
    '🤩',
    '😇',
    '🙂',
    '💪',
    '🏃‍♂️',
    '🏃‍♀️',
    '🚴‍♂️',
    '🚴‍♀️',
    '🏋️‍♂️',
    '🏋️‍♀️',
    '🤸‍♂️',
    '⚽',
    '🏀',
    '🎾',
    '🏐',
    '🏈',
    '⚾',
    '🥎',
    '🏓',
    '🔥',
    '⭐',
    '🌟',
    '💎',
    '🏆',
    '🥇',
    '🎯',
    '💯',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProfileData();
  }

  void _initializeControllers() {
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Primero tratamos de cargar del provider
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      _user = authProv.currentUser ?? await UserPrefs.loadUser();
      if (_user == null) return _redirectToLogin();

      _nameCtrl.text = _user!.name;
      _emailCtrl.text = _user!.email;
      _phoneCtrl.text = _user!.phone ?? '';
      _ageCtrl.text = _user!.age?.toString() ?? '';
      _heightCtrl.text = _user!.height?.toString() ?? '';
      _weightCtrl.text = _user!.weight?.toString() ?? '';

      final imgData = await UserPrefs.getProfileImage();
      if (imgData != null && imgData.isNotEmpty) {
        if (imgData.startsWith('avatar:')) {
          _selectedAvatar = imgData.substring(7);
        } else {
          _profileImage = File(imgData);
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _showErrorSnackbar('Error al cargar perfil');
      _redirectToLogin();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _redirectToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource src) async {
    final file = await _picker.pickImage(
      source: src,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (file != null) {
      await _updateProfileImage(File(file.path));
    }
  }

  Future<void> _updateProfileImage(File image) async {
    setState(() {
      _profileImage = image;
      _selectedAvatar = null;
    });
    await UserPrefs.saveProfileImage(image.path);
  }

  Future<void> _clearProfileImage() async {
    await UserPrefs.clearProfileImage();
    if (!mounted) return;
    setState(() {
      _profileImage = null;
      _selectedAvatar = null;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final updated = User(
        id: _user!.id,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _user!.password,
        phone: _phoneCtrl.text.trim().isNotEmpty
            ? _phoneCtrl.text.trim()
            : null,
        age: int.tryParse(_ageCtrl.text.trim()),
        height: double.tryParse(_heightCtrl.text.trim()),
        weight: double.tryParse(_weightCtrl.text.trim()),
        createdAt: _user!.createdAt,
        avatarUrl: _selectedAvatar,
      );

      await UserPrefs.saveUser(updated);
      // ignore: use_build_context_synchronously
      Provider.of<AuthProvider>(context, listen: false).setUser(updated);

      if (!mounted) return;
      setState(() => _user = updated);
      _showSuccessSnackbar('Perfil actualizado correctamente');
    } catch (e) {
      _showErrorSnackbar('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cerrar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // ignore: use_build_context_synchronously
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildProfileAvatar() {
    const radius = 60.0;
    // ignore: deprecated_member_use
    final bg = AppColors.primary.withOpacity(0.1);
    if (_selectedAvatar != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: Text(_selectedAvatar!, style: const TextStyle(fontSize: 60)),
      );
    }
    if (_profileImage != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        backgroundImage: FileImage(_profileImage!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Icon(Icons.person, size: 60, color: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Stack(
                    children: [
                      _buildProfileAvatar(),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  'Nombre completo',
                  _nameCtrl,
                  Icons.person_outline,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Email',
                  _emailCtrl,
                  Icons.email_outlined,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Teléfono (opc.)',
                  _phoneCtrl,
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Edad (opc.)',
                        _ageCtrl,
                        Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        validator: Validators.validateAge,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Altura (cm)',
                        _heightCtrl,
                        Icons.height,
                        keyboardType: TextInputType.number,
                        validator: Validators.validateHeight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Peso (kg)',
                  _weightCtrl,
                  Icons.monitor_weight_outlined,
                  keyboardType: TextInputType.number,
                  validator: Validators.validateWeight,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : _logout,
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar foto de perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerOption(
                  Icons.camera_alt,
                  'Cámara',
                  () => _pickImage(ImageSource.camera),
                ),
                _pickerOption(
                  Icons.photo_library,
                  'Galería',
                  () => _pickImage(ImageSource.gallery),
                ),
                _pickerOption(
                  Icons.emoji_emotions,
                  'Avatar',
                  _showAvatarPicker,
                ),
                if (_profileImage != null || _selectedAvatar != null)
                  _pickerOption(Icons.delete, 'Eliminar', _clearProfileImage),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Elige tu avatar',
          style: TextStyle(color: AppColors.primary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _avatars.length,
            itemBuilder: (c, i) {
              final av = _avatars[i];
              return GestureDetector(
                onTap: () async {
                  setState(() => _selectedAvatar = av);
                  await UserPrefs.saveProfileImage('avatar:$av');
                  if (mounted) Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedAvatar == av
                        // ignore: deprecated_member_use
                        ? AppColors.primary.withOpacity(0.2)
                        // ignore: deprecated_member_use
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: _selectedAvatar == av
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(av, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
