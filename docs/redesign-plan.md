# NameRetailer customer app – redesign plan

Scope: presentation layer only. Customer flows only. No change to endpoints, models,
auth/JWT, secure storage, route paths, provider contracts or business rules.

## Phase 0 – Audit (findings before any edit)

Baseline: `flutter analyze` clean, 9 tests passing.

| Area | Finding |
|---|---|
| Colour | ~120 inline `isDark ? X : Y` ternaries and raw hex literals (`0xFFF1F5F9`, `0xFF131D33`…) in screens; no semantic roles. Muted text `#94A3B8` on white is 2.6:1 and price green `#10B981` on white is 2.5:1 – both fail WCAG AA. |
| Type | Platform default font only. Font sizes hard-coded per call site (9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5 …); `AppTypography` is barely used. Several labels are below 11sp. |
| Spacing / radius | Mix of tokens and magic numbers (14, 18, 10, 6…); radii 5/6/8/10/12/16/20 used ad hoc. |
| Buttons | `AppButton` exists but screens also hand-roll `ElevatedButton`/`OutlinedButton` (product card, home search, profile). Heights 34/44/50 – small/medium are below the 48dp touch target. |
| Cards | At least 8 hand-built `Container + BoxDecoration` copies (stat pill, feature card, metric tile, cart item, banner, menu group…). |
| Inputs | `AppTextField` is unused; screens use raw `TextFormField`s with floating labels, no focus order / autofill hints in checkout, the search field is built twice. |
| States | Detail/cart/checkout loading = spinner + text (no skeleton). Errors print raw `err.toString()`. No offline-specific wording. Empty states are decent but unlike error states. |
| Sheets / dialogs | Grab-handle + rounded sheet re-implemented 3 times; 6 hand-built `AlertDialog`s with different button styling. |
| Navigation | Custom bottom bar from `InkWell`s – no Material 3 semantics, 11sp labels, hit area ≈ 48 only by luck. |
| A11y | No `Semantics`; compact icon buttons < 48dp; `SizedBox(height: 42)` chip rail and `GridView(childAspectRatio: 2.1)` overflow at large text scale; no reduced-motion handling. |
| Motion | Only an `AnimatedContainer` in the nav bar and a skeleton pulse; nothing respects `disableAnimations`. |
| Duplicated UI | Hero gradient ×4, status banner ×6, section-title-with-icon ×8, sheet header ×3, price block ×5. |
| Missing UI | No compare view although the shortlist is described as "for comparison"; no step indicator component (checkout fakes one). |

Functionality notes (not changed, reported at the end): search submits on enter/tap (no
debounce exists in code); shortlist is in-memory (`_loadFromStorage` is a stub) so it resets
on app restart; shortlist cap of 8 drops the oldest item silently.

## Phase 1 – Design system (`lib/core/theme`, `lib/core/widgets`)

* `AppPalette` `ThemeExtension` (light + dark) → `context.palette`; screens never branch on brightness.
* Fonts bundled as static instances (no new package): **Fraunces** for display/headlines,
  **Manrope** for UI/body. Type scale in `AppTypography.textTheme`, min 11sp.
* Tokens: 4/8pt spacing (`AppSpace`), radii (`AppRadius`), elevation (`AppElevation`), motion (`AppMotion`, reduced-motion aware).
* Components: `AppButton`, `AppTextField`, `AppCard`, `MetricChip`, `SectionHeader`, `EmptyState`,
  `ErrorState`, `Skeleton*`, `AppBottomSheet`, `StepProgress`, `PriceSummaryBar`, `ConfirmDialog`,
  plus `InlineMessage`, `AppListTile`, `ChoiceTile`, `DomainAvatar`, `Pressable`, `PriceText`.

## Phase 2 – Screens (in order, analyze + test after each)

Shell/nav → Auth → Home → Marketplace (+filter/sort sheets, product card) → Domain detail →
Placement sheet → Cart → Shortlist + compare → Checkout → Profile / About / Help / Inquiry.

## Phase 3 – UX quality

Skeleton/empty/error (with offline wording) everywhere; reduced-motion aware transitions;
48dp targets; AA contrast; layouts verified at 360dp, 412dp, 800dp and 200 % text scale with
widget tests; dark mode driven by the same tokens.

## Phase 4 – Iterate

Per-screen analyze/test, then a repo-wide grep for stray colour/size literals and a final
consistency pass. Deliverables: this plan, `docs/design-system.md`, final report.
