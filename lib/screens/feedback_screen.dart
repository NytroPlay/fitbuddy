import 'package:flutter/material.dart';

import '../utils/user_prefs.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'Sugerencia';
  String _mensaje = '';
  bool _anonimo = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final user = await UserPrefs.loadUser();
    setState(() {
      _email = user?.email;
    });
  }

  Future<void> _enviarFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Aquí puedes guardar en storage local, enviar a un servidor o simplemente mostrar un "Gracias"
    // Ejemplo: Guardar en una lista local, o solo mostrar un snackbar

    // Desbloquear el logro SOLO la primera vez:
    await UserPrefs.unlockAchievement('primer_feedback');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('¡Gracias por tu feedback!')));

    // Limpia el formulario después de enviar
    setState(() {
      _mensaje = '';
      _tipo = 'Sugerencia';
      _anonimo = false;
    });
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _tipo,
                items: const [
                  DropdownMenuItem(
                    value: 'Sugerencia',
                    child: Text('Sugerencia'),
                  ),
                  DropdownMenuItem(
                    value: 'Error',
                    child: Text('Reporte de error'),
                  ),
                  DropdownMenuItem(
                    value: 'Motivación',
                    child: Text('Mensaje motivacional'),
                  ),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (val) => setState(() => _tipo = val ?? 'Sugerencia'),
                decoration: const InputDecoration(labelText: 'Tipo de mensaje'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Mensaje',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'El mensaje es obligatorio'
                    : null,
                onSaved: (val) => _mensaje = val ?? '',
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enviar anónimamente'),
                value: _anonimo,
                onChanged: (val) => setState(() => _anonimo = val),
              ),
              if (!_anonimo)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    initialValue: _email,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tu correo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _enviarFeedback,
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
