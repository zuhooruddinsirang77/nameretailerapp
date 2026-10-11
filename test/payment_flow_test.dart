import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nameretailer_mobile/core/widgets/widgets.dart';
import 'package:nameretailer_mobile/features/checkout/data/payment_repository.dart';
import 'package:nameretailer_mobile/features/checkout/models/checkout.dart';
import 'package:nameretailer_mobile/features/checkout/models/payment.dart';
import 'package:nameretailer_mobile/features/checkout/providers/checkout_provider.dart';
import 'package:nameretailer_mobile/features/checkout/screens/checkout_screen.dart';
import 'package:nameretailer_mobile/features/checkout/screens/order_screen.dart';
import 'support/harness.dart';
import 'checkout_flow_test.dart' show fixtureDraft;

const orderId =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

class PayingCheckoutRepo extends FakeCheckoutRepo {
  PayingCheckoutRepo({this.blocked = false}) : super(draft: fixtureDraft());
  final bool blocked;
  String? savedPreference;
  Future<CheckoutView> _view([CheckoutDraft? saved]) async => CheckoutView(
    draft: saved ?? draft,
    cart: await FakeCartRepo(items: [sampleCartItem('a')]).getCart(),
    issues: blocked ? ['The article file expired.'] : [],
    paymentAvailable: true,
    orderSubmissionAvailable: !blocked,
    paymentMethods: const PaymentMethods(stripe: true, paypal: true),
  );
  @override
  Future<CheckoutView> getCheckout() => _view();
  @override
  Future<CheckoutView> saveCheckoutDraft({
    required int version,
    required int cartVersion,
    required BillingDetails billing,
    required String notes,
    required String paymentPreference,
  }) {
    savedPreference = paymentPreference;
    return _view(
      CheckoutDraft(
        version: version + 1,
        cartVersion: cartVersion,
        billing: billing,
        notes: notes,
        paymentPreference: paymentPreference,
      ),
    );
  }
}

class FakePaymentRepo implements PaymentRepository {
  String? startedProvider;
  int? startedDraftVersion;
  int confirmations = 0;
  String status = 'pending';
  String confirmedStatus = 'paid';
  CustomerOrder get order => CustomerOrder(
    id: orderId,
    provider: 'stripe',
    status: status,
    totalCents: 12300,
    items: [sampleCartItem('a')],
    createdAt: '2026-01-01T00:00:00Z',
  );
  @override
  Future<PaymentRedirect> start({
    required int cartVersion,
    required int draftVersion,
    required String provider,
  }) async {
    startedProvider = provider;
    startedDraftVersion = draftVersion;
    return const PaymentRedirect(
      orderId: orderId,
      url: 'https://checkout.stripe.com/c/pay/fixture',
    );
  }

  @override
  Future<CustomerOrder> getOrder(String id) async => order;
  @override
  Future<CustomerOrder> confirm(String id) async {
    confirmations++;
    status = confirmedStatus;
    return order;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final provider in ['stripe', 'paypal']) {
    testWidgets(
      '$provider checkout saves the latest draft and requires terms before payment',
      (tester) async {
        final checkout = PayingCheckoutRepo();
        final payments = FakePaymentRepo();
        await pumpApp(
          tester,
          const CheckoutScreen(),
          overrides: [
            ...await testOverrides(),
            checkoutRepositoryProvider.overrideWithValue(checkout),
            paymentRepositoryProvider.overrideWithValue(payments),
          ],
        );
        await tester.tap(find.text('Continue to payment'));
        await tester.pumpAndSettle();
        if (provider == 'paypal') {
          await tester.ensureVisible(find.text('PayPal'));
          await tester.tap(find.text('PayPal'));
        }
        await tester.tap(find.text('Review order'));
        await tester.pumpAndSettle();
        final label = provider == 'paypal'
            ? 'Pay with PayPal'
            : 'Pay with Stripe';
        final payButton = find.widgetWithText(AppButton, label);
        await tester.ensureVisible(payButton);
        expect(tester.widget<AppButton>(payButton).onPressed, isNull);
        expect(payments.startedProvider, isNull);
        await tester.ensureVisible(find.byType(CheckboxListTile));
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();
        await tester.ensureVisible(payButton);
        await tester.tap(payButton);
        await tester.pumpAndSettle();
        expect(checkout.savedPreference, provider);
        expect(payments.startedProvider, provider);
        expect(payments.startedDraftVersion, 4);
        expect(find.text('stub'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('A checkout issue blocks progression before payment', (
    tester,
  ) async {
    final repo = PayingCheckoutRepo(blocked: true);
    await pumpApp(
      tester,
      const CheckoutScreen(),
      overrides: [
        ...await testOverrides(),
        checkoutRepositoryProvider.overrideWithValue(repo),
      ],
    );
    expect(
      tester
          .widget<AppButton>(
            find.widgetWithText(AppButton, 'Continue to payment'),
          )
          .onPressed,
      isNull,
    );
    expect(find.text('The article file expired.'), findsOneWidget);
  });
  for (final config in layoutConfigs) {
    testWidgets('Only server verification displays paid at ${config.name}', (
      tester,
    ) async {
      final payments = FakePaymentRepo();
      await pumpApp(
        tester,
        const OrderScreen(orderId: orderId),
        config: config,
        overrides: [
          ...await testOverrides(),
          paymentRepositoryProvider.overrideWithValue(payments),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('Payment confirmed'), findsNothing);
      expect(find.text('Awaiting payment confirmation'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Check payment'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Check payment'));
      await tester.pumpAndSettle();
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pumpAndSettle();
      expect(payments.confirmations, 1);
      expect(find.text('Payment confirmed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Pending server confirmation stays pending', (tester) async {
    final payments = FakePaymentRepo()..confirmedStatus = 'pending';
    await pumpApp(
      tester,
      const OrderScreen(orderId: orderId),
      overrides: [
        ...await testOverrides(),
        paymentRepositoryProvider.overrideWithValue(payments),
      ],
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Check payment'));
    await tester.tap(find.text('Check payment'));
    await tester.pumpAndSettle();
    expect(find.text('Payment confirmed'), findsNothing);
    expect(find.text('Awaiting payment confirmation'), findsOneWidget);
  });
  testWidgets('Hosted payment opens only the validated provider URL', (
    tester,
  ) async {
    Uri? opened;
    await pumpApp(
      tester,
      const OrderScreen(
        orderId: orderId,
        redirect: PaymentRedirect(
          orderId: orderId,
          url: 'https://checkout.stripe.com/c/pay/fixture',
        ),
      ),
      overrides: [
        ...await testOverrides(),
        paymentRepositoryProvider.overrideWithValue(FakePaymentRepo()),
        paymentBrowserProvider.overrideWithValue((uri) async {
          opened = uri;
          return true;
        }),
      ],
    );
    await tester.pumpAndSettle();
    expect(opened?.host, 'checkout.stripe.com');
    expect(find.text('Payment confirmed'), findsNothing);
  });
}
