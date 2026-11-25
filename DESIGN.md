# DESIGN — Quotesheaf (direction **M · Mono**)

| Field | Value |
|---|---|
| Status | **Chosen design** for the demo (v1.0) |
| Date | 2026-09-23 |
| Scope | PRD **v1.2 — Quotes only** (`PRD.md`): Quotes + Customers + Business. No Invoices, no Catalog screen, no inventory. |
| Platform | Flutter · iOS first (iPhone 390×844 reference frame) |
| Mockups | `docs/design/mono/*.png` (screens) · `docs/design/mono/html/` (source mockups, open `M-Home.dc.html` in a browser) |
| Alternative kept | **N · Harbor** → `docs/DESIGN-alt-harbor.md` |

> The **PDF sent to the customer** has its own fixed design (Poppins, zinc greys) in `PRD.md` §5.5.1. This file covers the **app UI** only.

---

## 1. Principles

1. **Black & white, one voice.** Ink on white. The only color in the app is the **status dot**. No gradients, no tinted cards, no brand color.
2. **Nothing boxed.** Lists are full-width rows separated by 1px hairlines. No cards, no borders around groups, no shadows (except the bottom sheet).
3. **One primary action per screen**, always a black pill at the bottom (New Quote · Preview · Text · Add to quote · Save).
4. **The number is the hero.** Totals are the largest text on detail screens; lists show the total (tax included) and nothing else money-related.
5. **Two places only.** *Quotes* (home) and *Customers*, switched from the header. *Business* is read-only settings behind a gear. No tab bar.
6. **Thumb-first.** Primary buttons live in the bottom 120px; every tap target ≥ 44×44.

## 2. Design tokens

### 2.1 Color
| Token | Hex | Use |
|---|---|---|
| `bg` | `#FFFFFF` | Screen background, docks, sheets |
| `ink` | `#161616` | Text, icons, **primary button fill**, back links |
| `muted` | `#6B6B68` | Secondary text, section labels, placeholders (5.3:1 on white) |
| `hairline` | `#EDEDEA` | Row dividers, dock top border, outlined button border, field border |
| `soft` | `#F4F4F2` | Search field fill, header icon hover |
| `tint` | `#F1F1EE` | Selected filter chip, secondary (soft) button fill |
| `onInk` | `#FFFFFF` | Text/icon on primary button |
| `scrim` | `rgba(20,22,26,.22)` | Behind bottom sheets |

**Status colors** (dot 7×7 + label; label text stays `muted`):
| Status | Dot |
|---|---|
| Draft | `#737373` |
| Sent | `#2B62C4` |
| Approved | `#2E7D4F` |
| Declined | `#B3372E` |

### 2.2 Typography
Font: **Hanken Grotesk** (400 / 500 / 600 / 700) — bundle the TTFs as assets (like Poppins for the PDF) so it works offline. Fallback: system (SF Pro).

| Style | Size / weight | Letter-spacing | Use |
|---|---|---|---|
| `display` | 40 / 700 | −1.2 | Total on quote detail |
| `title` | 32 / 700 | −0.8 | Home / Customers title |
| `titleDetail` | 28 / 700 | −0.6 | Customer name on detail |
| `amountLg` | 22 / 700 | 0 | Total in editor dock, line total in sheet |
| `sheetTitle` | 19 / 700 | 0 | Bottom-sheet title |
| `body` | 16 / 500 | 0 | Row title, nav title (600), buttons (600) |
| `bodyStrong` | 16 / 600 | 0 | Row trailing amount |
| `callout` | 15 / 400 | 0 | Helper paragraphs |
| `small` | 14 / 400 | 0 | Totals breakdown, meta lines |
| `caption` | 13 / 400–600 | 0 | Row subtitle, section labels (600), kicker ("Czanelle's") |
| `micro` | 12 / 400 | 0 | Field hints, nav subtitle |

Numbers: use tabular figures (`FontFeature.tabularFigures()`) for amounts in lists.

### 2.3 Spacing, radius, elevation
| Token | Value |
|---|---|
| Screen side padding | **24** (rows, headers) · 20 (search, docks, buttons) |
| Row padding | 15 vertical × 24 horizontal |
| Section label | top 22 · bottom 8 |
| Gaps | 4 (row title ↔ subtitle) · 10 (buttons in a row) · 12 (form fields) · 16 (sheet content) |
| Radius | Pill = height/2 (all buttons) · 12 (search, text fields) · 16 (filter chip) · 24 (sheet top corners) |
| Elevation | None, except bottom sheet over scrim |
| Safe areas | Content starts ≈ 54–62 below top; docks pad 32 at the bottom |

## 3. Components

| Component | Spec |
|---|---|
| **Main header** (Quotes / Customers) | Kicker "Czanelle's" (`caption`, muted) above `title`. Right: 44×44 icon buttons — `users` (go to Customers) or `doc` (back to Quotes), then `gear` (Business). Icons 21px, stroke 1.6. |
| **Nav bar** (inner screens) | 3-column grid (100 / flex / 100). Left: chevron + back label (16, ink). Center: title (16/600) + optional subtitle (`micro`, muted). Right: text action ("Save", "Edit") 16/600 ink, or an icon. |
| **Search field** | 44h, radius 12, fill `soft`, 18px search icon, placeholder muted, margin 14 top / 20 sides. |
| **Filter chips** | 32h, radius 16, 13/600. Selected: fill `tint`, ink text. Unselected: transparent, muted text. Row gap 4. Options: All · Draft · Sent · Approved · Declined. |
| **Section label** | `caption` 600 muted, left; optional right-aligned hint or action ("+ Add service", "+ Register", "incl. tax"). |
| **List row** | Line 1: title (16/500) ↔ trailing (16/600). Line 2 (optional): subtitle (13, muted) ↔ meta (13, muted). 1px `hairline` bottom. Whole row tappable. |
| **Status** | 7px dot + status word inside the subtitle: `Q-0038 · ● Sent`. |
| **Primary button** | Pill, fill `ink`, text white 16/600, optional 18px icon, heights 48 / 52 / 54 / 56. |
| **Secondary (outlined)** | Pill, white, 1px `hairline` border, ink text. |
| **Soft button** | Pill, fill `tint`, ink text (e.g., "Email", "New quote for David"). |
| **Fixed CTA** | "New Quote": full-width pill 56h, 20 from sides, 32 from bottom, `plus` icon. Home only. |
| **Dock** | Bottom container on editor/preview: white, 1px top hairline, padding 14/20/32, gap 10. |
| **Money block** | Rows (`small`, muted): Subtotal, GET 4.5%. Then hairline + "Total + tax" (15/600) ↔ amount (`amountLg`). |
| **Text field** | Label above (13/600 muted) · input 48h, radius 12, 1px hairline, 16 ink · hint below (`micro` muted). |
| **Stepper** | − 46px circle outlined · value 26/700 · + 46px circle filled ink. |
| **Bottom sheet** | Radius 24 top, padding 10/24/32, grabber 36×5 `hairline`, content gap 16, scrim behind. |
| **Service chips (recent)** | 36h pill, white, 1px hairline, 13 ink ("Diagnostic $129"). |
| **PDF preview** | White page, 290px wide (Letter ratio), shadow `0 2 16 rgba(0,0,0,.08)`, centered. |

## 4. Screens

Reference images: `docs/design/mono/M-*.png`.

### 4.1 Quotes — Home (`M-Home`) · PRD F-01
- Main header "Quotes" (+ Customers, Business icons).
- Search: "Customer, phone or Q-number". Filter chips by status.
- **"Waiting for an answer"** section on top: quotes in `Sent` (follow-up list).
- **"All quotes · by customer"** (hint "incl. tax"): rows = customer · total / `Q-#### · ● status` · date. Sorted A–Z by customer.
- Fixed **New Quote** pill.
- Empty state: title "No quotes yet", callout "Create your first quote in under 2 minutes.", same CTA.

### 4.2 New / edit quote (`M-Editor`) · F-02
- Nav: "‹ Quotes" · "New Quote" / "Q-0038 · valid until Oct 7".
- **Customer** row (name / phone · email, chevron) → Customer picker.
- **Services** section with "+ Add service" → Service picker. Rows: service · line total / `qty unit × price`. Tap a row → edit sheet (same as 4.4). Swipe left → Remove.
- **Dock**: money block + [Save draft (outlined)] [Preview (primary)].
- Live totals update on every change (< 100 ms).

### 4.3 Pick / register customer (`M-Pick`) · F-08
- Nav: "‹ Cancel" · "Customer" · "Save".
- Search registered customers → **Recent** rows (tap = use in quote).
- **Or register a new customer**: Name · Mobile (hint "To send by Text") · Email (hint "phone or email is enough").
- Validation inline under the field (E.164 phone, email format, duplicate warning "Already saved as David Souza — use it?").

### 4.4 Add service (`M-Service`) · F-06 — the only place the catalog appears
- Nav: "‹ Quote" · "Add service" / "Your catalog · 20 services".
- Search · **recent** service chips · category chips (All · Calls · Labor · Refrigerant · Parts).
- Rows: service · unit price / `per unit · taxable`. No stock, no edit of the catalog.
- Tap → **sheet**: name + "$85.00 per lb · taxable · from your catalog", Description field (prefilled, editable), Quantity stepper, Line total, **Add to quote**. Price is editable by tapping the price line (optional in demo).

### 4.5 Preview + send (`M-Preview`) · F-04 / F-05
- Nav: "‹ Edit" · "Preview" / "Q-0038 · Leilani Kahale".
- The exact PDF (quote variant) centered.
- Dock: caption "PDF attached · you tap Send in Messages or Mail" + **[Text]** (primary, `msg` icon) **[Email]** (soft, `mail` icon). Exactly two actions, no share sheet.
- Disabled state: button at 40% opacity + reason under it ("Add a phone number to this customer").

### 4.6 Quote detail — Sent (`M-Quote`) · F-03
- Nav: "‹ Quotes" · "Q-0038" · edit icon.
- Customer (muted) · **total** (`display`) · `● Sent by Text · Sep 23, 10:42 AM · valid until Oct 7`.
- **Customer's answer**: "Leilani approves by replying YES or calling you. What did she say?" → [✓ Approved] (primary) [✕ Declined] (outlined). Hint: "Wants changes? Edit the quote and send it again."
- Services (first 2 + "+ 3 more") · **Resend** link.

### 4.7 Quote detail — Approved (`M-Approved`)
- Same header with `● Approved Sep 22`.
- Status note: "This quote is done. Nothing else to do in the app." + **Undo — mark as Sent again**.
- Services + money block. No "convert to invoice".

### 4.8 Customers (`M-Customers`) · F-08
- Main header "Customers" (icons: Quotes, Business).
- Search "Name, phone or email". Section "6 customers · A–Z" with "+ Register".
- Rows: name / phone or email ↔ "2 quotes".

### 4.9 Customer detail (`M-Client`)
- Nav "‹ Customers" · "Edit".
- Name (`titleDetail`) + private note (muted).
- **New quote for David** (soft pill).
- **Contact**: mobile ("used for Text"), email, address. **Quotes**: history rows with status.

### 4.10 Business (`M-Business`) · F-09
- Nav "‹ Back" · "Business". Caption: "Read-only here · change it in your AppAmbit dashboard".
- **Profile** (name, trade, license, address, phone) · **Quotes** (tax GET 4.5%, valid 14 days, next number Q-0039) · **Catalog** ("Services & prices — 20 — used in Add service").

## 5. Navigation map

```
Quotes (home) ──users icon──▶ Customers ──row──▶ Customer detail ──New quote──▶ Editor
   │  ▲                         │
   │  └──────doc icon───────────┘
   ├──gear──▶ Business (read-only)
   ├──New Quote──▶ Editor ──Customer row──▶ Pick customer
   │                 ├──+ Add service──▶ Add service ──sheet──▶ back to Editor
   │                 └──Preview──▶ Preview ──Text / Email──▶ native composer ──▶ Quote detail (Sent)
   └──row──▶ Quote detail ──Approved / Declined──▶ Quote detail (final) ──Undo──▶ Sent
```
Transitions: iOS push for inner screens; bottom sheets for item edit; native composers are modal.

## 6. States & feedback
| Situation | Treatment |
|---|---|
| Saving (needs internet) | Primary button shows a small spinner; on failure keep data and show inline "Couldn't save — check your connection. Retry" |
| Sent result from iOS | `sent` → toast "Sent by Text" and go to Quote detail · `cancelled` → stay on Preview, no toast · `failed` → inline error |
| Offline | Top banner (muted, 13) "You're offline — you can browse, not save" |
| Validation | Red text only for errors (`#B3372E`, 12); field border turns the same color |
| Destructive (remove line) | Swipe action, no confirm; undo toast 4 s |

## 7. Accessibility
- Contrast AA: ink/white 17:1, muted/white 5.3:1, status label is muted text (the dot is decorative).
- Tap targets ≥ 44×44 (icon buttons, chips' hit area, stepper 46).
- Dynamic Type: rows grow in height; never truncate totals — truncate names with ellipsis first.
- Every icon-only button has a semantic label ("Customers", "Business", "Edit quote").
- Status is never color-only: dot + word.

## 8. Flutter implementation notes
- `ThemeData(useMaterial3: true, scaffoldBackgroundColor: bg, colorScheme: ColorScheme.light(primary: ink, onPrimary: onInk, surface: bg, onSurface: ink, outline: hairline))`, `fontFamily: 'HankenGrotesk'`.
- Put tokens in `lib/core/theme/` (`AppColors`, `AppText`, `AppSpacing`, `AppTheme`); components in `lib/core/widgets/` (`QfRow`, `QfSectionLabel`, `QfPillButton` {primary|outlined|soft}, `QfSearchField`, `QfFilterChips`, `QfStatus`, `QfMoneyBlock`, `QfStepper`, `QfSheet`). Architecture and folders: see `AGENTS.md`.
- No `BottomNavigationBar`; the two main screens are top-level **go_router** routes (`/` and `/customers`) switched from the header icons.
- Rows: `InkWell` + `Padding(24/15)` + `Divider(height: 1, color: hairline)` — not `ListTile` (its default paddings/typography don't match).
- Sheets: `showModalBottomSheet(isScrollControlled: true, backgroundColor: bg, barrierColor: scrim, shape: top radius 24)`.
- PDF preview: `PdfPreview` (from `printing`) with all built-in actions disabled (PRD §5.5).
- Icons: outline set at stroke ~1.6 (e.g., `lucide_icons`/`phosphor` light) — doc, users, gear, search, plus, minus, chevron, msg, mail, edit, check, x.
