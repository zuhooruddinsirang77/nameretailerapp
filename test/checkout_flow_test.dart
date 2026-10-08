import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nameretailer_mobile/features/checkout/models/checkout.dart';
import 'package:nameretailer_mobile/features/checkout/providers/checkout_provider.dart';
import 'package:nameretailer_mobile/features/checkout/screens/checkout_screen.dart';

import 'support/harness.dart';

BillingDetails fixtureBilling() => BillingDetails(
  email: 'alex@example.com',
  firstName: 'Alex',
  lastName: 'Morgan',
  country: 'PK',
  street: '12 Market Street',
  apartment: 'Suite 4',
  city: 'Islamabad',
  region: 'ICT',
  postalCode: '44000',
  phone: '+92 300 1234567',
);

CheckoutDraft fixtureDraft() => CheckoutDraft(
  version: 3,
  cartVersion: 1,
  billing: fixtureBilling(),
  notes: 'Existing campaign notes',
  paymentPreference: 'stripe',
);

class RecordingCheckoutRepo extends FakeCheckoutRepo {
  RecordingCheckoutRepo() : super(draft: fixtureDraft());

  BillingDetails? savedBilling;
  String? savedNotes;
  String? savedPreference;
  int? savedVersion;
  int? savedCartVersion;

  @override
  Future<CheckoutView> saveCheckoutDraft({
    required int version,
    required int cartVersion,
    required BillingDetails billing,
    required String notes,
    required String paymentPreference,
  }) async {
    savedBilling = billing;
    savedNotes = notes;
    savedPreference = paymentPreference;
    savedVersion = version;
    savedCartVersion = cartVersion;
    return CheckoutView(
      cart: await FakeCartRepo().getCart(),
      issues: [],
      draft: CheckoutDraft(
        version: version + 1,
        cartVersion: cartVersion,
        billing: billing,
        notes: notes,
        paymentPreference: paymentPreference,
      ),
    );
  }
}

void main() {
  testWidgets('Billing is required before continuing to payment', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const CheckoutScreen(),
      overrides: await testOverrides(),
    );
    await tester.tap(find.text('Continue to payment'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid billing email'), findsOneWidget);
    expect(find.text('Payment method'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final config in layoutConfigs) {
    testWidgets(
      'Checkout steps retain billing and preference at ${config.name}',
      (tester) async {
        final repo = RecordingCheckoutRepo();
        await pumpApp(
          tester,
          const CheckoutScreen(),
          config: config,
          overrides: [
            ...await testOverrides(),
            checkoutRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.text('Continue to payment'));
        await tester.pumpAndSettle();
        expect(find.text('Payment method'), findsOneWidget);
        await tester.ensureVisible(find.text('PayPal'));
        await tester.tap(find.text('PayPal'));
        await tester.tap(find.text('Review order'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Going back must preserve the draft and the choice made on payment.
        await tester.tap(find.byTooltip('Previous step'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Previous step'));
        await tester.pumpAndSettle();
        final email = tester.widget<TextFormField>(
          find.byType(TextFormField).first,
        );
        expect(email.controller?.text, fixtureBilling().email);
        await tester.tap(find.text('Continue to payment'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Review order'));
        await tester.pumpAndSettle();
        final notes = find.byType(TextFormField);
        await tester.ensureVisible(notes);
        await tester.enterText(notes, 'Updated campaign notes');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save order draft'));
        await tester.pumpAndSettle();

        expect(repo.savedBilling?.toJson(), fixtureBilling().toJson());
        expect(repo.savedPreference, 'paypal');
        expect(repo.savedNotes, 'Updated campaign notes');
        expect(repo.savedVersion, 3);
        expect(repo.savedCartVersion, 1);
        expect(find.text('Order draft saved'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Back to cart'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Back to cart'));
        await tester.pumpAndSettle();
        expect(find.text('stub'), findsOneWidget);
      },
    );
  }
}
