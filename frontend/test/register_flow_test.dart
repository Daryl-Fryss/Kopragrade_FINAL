// The sign-up flow: a successful registration goes back to the sign-in screen and shows
// the "You are registered" notification. The account is NOT signed in automatically -
// the user logs in with the new account (see RegisterScreen / AuthController.register).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopragrade/core/api_client.dart';
import 'package:kopragrade/main.dart';
import 'package:kopragrade/providers/auth_controller.dart';
import 'package:kopragrade/providers/providers.dart';
import 'package:kopragrade/services/auth_service.dart';

/// Stands in for the real controller: the sign-up succeeds without calling a server.
class _FakeAuthController extends AuthController {
  _FakeAuthController()
    : super(ApiClient(), AuthService(ApiClient()));

  bool registered = false;

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    registered = true;
    // like the real controller: the account exists now, but nobody is signed in
  }
}

void main() {
  testWidgets('a successful sign-up shows a notification and returns to sign in', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeAuthController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith((ref) => fake)],
        child: const KopraGradeApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Join KopraGrade'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Juan Dela Cruz',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'juan@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');

    await tester.ensureVisible(find.text('Sign up'));
    await tester.tap(find.text('Sign up'));
    await tester.pump();
    await tester.pumpAndSettle();

    // registered, still signed out, and back on the sign-in screen
    expect(fake.registered, isTrue);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);

    // the success notification is on top of the sign-in screen
    expect(find.textContaining('You are registered'), findsOneWidget);

    // let the notification finish so no timer is left pending
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
