# The prompts behind Quotesheaf

Quotesheaf lets a small contractor build a quote on site in under two minutes and send it
to the customer as a PDF by Email. The contractor's business profile and service
catalog live in the **AppAmbit CMS**; customers and quotes live in the **AppAmbit Database**;
usage events go to **AppAmbit Analytics** and crashes to **AppAmbit Crash Reporting**.

The whole app is built with **three prompts** sent to a coding agent (Claude Code) that has
the **AppAmbit MCP** connected. Everything runs in **one environment**.

| Step | Where | What it builds |
|---|---|---|
| 0 | AppAmbit dashboard, by hand | The two AppAmbit apps (iOS and Android) and their App Keys |
| 1 | Agent + AppAmbit MCP | The backend: the database, its tables, the CMS content types and the demo content |
| 2 | Agent, Flutter | The app: customers, the quote editor, the service picker, numbering and totals |
| 3 | Agent, Flutter | The PDF, sending by Email, analytics and tests |

Each prompt is self-contained: paste it as is. The product rules come from [PRD.md](PRD.md),
the look from [DESIGN.md](DESIGN.md) and the code structure from [AGENTS.md](AGENTS.md).

---

## 0. Create the apps in AppAmbit (dashboard, by hand)

The agent can't create AppAmbit apps, so this step is done in the dashboard:

1. Create **App Quote - iOS** (platform iOS, stack Flutter).
2. Create **App Quote - Android** (platform Android, stack Flutter).
3. Copy both App Keys into `.env` (use `.env.example` as the template; `.env` is git-ignored):

```
APPAMBIT_IOS_APP_KEY=<App Quote - iOS key>
APPAMBIT_IOS_CMS_SUFFIX=
APPAMBIT_ANDROID_APP_KEY=<App Quote - Android key>
APPAMBIT_ANDROID_CMS_SUFFIX=_android
```

Never paste an App Key into the chat or into a committed file.

---

## 1. The backend in AppAmbit: database, CMS and demo content

```text
Use the AppAmbit MCP to set up the whole backend for Quotesheaf, a contractor quote app.
Call get-started-tool first and work on the two apps "App Quote - iOS" and
"App Quote - Android". Read PRD.md sections 5.5.2, 5.6.1 and 9 before you start.

Rule of the data: the CMS holds the contractor's information (who they are, what they sell),
set once and read-only from the app. The Database holds what the contractor creates every
day: customers and quotes.

DATABASE
- Create the database QuoteFlowDb and link BOTH apps to it (they share customers and quotes).
- Create these tables in one batch (ids are TEXT uuids, money is INTEGER cents, dates ISO text):
  - customers(id PK, name NOT NULL, phone, email, address, notes, created_at)
  - quotes(id PK, number UNIQUE, customer_id REFERENCES customers, issue_date, valid_until,
    business_snapshot (JSON text), tax_label, tax_rate REAL, tax_name, subtotal, tax_amount,
    total, sent_via, sent_at, created_at, updated_at)
  - line_items(id PK, quote_id REFERENCES quotes, service_id, name, description, unit_price,
    quantity REAL, unit, taxable INTEGER, line_total, sort)
  - counters(name PK, value INTEGER) seeded with ('quote', 0)
  - indexes on quotes.customer_id and line_items.quote_id
- Quotes have no status. sent_via and sent_at only record the last send.

CMS
Create these content types, published and linked to the iOS app:
- business_profile: name*, logo (Media), trade_label, license_no, address, phone, email,
  tax_label*, tax_rate*, tax_name, quote_prefix*, valid_days*, approval_note,
  sms_template, email_subject, email_template. One entry only: the app reads the first one.
- catalog_item: name*, sku, category, description, unit, unit_price*, taxable, active
- service_category: name*, sort_order, active
- unit: code*, qty_step*  (0.5 for hours, 1 for each, 0.5 for pounds)
- quote_footer: title, note  (the note may contain {{number}})
- payment_method: label*, value*, sort_order, active
Content type names are unique per team and their entries belong to one app, so create the
same six types for the Android app with the suffix "_android" and the same entries.

DEMO CONTENT (the first contractor: Czanelle's Airconditioning & Refrigeration, Honolulu)
- business_profile: address 3534 Likini St, Honolulu, HI 96818; trade "Air conditioning &
  refrigeration"; tax "GET" 4.5% (tax_rate 0.045); quote_prefix "Q-"; valid_days 14;
  placeholder phone (808) 555-0142, license C-00000; approval_note
  "Reply YES to this text or call {{business_phone}}."; sms and email templates that use
  {{first_name}}, {{business}}, {{number}}, {{total}} and {{business_phone}}.
- The 20 catalog items from PRD 5.6.1 with their units and prices, all taxable and active.
- Categories: Calls, Labor, Refrigerant, Parts. Units: ea, hr, lb, ft.
- One quote_footer ("How to approve") and the payment methods Zelle, Check and Cash.
Use the array form of the create tools: one call per kind, not one call per item.

VERIFY before you tell me it's ready:
- list-databases-tool shows QuoteFlowDb linked to both apps; list-database-tables-tool shows
  the 4 tables; counters has the 'quote' row.
- list-content-types-tool shows the 12 types with is_published true and the app link in place.
- query-content-tool returns 20 catalog items for each app.
Finish with a table: what you created in AppAmbit, how many of each.
```

---

## 2. The Flutter app: customers, quotes and the service picker

```text
Build the Quotesheaf Flutter app on top of the AppAmbit backend that already exists
(QuoteFlowDb + the CMS types). Follow AGENTS.md for the structure and DESIGN.md (direction
M · Mono, black and white, Hanken Grotesk) for every screen. Build only what PRD.md describes.

STACK: Riverpod with code generation, go_router, appambit_sdk_flutter, flutter_dotenv,
uuid, intl, lucide_icons_flutter. Feature-first + MVVM: core/ and features/quotes,
features/customers, features/services, features/business. Views have no logic; ViewModels
never touch widgets; repositories are the only ones that talk to core/services.

APPAMBIT
- main.dart: load .env, pick the key by platform (APPAMBIT_IOS_APP_KEY or
  APPAMBIT_ANDROID_APP_KEY) and await AppAmbitSdk.start before runApp. Crash Reporting
  comes with the SDK.
- core/services/appambit_db.dart: the ONLY place that calls AppAmbitDb (query, execute,
  batchInTransaction). Two SDK gotchas: iOS sends '' as NULL and Android crashes on a null
  param, so never bind empty strings and rewrite null params to a literal NULL.
- core/services/appambit_cms.dart: the ONLY place that reads AppAmbitCms. It appends the
  platform suffix (APPAMBIT_ANDROID_CMS_SUFFIX) to the type name, so repositories use the base
  names. Cache every list and the logo on disk so the app still reads the catalog offline.

SCREENS (no tab bar: Quotes and Customers switch from header icons, Business behind the gear)
- Quotes (home): search by customer, phone or Q-number; rows customer · total / Q-number ·
  date; fixed "New Quote" button; empty state "No quotes yet".
- Quote editor: customer row, "+ Add service", line rows with an edit sheet and swipe to
  remove, live subtotal / tax / total, Save.
- Pick or register customer: search recent customers or register one. Name is required;
  phone and email are optional (validate E.164 and email format, warn on duplicates).
- Add service: the CMS catalog with search, recent services and category chips; tap opens a
  sheet with description, quantity stepper (step from the unit) and "Add to quote".
- Customers list and customer detail (contact + quote history + "New quote for <name>").
- Business: the CMS profile, read-only ("change it in your AppAmbit dashboard"), tax,
  validity days, next quote number and catalog size.

RULES
- Money in integer cents: line_total = round(price x qty), tax = round(taxable subtotal x
  rate), total = subtotal + tax. Format only in the View.
- Quote number: one batchInTransaction that increments counters and inserts the quote with
  number = prefix + 4 digits from the counter, so two phones never get the same number.
- Snapshot: on save, copy the business profile fields and the tax into the quote, and the
  service name, description, price and unit into line_items. Editing the CMS later never
  changes a saved quote.
- Saving needs internet: on failure keep the data and show "Couldn't save — check your
  connection. Retry".
- No statuses, no invoices, no catalog editing in the app.

Run build_runner, flutter analyze with zero warnings, and run the app on the iOS simulator:
register a customer, create a quote with three services and check the rows in QuoteFlowDb.
Finish with a table: what you built in the app.
```

---

## 3. The PDF, sending by Email, analytics and tests

```text
Finish Quotesheaf: the quote PDF, sending it, the AppAmbit events and the tests. Same rules
as before (AGENTS.md, DESIGN.md, PRD.md).

PDF (core/services/pdf_service.dart, on the phone)
- Build it with the pdf package following PRD 5.5.1: optional logo + business name, trade,
  phone and email on the left; "Quote", the number, Issued and Valid until on the right;
  Bill to; the services table (header repeats on page 2); Subtotal, the tax line and the
  Estimated total; footer with the quote_footer title and note ({{number}} replaced) and the
  payment methods, falling back to approval_note; address, license and "Page X of Y".
- Poppins (bundled), black and greys only. Save it to the temp folder.

PREVIEW + SEND
- Quote detail: customer, total, issued / valid until, services, "Edit quote" and
  "Preview & send".
- Preview: the exact PDF in a full-screen viewer (pdfrx, pinch and zoom) with one button,
  Email. No share sheet. The button is disabled with its reason when the customer has no
  email or the phone has no Mail account.
- Email: flutter_email_sender with the customer's email, email_subject, email_template and
  the PDF attached. A small platform channel "quotesheaf/composer" (AppDelegate.swift,
  MainActivity.kt) answers canSendMail. Mail doesn't report the outcome, so nothing is
  recorded after it opens.

ANALYTICS (AppAmbitSdk.trackEvent through one AnalyticsService)
- quote_created and quote_updated with the number; quote_email_opened with the number.

TESTS
- Money and validators, including the PRD sample: subtotal $650.50, GET 4.5% $29.27,
  total $679.77.
- The DB service null and empty-string handling, the customer repository, the editor and
  preview ViewModels with fake repositories, and a widget test for the Quotes list.
- flutter analyze with zero warnings and flutter test green.

Then send the sample quote by Email from the simulator, open the PDF, and show me the
quote_email_opened event in AppAmbit. Finish with a table: what you built.
```
