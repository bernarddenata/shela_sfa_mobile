import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/app_state_scope.dart';
import 'data/repositories/mock_sfa_repository.dart';

class ShelaSalesApp extends StatefulWidget {
  const ShelaSalesApp({super.key});

  @override
  State<ShelaSalesApp> createState() => _ShelaSalesAppState();
}

class _ShelaSalesAppState extends State<ShelaSalesApp> {
  late final MockSfaRepository _repository;
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _repository = MockSfaRepository();
    _router = AppRouter(_repository);
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      repository: _repository,
      child: MaterialApp.router(
        title: 'SHELA SFA Mobile',
        theme: AppTheme.light,
        routerConfig: _router.config,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
