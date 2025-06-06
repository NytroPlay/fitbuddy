import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa shared_preferences
import '../models/user.dart';
import '../utils/user_prefs.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl,
      emailCtrl,
      phoneCtrl,
      ageCtrl,
      heightCtrl,
      weightCtrl;
  File? _profileImage;
  String? _selectedAvatar;
  final ImagePicker _picker = ImagePicker();

  // Claves para guardar en shared_preferences
  static const String _prefKeyImage = 'profile_image';
  static const String _prefKeyAvatar = 'selected_avatar';

  // Lista de avatares/emojis disponibles
  final List<String> _avatars = [
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
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await _loadUserData();
    await _loadImageFromPrefs(); // Cargar imagen/avatar de shared_preferences
  }

  Future<void> _loadUserData() async {
    user = await UserPrefs.loadUser();
    nameCtrl = TextEditingController(text: user?.name ?? '');
    emailCtrl = TextEditingController(text: user?.email ?? '');
    phoneCtrl = TextEditingController(text: user?.phone ?? '');
    ageCtrl = TextEditingController(text: user?.age?.toString() ?? '');
    heightCtrl = TextEditingController(text: user?.height?.toString() ?? '');
    weightCtrl = TextEditingController(text: user?.weight?.toString() ?? '');
    setState(() {});
  }

  Future<void> _loadImageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_prefKeyImage);
    final avatar = prefs.getString(_prefKeyAvatar);

    setState(() {
      if (imagePath != null) {
        _profileImage = File(imagePath);
        _selectedAvatar = null;
      } else if (avatar != null) {
        _selectedAvatar = avatar;
        _profileImage = null;
      }
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    ageCtrl.dispose();
    heightCtrl.dispose();
    weightCtrl.dispose();
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
          _selectedAvatar = null; // Limpiar avatar si se selecciona imagen
        });
        await _saveImageToPrefs(
          pickedFile.path,
        ); // Guardar ruta en shared_preferences
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _saveImageToPrefs(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyImage, imagePath);
    await prefs.remove(_prefKeyAvatar); // Limpiar avatar si se guarda imagen
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
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
            SizedBox(height: 20),
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
            SizedBox(height: 20),
          ],
        ),
      ),
    );
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
          height: 300,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _avatars.length,
            itemBuilder: (context, index) {
              final avatar = _avatars[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatar = avatar;
                    _profileImage =
                        null; // Limpiar imagen si se selecciona avatar
                  });
                  _saveAvatarToPrefs(
                    avatar,
                  ); // Guardar avatar en shared_preferences
                  Navigator.pop(context);
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
                    child: Text(avatar, style: TextStyle(fontSize: 24)),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAvatarToPrefs(String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyAvatar, avatar);
    await prefs.remove(_prefKeyImage); // Limpiar imagen si se guarda avatar
  }

  Future<void> _clearProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyImage);
    await prefs.remove(_prefKeyAvatar);
    setState(() {
      _profileImage = null;
      _selectedAvatar = null;
    });
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updatedUser = User(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: user!.password,
        phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        age: int.tryParse(ageCtrl.text),
        height: double.tryParse(heightCtrl.text),
        weight: double.tryParse(weightCtrl.text),
      );

      await UserPrefs.saveUser(updatedUser);

      setState(() {
        user = updatedUser;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildProfileAvatar() {
    if (_selectedAvatar != null) {
      // Mostrar emoji/avatar
      return CircleAvatar(
        radius: 60,
        // ignore: deprecated_member_use
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(_selectedAvatar!, style: TextStyle(fontSize: 60)),
      );
    } else if (_profileImage != null) {
      // Mostrar imagen seleccionada
      return CircleAvatar(
        radius: 60,
        // ignore: deprecated_member_use
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: FileImage(_profileImage!),
      );
    } else {
      // Mostrar icono por defecto
      return CircleAvatar(
        radius: 60,
        // ignore: deprecated_member_use
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(Icons.person, size: 60, color: AppColors.primary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Perfil'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mi Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
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
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
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

                SizedBox(height: 32),

                // Formulario
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
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
                      SizedBox(height: 16),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        enabled: false,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: InputDecoration(
                          labelText: 'Teléfono (opcional)',
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: ageCtrl,
                              decoration: InputDecoration(
                                labelText: 'Edad',
                                prefixIcon: Icon(
                                  Icons.cake_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: heightCtrl,
                              decoration: InputDecoration(
                                labelText: 'Altura (cm)',
                                prefixIcon: Icon(
                                  Icons.height,
                                  color: AppColors.primary,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: weightCtrl,
                        decoration: InputDecoration(
                          labelText: 'Peso (kg)',
                          prefixIcon: Icon(
                            Icons.monitor_weight_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Botón guardar
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Botón cerrar sesión
                TextButton(
                  onPressed: () async {
                    await UserPrefs.clearUser();
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
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
