# NameRetailer mobile visual system

The customer app follows the supplied mobile references: a navy search hero,
cyan headline accents, blue actions, pale surfaces, compact publication cards
and rounded panels. Its content continues to use the existing publisher
placement catalogue and customer APIs.

| Role | Light theme | Dark theme |
| --- | --- | --- |
| Background | `#F6F8FD` | `#050E24` |
| Surface | `#FFFFFF` | `#101D38` |
| Primary text | `#08143E` | `#F1F5F9` |
| Primary action | `#0068FF` | `#0068FF` |
| Price | `#062777` | `#A6C5FF` |
| Hero | `#03183E` → `#00285B` | Same |
| Hero accent | `#00CEEE` | Same |

Manrope is bundled for headings and controls. Shared spacing uses a 4/8-point
scale. Buttons and icon controls retain 48-point touch targets. Forms and cards
grow with system text size, and tablet content is capped at 720 points.

`BrandArtwork` draws abstract ribbons and a geometric mesh with Flutter's
canvas. Publication artwork is derived consistently from its domain; these
decorations need no network request. `BrandMark` draws the folded blue N.

Home, Search, Favorites, Cart and Profile share the navigation shell. Each tab
keeps its navigation state, and tablet layouts use a navigation rail. Heart
controls use the existing shortlist provider and comparison view.

Checkout presents Details, Payment and Review as separate steps. Billing and
campaign fields survive moving between steps. Required billing is validated
before Payment. The final action saves the same versioned checkout draft,
complete billing data and payment preference through the existing repository.

Sign-in and registration use a navy theme in both device appearances. Error
messages, password visibility, autofill and existing authentication behavior
remain part of the forms.

## Review and validation

Previews use explicit test fixtures rather than live customer data:

| Screen | Preview |
| --- | --- |
| Home | [Light](previews/home.png), [dark](previews/home-dark.png) |
| Search | [Light](previews/catalog.png), [dark](previews/catalog-dark.png) |
| Publication | [Detail](previews/publication.png) |
| Favorites | [Saved list](previews/favorites.png) |
| Cart | [Cart](previews/cart.png) |
| Checkout | [Details](previews/checkout.png), [payment](previews/payment.png), [review](previews/order-review.png) |
| Profile | [Account](previews/account.png) |
| Sign-in | [Login](previews/sign-in.png) |

Run `flutter analyze` and `flutter test`. Layout coverage includes narrow phones,
tablets, landscape, both themes and text scales up to 200%. Checkout flow tests
verify validation, back navigation, payment preference persistence, draft
versions and the full saved billing payload.

Regenerate previews with:

```sh
flutter test test/visual_review_test.dart --dart-define=CAPTURE_UI=true
```
