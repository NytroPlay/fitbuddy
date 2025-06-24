// lib/screens/profile_screen.dart

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

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
    '💙',
    '💪',
    '🏃‍♂️',
    '🏃‍♀️',
    '🚴‍♂️',
    '🚴‍♀️',
    '🏋️‍♂️',
    '🏋️‍♀️',
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
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _weightCtrl = TextEditingController();

    // Cargar datos al arrancar
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfileData());
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      // 1) cargar usuario
      final saved = await UserPrefs.loadCurrentUser();
      if (saved == null) return _redirectToLogin();
      // sincronizar provider
      // ignore: use_build_context_synchronously
      Provider.of<AuthProvider>(context, listen: false).setUser(saved);
      _user = saved;

      // 2) rellenar campos
      _nameCtrl.text = _user!.name;
      _emailCtrl.text = _user!.email;
      _phoneCtrl.text = _user!.phone ?? '';
      _ageCtrl.text = _user!.age?.toString() ?? '';
      _heightCtrl.text = _user!.height?.toString() ?? '';
      _weightCtrl.text = _user!.weight?.toString() ?? '';

      // 3) cargar avatarImage / emoji
      // primero intento de SharedPrefs profile_image
      final imgData = await UserPrefs.getProfileImage();
      if (imgData != null && imgData.isNotEmpty) {
        if (imgData.startsWith('avatar:')) {
          _selectedAvatar = imgData.substring(7);
          _profileImage = null;
        } else if (File(imgData).existsSync()) {
          _profileImage = File(imgData);
          _selectedAvatar = null;
        }
      } else {
        // si no hay en profile_image, usar avatar del usuario
        final av = _user!.avatar ?? '';
        if (av.startsWith('avatar:')) {
          _selectedAvatar = av.substring(7);
          _profileImage = null;
        } else if (av.isNotEmpty && File(av).existsSync()) {
          _profileImage = File(av);
          _selectedAvatar = null;
        }
      }
    } catch (e) {
      _showErrorSnackbar('Error al cargar perfil');
      _redirectToLogin();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _redirectToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
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
      await _updateAvatar(File(file.path), isEmoji: false);
    }
  }

  Future<void> _updateAvatar(Object data, {required bool isEmoji}) async {
    if (_user == null) return;
    setState(() => _isLoading = true);

    String newAvatar;
    if (isEmoji) {
      _selectedAvatar = data as String;
      _profileImage = null;
      newAvatar = 'avatar:$_selectedAvatar';
    } else {
      _profileImage = data as File;
      _selectedAvatar = null;
      newAvatar = _profileImage!.path;
    }

    // 1) actualizar en UserPrefs.users_list
    final updated = _user!.copyWith(avatar: newAvatar);
    await UserPrefs.saveUser(updated);
    // ignore: use_build_context_synchronously
    Provider.of<AuthProvider>(context, listen: false).setUser(updated);

    // 2) también guardo en la clave profile_image
    await UserPrefs.saveProfileImage(newAvatar);

    setState(() {
      _user = updated;
      _isLoading = false;
    });
  }

  Future<void> _clearAvatar() async {
    if (_user == null) return;
    setState(() => _isLoading = true);

    final updated = _user!.copyWith(avatar: '');
    await UserPrefs.saveUser(updated);
    // ignore: use_build_context_synchronously
    Provider.of<AuthProvider>(context, listen: false).setUser(updated);

    // limpio clave profile_image también
    await UserPrefs.clearProfileImage();

    setState(() {
      _user = updated;
      _profileImage = null;
      _selectedAvatar = null;
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _user == null) return;
    setState(() => _isLoading = true);

    try {
      final currentAv = _user!.avatar ?? '';
      final updated = _user!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isNotEmpty
            ? _phoneCtrl.text.trim()
            : null,
        age: int.tryParse(_ageCtrl.text.trim()),
        height: double.tryParse(_heightCtrl.text.trim()),
        weight: double.tryParse(_weightCtrl.text.trim()),
        avatar: currentAv,
      );

      // actualizar lista de usuarios
      await UserPrefs.saveUser(updated);
      // ignore: use_build_context_synchronously
      Provider.of<AuthProvider>(context, listen: false).setUser(updated);

      // la imagen/emoji ya está en profile_image de antes,
      // así que no hace falta volver a guardarla aquí.

      setState(() => _user = updated);
      _showSuccessSnackbar('Perfil actualizado');
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
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
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

  Widget _buildAvatarCircle() {
    super.build(context); // para AutomaticKeepAliveClientMixin
    const radius = 60.0;
    // ignore: deprecated_member_use
    final bg = AppColors.primary.withOpacity(0.1);

    if (_selectedAvatar != null && _selectedAvatar!.isNotEmpty) {
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
      child: Icon(Icons.person, color: AppColors.primary, size: 60),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                      _buildAvatarCircle(),
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
                            color: Colors.white,
                            size: 20,
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
                  onPressed: _saveProfile,
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
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _logout,
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
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
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
            _pickerOption(Icons.emoji_emotions, 'Avatar', _showAvatarPicker),
            if (_profileImage != null || _selectedAvatar != null)
              _pickerOption(Icons.delete, 'Eliminar', _clearAvatar),
          ],
        ),
      ),
    );
  }

  Widget _pickerOption(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
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
            itemBuilder: (_, i) {
              final av = _avatars[i];
              final isSel = _selectedAvatar == av;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _updateAvatar(av, isEmoji: true);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSel
                        // ignore: deprecated_member_use
                        ? AppColors.primary.withOpacity(0.2)
                        // ignore: deprecated_member_use
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: isSel
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
