# NameRetailer — Customer Mobile Application

A complete, production-ready Flutter mobile application exclusively for NameRetailer customers on Android and iOS.

---

## 1. Architectural Highlights

- **Framework**: Flutter 3.41.6 / Dart 3.11.4
- **State Management**: [Riverpod](https://riverpod.dev) (`flutter_riverpod: ^2.6.1`)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) (`go_router: ^17.5.0`) with `StatefulShellRoute`
- **Networking**: [Dio](https://pub.dev/packages/dio) (`dio: ^5.11.1`) with JWT Bearer Token Interceptor & automatic 401 handling
- **Secure Storage**: [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) (`flutter_secure_storage: ^11.2.0`)
- **Image Caching**: [Cached Network Image](https://pub.dev/packages/cached_network_image)
- **Design System**: Material 3 with customized brand tokens, typography scales, dark/light theme palettes, and native micro-interactions.

---

## 2. Customer-Only Features (Zero Admin Access)

> **Strict Security Notice**: This application contains strictly customer-facing workflows. All administrative panels, CMS operations, product uploads, user controls, and privileged settings are entirely excluded.

### Core Customer Capabilities
1. **Catalog & Discovery**:
   - Live browsing across all **56,000+ active domains**.
   - Real-time search with debounced queries.
   - Comprehensive multi-metric filtering:
     - Topic / Category (Business, Technology, Finance, Travel, Health, etc.)
     - Location / Country (United States, UK, Canada, Australia, etc.)
     - Domain Rating (DR) range (0 - 90+)
     - Domain Authority (DA) range (0 - 90+)
     - Monthly Traffic range
     - Placement Price filter
   - Sort orders: Publication A–Z, Price Low to High, Price High to Low, DR High to Low, Traffic High to Low.
   - Server-side pagination with real page counts.

2. **Domain Details & SEO Transparency**:
   - Full publication metrics breakdown: DA, DR, Est. Monthly Traffic, Trust Flow (TF), URL Rating (UR), Referring Domains, Backlinks, and Spam Score.
   - Placement requirements, link types (DoFollow), turnaround windows (3-5 days).
   - One-tap site visit (external link).

3. **Customer Shortlist (Bookmarks & Comparison)**:
   - Save up to 8 publications locally and compare their metrics side by side.
   - Quick one-tap planning from shortlist.

4. **Planning Cart & Placement Briefs**:
   - Customer-scoped planning cart synchronized with the database.
   - Article writing add-on options:
     - Own Article Supplied ($0)
     - 500 Words Professional Article
     - 750 Words Long-Form Article
     - 1,000 Words Comprehensive Guide
   - Detailed placement brief form (Promoted URL, Target Keyword / Anchor Text, Special Publisher Requirements, Article Content / Draft).
   - Live total price calculation.

5. **Checkout Review (3-Step Progress)**:
   - Step 1: Publication → Step 2: Brief & Cart → Step 3: Checkout Review.
   - Billing details form (First Name, Last Name, Email, Country, Address, City, Postal Code, Phone).
   - Special order notes.
   - Stripe and PayPal hosted checkout, verified payment status and customer order history.
   - 7-day private billing drafts. Saving a draft does not reserve inventory or take payment.

6. **Customer Account & Security**:
   - Customer login with email & password.
   - Customer registration with name, email, password (12-256 characters policy).
   - Profile name update.
   - Secure session handling via signed Bearer JWT tokens in Android KeyStore / iOS Keychain.
   - One-tap sign out with confirmation.

7. **Placement Inquiries**:
   - Direct placement inquiry form to contact NameRetailer support with publication domain context.

---

## 3. Directory Structure

```
mobile/
├── lib/
│   ├── core/
│   │   ├── constants/       # API endpoints & base URLs
│   │   ├── network/         # Dio client & token interceptors
│   │   ├── providers/       # Core Riverpod providers (storage, client)
│   │   ├── storage/         # Secure storage & preferences service
│   │   ├── theme/           # AppColors, AppTypography, AppTheme
│   │   └── utils/           # Formatters (currency, metrics, domain hostnames)
│   ├── features/
│   │   ├── auth/            # Customer login, register, models, state
│   │   ├── cart/            # Planning cart, brief configuration, writing add-ons
│   │   ├── checkout/        # Billing details, payment preference, draft saving
│   │   ├── home/            # Hero section, statistics, featured publishers
│   │   ├── inquiry/         # Customer placement inquiries
│   │   ├── marketplace/     # Catalog, search, filters sheet, domain details, shortlist
│   │   ├── navigation/      # GoRouter configuration & Bottom Navigation Shell
│   │   └── profile/         # Account overview, name editor, about & help screens
│   └── main.dart            # App entry point
└── test/
    ├── formatters_test.dart # Currency and metric formatter unit tests
    ├── models_test.dart     # Serialization & model tests
    └── widget_test.dart     # App & HomeScreen smoke widget tests
```

---

## 4. API & Backend Integration

The mobile app integrates with the existing NameRetailer backend:

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/mobile/auth/login/` | `POST` | Customer authentication returning JWT token |
| `/api/mobile/auth/register/` | `POST` | Customer registration |
| `/api/mobile/auth/profile/` | `GET`, `PATCH` | Retrieve and update customer profile |
| `/api/mobile/products/` | `GET` | Catalog query with search, sort, filter, and pagination |
| `/api/mobile/products/facets/` | `GET` | Available topics, countries, and languages |
| `/api/mobile/products/:id/` | `GET` | Publication details and placement options |
| `/api/mobile/cart/` | `GET`, `PUT`, `DELETE` | Customer planning cart operations |
| `/api/mobile/checkout/` | `GET`, `PUT` | Checkout review and 7-day draft saving |
| `/api/mobile/checkout/` | `DELETE` | Delete saved billing draft |
| `/api/mobile/cart/files/` | `GET`, `POST` | Retained article files and private uploads |
| `/api/mobile/cart/files/:id/` | `GET`, `DELETE` | Owner-only article download and deletion |
| `/api/mobile/payments/` | `POST` | Create or resume Stripe/PayPal hosted checkout |
| `/api/mobile/payments/confirm/` | `POST` | Server-verified payment confirmation |
| `/api/mobile/orders/` | `GET` | Customer order history |
| `/api/mobile/orders/:id/` | `GET` | Customer order status |
| `/api/mobile/inquiries/` | `POST` | Submit customer placement questions |

---

## 5. Setup & Running Instructions

See [mobile payment setup](docs/payments.md) for server `.env` variables, webhooks and payment verification. Provider secrets belong only in the backend environment.

### Prerequisites
- Flutter SDK 3.41+
- Android Studio / Android SDK 34+
- Xcode (for iOS on macOS), targeting iOS 14+ for the native document picker

### Install Dependencies
```bash
cd mobile
flutter pub get
```

### Run Static Analysis
```bash
flutter analyze
```

### Run Automated Tests
```bash
flutter test
```

### Run on Connected Device / Emulator
```bash
# Debug mode
flutter run

# With custom API URL (e.g. local backend)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

### Build Android APK
```bash
flutter build apk --release
```

### Build iOS Application (macOS)
```bash
cd ios
pod install
cd ..
flutter build ipa --no-codesign
```
