import 'package:flutter/material.dart';

class AuthentificationForm extends StatefulWidget {
  const AuthentificationForm({super.key});

  @override
  State<AuthentificationForm> createState() => _AuthentificationForm();
}

class _AuthentificationForm extends State<AuthentificationForm> {
  final _formKey = GlobalKey<FormState>();
  String? _userName;
  String? _password;
  String? _authToken;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          Text('Welcome to the GitStats Viewer'),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Username',
              labelText: 'Username',
              prefixIcon: Icon(Icons.account_circle_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Username required';
              if (value.contains('@') && value.contains('%')) return 'Username cannot have special characters';
              return null;
            },
            onSaved: (value) => _userName = value,
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Password',
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password required';
              if (!value.contains('@') || !value.contains('%')) return 'Password must have special characters';
              return null;
            },
            onSaved: (value) => _password = value,
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              }
            },
            child: Icon(Icons.save_alt_rounded),
          ),
        ],
      ),
    );
  }
}
