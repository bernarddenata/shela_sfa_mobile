import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_config.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/app_state_scope.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static String? _rememberedCompanyCode;

  final _companyCodeController = TextEditingController(
    text: _rememberedCompanyCode ?? 'demo-distributor',
  );
  final _usernameController = TextEditingController(text: 'budi.sales');
  final _passwordController = TextEditingController(text: 'password');
  bool _rememberCompanyCode = _rememberedCompanyCode != null;
  bool _showPassword = false;
  String? _errorText;

  @override
  void dispose() {
    _companyCodeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final companyCode = _companyCodeController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (companyCode.isEmpty) {
      setState(() {
        _errorText = 'Company code is required.';
      });
      return;
    }
    if (username.isEmpty) {
      setState(() {
        _errorText = 'Username is required.';
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _errorText = 'Password is required.';
      });
      return;
    }

    final loggedIn = AppStateScope.of(
      context,
    ).login(companyCode: companyCode, username: username, password: password);
    if (!loggedIn) {
      setState(() {
        _errorText = 'Company code is not recognized.';
      });
      return;
    }

    _rememberedCompanyCode = _rememberCompanyCode ? companyCode : null;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'S',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              AppConfig.appShortName,
              style: textTheme.headlineMedium?.copyWith(
                color: AppTheme.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Field sales execution for daily store visits.',
              style: textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF4B5563),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 34),
            TextField(
              controller: _companyCodeController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Company Code',
                hintText: 'demo-distributor',
                helperText: 'Enter the company code provided by your admin.',
                prefixIcon: Icon(Icons.apartment_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              onSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _showPassword ? 'Hide password' : 'Show password',
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _rememberCompanyCode,
              onChanged: (value) {
                setState(() {
                  _rememberCompanyCode = value ?? false;
                });
              },
              title: const Text('Remember Company Code'),
              subtitle: const Text(
                'Use the company code shared by your company admin.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _login,
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.offline_bolt_outlined,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Prototype mode uses local offline-ready sample data.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
