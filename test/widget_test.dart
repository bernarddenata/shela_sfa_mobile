import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shela_sales_mobile/app.dart';

void main() {
  testWidgets('dummy login opens the SFA home dashboard', (tester) async {
    await tester.pumpWidget(const ShelaSalesApp());

    expect(find.text('SHELA SFA'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Budi'), findsOneWidget);
    expect(find.text('Daan Mogot'), findsOneWidget);
    expect(find.text("Today's Work"), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Home Menu'),
      500,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Home Menu'), findsOneWidget);
    expect(find.text('Visit'), findsOneWidget);

    await tester.tap(find.text('Visit'));
    await tester.pumpAndSettle();

    expect(find.text('No visit plan for today'), findsOneWidget);
    expect(
      find.text('Add a customer to start your visit plan.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Add Call Plan').last);
    await tester.pumpAndSettle();

    expect(find.text('Toko Sumber Jaya'), findsOneWidget);
    expect(find.text('Toko Makmur Abadi'), findsOneWidget);

    await tester.tap(
      find
          .ancestor(
            of: find.text('Toko Sumber Jaya'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(find.text('No visit plan for today'), findsNothing);
    expect(find.text('Toko Sumber Jaya'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('NOT_STARTED'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('NOT_STARTED'), findsOneWidget);
    expect(find.text('Start Visit'), findsOneWidget);

    await tester.tap(find.text('Start Visit'));
    await tester.pumpAndSettle();

    expect(find.text('Check-in'), findsOneWidget);
    expect(find.text('Location captured'), findsWidgets);
    expect(find.text('-6.1611, 106.7689'), findsOneWidget);
    expect(find.text('0 m from store'), findsOneWidget);
    expect(find.text('Not Detected'), findsWidgets);
    expect(find.text('Normal'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -350));
    await tester.pumpAndSettle();

    expect(find.text('Photo required'), findsOneWidget);

    await tester.tap(find.text('Take Selfie / Store Photo'));
    await tester.pumpAndSettle();

    expect(find.text('Photo captured'), findsWidgets);
    expect(find.text('Check-in Requirements'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Check In'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.text('Check In'));
    await tester.pumpAndSettle();

    expect(find.text('Store Page'), findsOneWidget);
    expect(find.text('IN_PROGRESS'), findsOneWidget);
    expect(find.text('GPS Valid'), findsOneWidget);
    expect(find.text('Fake GPS Not Detected'), findsOneWidget);
    expect(find.text('Selfie/Photo Captured'), findsOneWidget);
    expect(find.text('1 Pending Sync'), findsOneWidget);
    expect(find.text('Primary Sales'), findsOneWidget);
    expect(find.text('Sales / Order'), findsOneWidget);

    await tester.tap(find.text('Sales / Order'));
    await tester.pumpAndSettle();

    expect(find.text('Regular Order'), findsOneWidget);
    expect(find.text('Canvas Order'), findsOneWidget);

    await tester.tap(find.text('Regular Order'));
    await tester.pumpAndSettle();

    expect(find.text('Nabati Wafer 50g'), findsOneWidget);
    expect(find.text('NAB-WFR-50'), findsOneWidget);

    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit Order'));
    await tester.pumpAndSettle();

    expect(find.text('Order Submitted'), findsOneWidget);
    expect(find.text('QUEUED'), findsOneWidget);

    await tester.tap(find.text('View Order'));
    await tester.pumpAndSettle();

    expect(find.text('Order Detail'), findsOneWidget);
    expect(find.text('Product Items'), findsOneWidget);
    expect(find.text('Nabati Wafer 50g'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Store Page'));
    await tester.pumpAndSettle();

    expect(find.text('Store Page'), findsOneWidget);

    await tester.tap(find.text('Return'));
    await tester.pumpAndSettle();

    expect(find.text('Return Order'), findsOneWidget);
    expect(find.text('Return Swap Order'), findsOneWidget);

    await tester.tap(find.text('Return Order'));
    await tester.pumpAndSettle();

    expect(find.text('Return Reason'), findsOneWidget);
    expect(find.text('Nabati Wafer 50g'), findsOneWidget);

    await tester.tap(find.text('Return Reason'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Damaged').last);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -180));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Capture Photo'),
      400,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.text('Capture Photo'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Submit Return'));
    await tester.pumpAndSettle();

    expect(find.text('Return Submitted'), findsOneWidget);
    expect(find.text('QUEUED'), findsOneWidget);

    await tester.tap(find.text('View Return'));
    await tester.pumpAndSettle();

    expect(find.text('Return Detail'), findsOneWidget);
    expect(find.text('Damaged'), findsOneWidget);
  });
}
