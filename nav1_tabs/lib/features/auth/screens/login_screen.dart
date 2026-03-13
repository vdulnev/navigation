import 'package:flutter/material.dart';

import '../../../widgets/nav_note_card.dart';
import '../services/auth_service.dart';

/// Login screen presented as a fullscreen dialog over the tab shell.
///
/// Navigator 1 concepts demonstrated:
///
/// • Pushed via `rootNavigator: true` from any tab — sits on top of the
///   entire [ShellScreen] including all per-tab Navigators.
///
/// • Returns `true` via `Navigator.pop(context, true)` on success so the
///   caller can react without touching any global state.
///
/// • Dismissing with the ✕ button calls `Navigator.pop()` with no value;
///   callers receive `null` and treat it as "cancelled".
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      // pop(true): the awaited Future<Object?> in the caller resolves to true.
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'Invalid credentials. Try any non-empty values.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlutterLogo(size: 64),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter an email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter a password' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 16),
                const NavNoteCard(
                  title: 'Navigator 1: pop(value) across Navigator boundaries',
                  body:
                      'pop(true) returns to the caller that used '
                      'rootNavigator: true to push this screen. The caller '
                      'awaits the Future<Object?> to know if login succeeded.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
