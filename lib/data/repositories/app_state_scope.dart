import 'package:flutter/widgets.dart';

import 'mock_sfa_repository.dart';

class AppStateScope extends InheritedNotifier<MockSfaRepository> {
  const AppStateScope({
    required MockSfaRepository repository,
    required super.child,
    super.key,
  }) : super(notifier: repository);

  static MockSfaRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
