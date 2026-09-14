import 'package:flutter/material.dart';

class AuthentificationForm extends StatefulWidget {
  const AuthentificationForm({super.key});

  @override
  State<AuthentificationForm> createState() => _AuthentificationFormState(); // <- Nom standard
}

class _AuthentificationFormState extends State<AuthentificationForm> { // <- Nom standard
  final _formKey = GlobalKey<FormState>();
  String? _userName;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          const Text('Welcome to the GitStats Viewer'),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Username',
              labelText: 'Username',
              prefixIcon: Icon(Icons.account_circle_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Username required';
              if (value.contains('@') || value.contains('%')) return 'Username cannot have special characters';
              return null;
            },
            onSaved: (value) => _userName = value,
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Password',
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
            obscureText: true, // Conseil : c'est mieux pour un mot de passe !
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password required';
              return null;
            },
            onSaved: (value) => _password = value,
          ),
          Text(
            '-You are logged out. Login to connect to the gitstats viewer', 
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary, // Couleur gérée proprement
              foregroundColor: Theme.of(context).colorScheme.onPrimary, // Texte lisible sur le primary
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              }
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }
}