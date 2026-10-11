# Mobile placement and payment setup

The mobile app shares publication prices, writing packages, brief validation, private article files, cart revisions, checkout drafts and orders with the website. The Flutter screens use authenticated `/api/mobile/` routes; provider secrets stay on the Next.js server.

## Server environment

Add these values to `D:\nameretailer\.env` (or the deployed backend's private environment), then restart the backend. Do not put payment secrets in Flutter assets, a mobile `.env`, or `--dart-define`.

```dotenv
STRIPE_SECRET_KEY=sk_test_your_key
STRIPE_WEBHOOK_SECRET=whsec_your_signing_secret
PAYPAL_CLIENT_ID=your_sandbox_client_id
PAYPAL_CLIENT_SECRET=your_sandbox_client_secret
PAYPAL_WEBHOOK_ID=your_sandbox_webhook_id
PAYPAL_ENV=sandbox
NEXTAUTH_URL=https://your-backend-domain
SITE_URL=https://your-backend-domain
```

Stripe requires both its secret key and webhook signing secret. PayPal requires its client ID, client secret and webhook ID. A method remains unavailable until its complete configuration is present. The hosted Stripe integration does not require a publishable key in the mobile app.

Configure Stripe's webhook at `https://your-backend-domain/api/payments/stripe/webhook/` for:

- `checkout.session.completed`
- `checkout.session.async_payment_succeeded`
- `checkout.session.async_payment_failed`
- `checkout.session.expired`

Configure PayPal's webhook at `https://your-backend-domain/api/payments/paypal/webhook/` for:

- `CHECKOUT.ORDER.APPROVED`
- `PAYMENT.CAPTURE.COMPLETED`
- `PAYMENT.CAPTURE.PENDING`
- `PAYMENT.CAPTURE.DENIED`

The existing commerce database needs its MongoDB transaction support. Deploy the mobile API routes alongside the existing backend before running the app against that backend.

## Run from PowerShell

```powershell
cd D:\nameretailer\mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=https://your-backend-domain
```

The default backend is `https://nameretailer.com`. For Android emulator development, `--dart-define=API_BASE_URL=http://10.0.2.2:3000` connects to a local backend. Payment callbacks still need the backend's configured return origin and reachable webhook URLs.

## Customer flow

1. Buy/Plan opens **Create a placement brief** and fetches the current publication options. Existing briefs restore when edited.
2. Enter a public HTTP(S) destination, keyword and optional requirements. Choose **Link only** or **Link + article** using the publication's actual writing charges.
3. Supply article text or a private PDF/DOC/DOCX/TXT upload (up to 5 MiB). Writing packages require a theme brief. Retained uploads can be reused, downloaded and deleted. Uploaded drafts expire after seven days.
4. Save and continue to the cart. Incomplete briefs, unavailable publications, changed prices and unavailable files block checkout.
5. Complete billing, choose Stripe or PayPal and review the order. **Save order draft** stores billing for seven days; it does not reserve inventory or charge payment.
6. Agree to the linked policies and choose **Pay with Stripe** or **Pay with PayPal**. The app saves the latest draft and requests a server-priced, idempotent payment attempt.
7. Complete payment in the external browser. The provider uses the existing website return URL. Return to the app; it checks the provider when resumed, and **Check payment** allows a manual retry. A browser redirect alone never marks an order paid.
8. **Profile → Your orders** provides recovery after closing the app, including pending attempts. Check an existing attempt before retrying checkout.

## Sandbox verification

Use Stripe test credentials and PayPal sandbox credentials first. Verify successful payments, cancellation, declined payments, delayed confirmation, app restart, duplicate taps, expired files, changed cart revisions and account ownership. A live merchant test has not been performed without credentials.

Provider references: [Stripe fulfillment](https://docs.stripe.com/checkout/fulfillment), [PayPal Orders v2](https://developer.paypal.com/api/orders/v2).

The repository currently ignores `mobile/`, including paths with a `mobile` directory segment. If delivering through Git, explicitly include the Flutter project and `app/api/mobile/` files when preparing the commit.
