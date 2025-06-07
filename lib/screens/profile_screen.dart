import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../utils/user_prefs.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;

  File? _profileImage;
  String? _selectedAvatar;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Lista de avatares/emojis disponibles
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
    setState(() => _isLoading = true);
    try {
      _user = await UserPrefs.loadUser();
      if (_user != null) {
        _nameCtrl.text = _user!.name;
        _emailCtrl.text = _user!.email;
        _phoneCtrl.text = _user!.phone ?? '';
        _ageCtrl.text = _user!.age?.toString() ?? '';
        _heightCtrl.text = _user!.height?.toString() ?? '';
        _weightCtrl.text = _user!.weight?.toString() ?? '';

        // Cargar imagen/avatar
        final prefsData = await UserPrefs.getProfileImage();
        if (prefsData != null) {
          if (prefsData.startsWith('avatar:')) {
            _selectedAvatar = prefsData.replaceFirst('avatar:', '');
          } else {
            _profileImage = File(prefsData);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _selectedAvatar = null;
        });
        await UserPrefs.saveProfileImage(pickedFile.path);
      }
    } catch (e) {
      _showErrorSnackbar('Error al seleccionar imagen: $e');
    }
  }

  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            itemBuilder: (context, index) {
              final avatar = _avatars[index];
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    _selectedAvatar = avatar;
                    _profileImage = null;
                  });
                  await UserPrefs.saveProfileImage('avatar:$avatar');
                  // ignore: use_build_context_synchronously
                  if (mounted) Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedAvatar == avatar
                        // ignore: deprecated_member_use
                        ? AppColors.primary.withOpacity(0.2)
                        // ignore: deprecated_member_use
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: _selectedAvatar == avatar
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 24)),
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

  Future<void> _clearProfileImage() async {
    await UserPrefs.clearProfileImage();
    setState(() {
      _profileImage = null;
      _selectedAvatar = null;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = User(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _user!.password, // Mantener la contraseña existente
        phone: _phoneCtrl.text.trim().isNotEmpty
            ? _phoneCtrl.text.trim()
            : null,
        age: _ageCtrl.text.trim().isNotEmpty
            ? int.parse(_ageCtrl.text.trim())
            : null,
        height: _heightCtrl.text.trim().isNotEmpty
            ? double.parse(_heightCtrl.text.trim())
            : null,
        weight: _weightCtrl.text.trim().isNotEmpty
            ? double.parse(_weightCtrl.text.trim())
            : null,
      );

      await UserPrefs.saveUser(updatedUser);
      setState(() => _user = updatedUser);

      _showSuccessSnackbar('Perfil actualizado correctamente');
    } catch (e) {
      _showErrorSnackbar('Error al guardar: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
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
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: 'Cámara',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: 'Galería',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.emoji_emotions,
                    label: 'Avatar',
                    onTap: () {
                      Navigator.pop(context);
                      _showAvatarPicker();
                    },
                  ),
                  if (_profileImage != null || _selectedAvatar != null)
                    _buildImageOption(
                      icon: Icons.delete,
                      label: 'Eliminar',
                      onTap: () {
                        Navigator.pop(context);
                        _clearProfileImage();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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

  Widget _buildProfileAvatar() {
    if (_selectedAvatar != null) {
      return CircleAvatar(
        radius: 60,
        // ignore: deprecated_member_use
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(_selectedAvatar!, style: const TextStyle(fontSize: 60)),
      );
    } else if (_profileImage != null) {
      return CircleAvatar(
        radius: 60,
        // ignore: deprecated_member_use
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: FileImage(_profileImage!),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        // ignore: deprecated_member_use
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(Icons.person, size: 60, color: AppColors.primary),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  String? _validateNumber(
    String? value,
    String fieldName, {
    bool isDouble = false,
  }) {
    if (value == null || value.isEmpty) return null;

    final number = isDouble ? double.tryParse(value) : int.tryParse(value);
    if (number == null) return '$fieldName debe ser un número válido';
    if (number <= 0) return '$fieldName debe ser mayor que cero';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Foto de perfil
                Center(
                  child: GestureDetector(
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
                ),

                const SizedBox(height: 32),

                // Formulario
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'El nombre es requerido'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: InputDecoration(
                          labelText: 'Teléfono (opcional)',
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageCtrl,
                              decoration: InputDecoration(
                                labelText: 'Edad (opcional)',
                                prefixIcon: Icon(
                                  Icons.cake_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => _validateNumber(v, 'La edad'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _heightCtrl,
                              decoration: InputDecoration(
                                labelText: 'Altura (cm, opcional)',
                                prefixIcon: Icon(
                                  Icons.height,
                                  color: AppColors.primary,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => _validateNumber(
                                v,
                                'La altura',
                                isDouble: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _weightCtrl,
                        decoration: InputDecoration(
                          labelText: 'Peso (kg, opcional)',
                          prefixIcon: Icon(
                            Icons.monitor_weight_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            _validateNumber(v, 'El peso', isDouble: true),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Botón guardar
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // Botón cerrar sesión
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          await UserPrefs.clearUser();
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
