class Validators {
  // Validación de email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  // Validación de contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  // Validación de confirmación de contraseña
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Validación de nombre
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.length < 2) {
      return 'Mínimo 2 caracteres';
    }
    return null;
  }

  // Validación de edad (opcional)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) return null;

    final age = int.tryParse(value);
    if (age == null) {
      return 'Edad inválida';
    }
    if (age < 1 || age > 120) {
      return 'Edad debe ser entre 1-120';
    }
    return null;
  }

  // Validación de altura en cm (opcional)
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) return null;

    final height = double.tryParse(value);
    if (height == null) {
      return 'Altura inválida';
    }
    if (height < 50 || height > 250) {
      return 'Altura debe ser entre 50-250 cm';
    }
    return null;
  }

  // Validación de peso en kg (opcional)
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) return null;

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Peso inválido';
    }
    if (weight < 2 || weight > 300) {
      return 'Peso debe ser entre 2-300 kg';
    }
    return null;
  }

  // Validación de teléfono (opcional)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;

    if (!RegExp(r'^[0-9\+\-\s]{6,20}$').hasMatch(value)) {
      return 'Teléfono inválido';
    }
    return null;
  }
}
