# AGENTS.md — quote_generator_app (Quotesheaf)

Single guide for any coding agent (Claude Code, Codex, Cursor…) working in this repo. Read it first, then the sources of truth in §2.

Behavioral guidelines live in the parent `../CLAUDE.md` (apps_cms) and apply here too.

## 1. What this is

A Flutter demo app (`quote_generator_app`) that integrates the AppAmbit platform via `appambit_sdk_flutter`, plus a sample AppAmbit cloud function. The app follows the structure in §5. AppAmbit app: **App Quote - iOS** (key in `.env`), CMS types `business_profile`, `catalog_item`, `service_category`, `unit`, `quote_footer`, `payment_method` (PDF "How to pay" footer; the older `service` type is unused), database `QuoteFlowDb` (tables `customers`, `quotes`, `line_items`, `counters`).

## 2. Sources of truth — read before writing code

| File | What it defines | Rule |
|---|---|---|
| **`PRD.md`** | **All functionality**: scope, screens, flows, data model (CMS + DB), money rules, PDF spec, sending by Email, acceptance criteria. | Build only what the PRD describes. If something is not in the PRD, ask before adding it. |
| **`DESIGN.md`** | The UI: direction **M · Mono** — black & white, **Customers and Business in the header**, **fixed "New Quote" button** at the bottom. Tokens, components, the 10 screens. | Match it exactly (colors, type, spacing, components). Reference images in `docs/design/mono/`. |
| `docs/DESIGN-alt-harbor.md` | Alternative design **N · Harbor** (not active). | Reference only. Do **not** implement unless asked. |

**Scope reminders (PRD v1.2 + decisions of 2026-09-23):** the app is **quotes only** and **quotes have no status** (no Draft / Sent / Approved / Declined; `sent_via` / `sent_at` only record the last send). Everything contractor-specific (profile, tax, numbering, catalog, categories, units) comes from the CMS — no business values in code; UI copy stays in code. Customers need only a name (phone / email optional; Email is disabled with a reason when there is no email). **Quotes are sent by Email only — there is no Text button.** There are **no invoices, no conversion to invoice, no Catalog screen, no inventory, no payment methods**. The service catalog comes from the CMS (read-only) and appears only in the **Add service** picker. Navigation has **no tab bar**: Quotes (home) ↔ Customers from header icons, Business (read-only) behind the gear.

## 3. Commands

```bash
flutter pub get                 # install deps
flutter run -d <device>         # run (flutter devices to list)
flutter analyze                 # lint (flutter_lints via analysis_options.yaml)
flutter test                    # all tests (no test/ dir exists yet)
flutter test test/foo_test.dart --plain-name "name"   # single test
flutter build ios / flutter build apk
dart run build_runner watch -d  # Riverpod code generation
```

## 4. Stack

| Concern | Choice |
|---|---|
| Framework | Flutter (iOS first for the demo) |
| **State management** | **Riverpod** (`flutter_riverpod` + `riverpod_annotation` / `riverpod_generator`) |
| **Navigation** | **go_router** |
| Backend | AppAmbit (`appambit_sdk_flutter`): CMS (read), DB (SQL read/write), analytics, crashes |
| PDF | `pdf` builds the quote on device + `pdfrx` full-screen viewer (pinch / − fit + zoom) + `path_provider` |
| Sending | `flutter_email_sender` 9.x (Email only; opens Mail, does not report sent/cancelled, so nothing is recorded). The platform channel `quotesheaf/composer` (`ios/Runner/AppDelegate.swift`, `MainActivity.kt`) is only used for `canSendMail`; its old `sendText` is not called by the app. **No share sheet, no Text button.** |
| Fonts | Hanken Grotesk (app UI) · Poppins (PDF only) — bundled as assets |

Use the latest stable versions compatible with the Flutter SDK in `pubspec.yaml`.

## 5. Architecture — Feature-first + MVVM, with `core/` and `features/`

### 5.1 Folder structure

```
lib/
├── main.dart                      # AppAmbitSdk.start(...) then runApp(ProviderScope(child: App()))
├── app.dart                       # MaterialApp.router(routerConfig: ref.watch(appRouterProvider), theme: AppTheme.light)
│
├── core/                          # Shared, feature-agnostic code. Never imports from features/.
│   ├── router/
│   │   ├── app_router.dart        # GoRouter provider (@riverpod), all routes
│   │   └── routes.dart            # Route names + path helpers (AppRoutes.quoteDetail(id))
│   ├── theme/
│   │   ├── app_colors.dart        # DESIGN.md §2.1 tokens
│   │   ├── app_text.dart          # DESIGN.md §2.2 type scale
│   │   ├── app_spacing.dart       # spacing + radius tokens
│   │   └── app_theme.dart         # ThemeData (Material 3, Mono)
│   ├── widgets/                   # DESIGN.md §3 components: QfRow, QfSectionLabel, QfPillButton,
│   │                              # QfSearchField, QfFilterChips, QfStatus, QfMoneyBlock, QfStepper,
│   │                              # QfSheet, QfNavBar, QfMainHeader, QfFixedCta, QfTextField
│   ├── services/                  # Wrappers around platform/SDKs — the ONLY place that touches them
│   │   ├── appambit_db.dart       # AppAmbitDb (execute, batchInTransaction)
│   │   ├── appambit_cms.dart      # AppAmbitCms reads + local cache
│   │   ├── pdf_service.dart       # builds the quote PDF (PRD §5.5.1) → temp file
│   │   ├── sms_composer.dart      # platform channel: canSendMail (Email button)
│   │   └── email_composer.dart    # flutter_email_sender
│   ├── utils/                     # money (integer cents), formatters, validators (E.164, email)
│   └── errors/                    # Failure types, error mapping
│
└── features/
    ├── quotes/                    # Home list, editor, preview + send, detail (Sent / Approved)
    │   ├── data/
    │   │   ├── models/            # Quote, LineItem, QuoteStatus, BusinessSnapshot
    │   │   └── repositories/      # QuoteRepository (+ provider) — DB access via core/services
    │   ├── viewmodels/            # QuotesListViewModel, QuoteEditorViewModel, QuotePreviewViewModel, QuoteDetailViewModel
    │   ├── views/                 # QuotesListView, QuoteEditorView, QuotePreviewView, QuoteDetailView
    │   └── widgets/               # widgets used only by this feature
    ├── customers/                 # Customers list, detail, pick / register
    │   ├── data/ (models/, repositories/)
    │   ├── viewmodels/
    │   ├── views/
    │   └── widgets/
    ├── services/                  # CMS service catalog (read-only) + Add service picker
    │   ├── data/ (models/, repositories/)
    │   ├── viewmodels/
    │   ├── views/                 # ServicePickerView + item sheet
    │   └── widgets/
    └── business/                  # BusinessProfile from CMS, read-only Business screen
        ├── data/ (models/, repositories/)
        ├── viewmodels/
        └── views/
```

A new feature = a new folder under `features/` with the same four subfolders (`data/`, `viewmodels/`, `views/`, `widgets/` when needed).

### 5.2 MVVM inside each feature

| Layer | Lives in | Responsibility | Riverpod form |
|---|---|---|---|
| **Model** | `data/models/` | Immutable data classes (`copyWith`, `fromJson/toJson`, equality). Money in **integer cents**. No Flutter imports. | — |
| **Repository** (part of Model) | `data/repositories/` | Reads/writes AppAmbit DB or CMS through `core/services`; maps rows ⇄ models; snapshot logic (PRD §5.5.2). No UI state. | `@riverpod QuoteRepository quoteRepository(Ref ref)` |
| **ViewModel** | `viewmodels/` | Holds the screen's **UI state** (immutable state class) and exposes **intent methods** (`addLine`, `setQuantity`, `markApproved`, `sendByText`…). Calculates totals, validates, calls repositories/services. No widgets, no `BuildContext`. | `@riverpod class QuoteEditorViewModel extends _$QuoteEditorViewModel` (`Notifier` / `AsyncNotifier`; family by id when needed) |
| **View** | `views/` | `ConsumerWidget` / `ConsumerStatefulWidget`. Renders state with `ref.watch(...)`, forwards user actions to the ViewModel via `ref.read(...notifier).method()`. Navigation calls (`context.push(...)`) happen here in response to state/events. | — |

**Rules**
1. **Dependency direction:** `views → viewmodels → repositories → core/services`. Never the other way.
2. **Views have no business logic** — no SQL, no totals math, no validation, no SDK calls.
3. **ViewModels never import Flutter widgets** or `BuildContext`; they are unit-testable with `ProviderContainer`.
4. **One ViewModel per screen** (sheets can share the parent screen's ViewModel).
5. **Features don't import other features' `views/` or `viewmodels/`.** To share data across features, use the other feature's **repository provider** (e.g., `quotes` reads `customerRepositoryProvider`). Screen-to-screen hand-off goes through **go_router** (ids in the path).
6. Anything used by 2+ features moves to `core/`.
7. Async data: ViewModels expose `AsyncValue<State>`; Views use `.when(data:, loading:, error:)` with the states from DESIGN.md §6.
8. Money: integer cents everywhere; format only in the View (`core/utils/money.dart`). `line_total = round(price × qty)`, `tax = round(taxable subtotal × rate)`, `total = subtotal + tax`.

### 5.3 Navigation — go_router

- A single `GoRouter` exposed by a Riverpod provider in `core/router/app_router.dart`. **No `Navigator.push` with `MaterialPageRoute`** anywhere.
- **No `ShellRoute` / tab bar** (Mono design): Quotes and Customers are top-level routes switched from the header icons.
- Pass **ids in the path**, never whole objects in `extra` (screens reload from their ViewModel).
- Use named routes (`context.pushNamed(AppRoutes.quoteDetail, pathParameters: {'id': id})`).

| Route | Name | View |
|---|---|---|
| `/` | `quotes` | `QuotesListView` (home) |
| `/quotes/new` | `quoteNew` | `QuoteEditorView` |
| `/quotes/:id` | `quoteDetail` | `QuoteDetailView` (read-only, Edit, Preview & send) |
| `/quotes/:id/edit` | `quoteEdit` | `QuoteEditorView` |
| `/quotes/:id/preview` | `quotePreview` | `QuotePreviewView` (PDF + Email) |
| `/quotes/:id/customer` | `quotePickCustomer` | `CustomerPickerView` (choose existing) |
| `/quotes/:id/customer/new` | `quoteNewCustomer` | `CustomerFormView(returnToQuote: true)` |
| `/quotes/:id/services` | `quoteAddService` | `ServicePickerView` (+ item sheet) |
| `/customers` | `customers` | `CustomersListView` |
| `/customers/new` | `customerNew` | `CustomerFormView` |
| `/customers/:id` | `customerDetail` | `CustomerDetailView` |
| `/customers/:id/edit` | `customerEdit` | `CustomerFormView` |
| `/business` | `business` | `BusinessView` (read-only) |

Bottom sheets (item edit) are opened from the View with `showModalBottomSheet`, not as routes.

## 6. AppAmbit platform notes

- **AppAmbit SDK init** (`lib/main.dart`): one AppAmbit app per platform — keys in `.env` (`APPAMBIT_IOS_APP_KEY` = App Quote - iOS, `APPAMBIT_ANDROID_APP_KEY` = App Quote - Android; `flutter_dotenv`, `.env` git-ignored, template in `.env.example`). Both apps are linked to `QuoteFlowDb` (shared customers/quotes). CMS content types are unique per team and their entries belong to one app, so each platform has its own copy: iOS uses the plain slugs, Android the same slugs + `APPAMBIT_ANDROID_CMS_SUFFIX` (`_android`) — `AppAmbitCmsService` appends the suffix, repositories keep the base names. Keep both copies in sync when editing the CMS. `AppAmbitSdk.start(appKey:)` is awaited before `runApp`.
- **DB params gotchas:** the SDK DB bridge sends an empty-string param (`''`) as `NULL` on iOS (so `col <> ?` with `''` matches nothing), and the **Android** SDK crashes on any `null` param (NPE in `JsonConvertUtils.collectionToJson`). Never bind empty strings — build the SQL without that condition (see `CustomerRepository.findDuplicate`) — and keep all DB calls in `AppAmbitDbService`, which rewrites null params to a literal `NULL` (`inlineNulls`).
- **Native SDK sources** are available as additional working dirs for debugging SDK behavior: `../../appambit-sdk-android` and `../../appambit-sdk-ios/AppAmbitSdk/Sources`. The Flutter plugin wraps these.
- **Cloud functions** (`cloud_functions/<name>/index.js`): ES module exporting `async function handler(ctx)`; read request via `ctx.req` (e.g. `ctx.req.query`), return `{ status, headers, body }`. Deployed via the AppAmbit MCP (`create` → `deploy` → `activate` → `set-trigger`); the function name is snake_cased (`invoice_test`) while the HTTP trigger slug can keep dashes (`invoice-test`).
- **AppAmbit API gotchas**: real REST host is `https://appambit.com/api` (the `api.appambit.com` in docs doesn't resolve); CMS is `https://cms.appambit.com/api/v1`. HTTP-triggered functions (`/api/fn/{slug}`) require a consumer Bearer token and sit behind AWS WAF, which challenges plain `curl` — they can't be meaningfully tested from the terminal. `POST /api/consumer` requires an undocumented `app_version` field.
- Bundle IDs are still Flutter defaults (`com.example.quoteGeneratorApp` on iOS, `com.example.quote_generator_app` on Android).

## 7. AppAmbit — Mobile Backend & Analytics MCP

This project is instrumented with AppAmbit, a mobile backend + analytics platform:
crash/error monitoring, sessions & events, remote config, push notifications, a
managed CMS, a managed per-app SQLite database (DBaaS), and serverless Cloud Code
functions. The AppAmbit MCP server (server name: `appambit`) is configured and available.

**Always use AppAmbit MCP tools instead of querying the database directly when:**

- **Crash / error investigation** — Use `list-crashes-tool` to list recent crash groups
  with occurrence counts and affected users. Follow up with `query-sessions-tool` to
  inspect the sessions where crashes occurred.

- **Event analysis / session timeline** — Use `query-sessions-tool` with `start_date` /
  `end_date` filters to retrieve daily session metrics, crash-free rates, average
  durations, and spot regressions after a release.

- **SDK / integration health** — Use `verify-sdk-integration-tool` to confirm the SDK is
  active, or `debug-integration-tool` for a full diagnostic when the SDK appears silent.
  Use `get-sdk-docs-tool` to look up documentation and available snippet titles for a
  given platform and stack.

- **SDK setup code** — Use `get-integration-snippet-tool` to generate ready-to-paste
  SDK initialisation code for a specific app, platform, and stack.

- **Push notifications** — Use `send-push-notification-tool` to send a push notification
  to all consumers or a specific consumer. Confirm with the user before sending.

- **Remote config** — Use `list-app-configs-tool` to read current values and
  `update-app-config-tool` to push a change. Never edit config flags directly in the DB.

- **CMS content** — Use `list-content-types-tool` to discover schemas and verify setup
  (check `is_published: true` for each type — unpublished types are invisible to the
  mobile SDK). `query-content-tool` returns published entries with full query support:
  keyword `search` across all entry fields, `sort` by `published_at` / `created_at` /
  `updated_at` with `order` asc|desc, and pagination (`page` from 1, `per_page` default 10
  / max 50) — use these instead of fetching everything and filtering client-side. Use `get-content-entry-tool`
  to fetch a single entry by UUID, `create-content-type-tool` to define new schemas (always
  published immediately and linked to the app), and `create-content-entry-tool` to add
  content. (CMS query is keyword-search + date-sort + paginate; for arbitrary field-level
  WHERE filtering, store that data in the app database instead.) After creating content
  types, always call `list-content-types-tool` to assert `is_published: true` and confirm
  the app link is in place before telling the user the CMS is ready.

- **App database (DBaaS)** — Each app can be linked to its own managed SQLite database.
  Read: `list-databases-tool` (discover team databases and which apps are linked),
  `list-database-tables-tool` (inspect schema), `query-database-tool` (SELECT only,
  LIMIT 100 auto-applied). Write: `create-database-tool` (provision a database, optionally
  linking an app in the same call), `link-database-tool` (attach/detach an app), and
  `execute-database-statement-tool` (INSERT/UPDATE/DELETE plus full schema DDL — tables,
  indexes incl. UNIQUE, views, triggers). Batch statements in one call; irreversible
  DROP/DELETE require `confirm=true`. Rows read/written are metered against the plan.
  When writing the mobile app's data-access code, prefer the AppAmbit SDK's fluent
  database API (query builder) over hand-written raw SQL strings.

- **Cloud Code (serverless functions)** — Start with `get-cloud-function-docs-tool` for the
  handler signature and `ctx` contract (a handler takes ONE `ctx` argument), so the assistant
  writes correct code without probing the runtime. Read: `list-cloud-functions-tool`,
  `get-cloud-function-tool`, `get-cloud-function-source-tool` (deployed source),
  `get-cloud-function-logs-tool`. Lifecycle (write):
  `create-cloud-function-tool` → `deploy-cloud-function-version-tool` (builds
  asynchronously) → `activate-cloud-function-version-tool` (make a ready version live) →
  `run-cloud-function-tool` (invoke). Configure with `set-cloud-function-env-tool`
  (env/secrets) and `set-cloud-function-trigger-tool` (http/event/manual). Running is
  plan-gated and metered.

- **Billing / plan debugging** — Use `get-billing-status-tool` to read the plan, enabled
  feature flags, plan limits, and current metered usage. Reach for it first whenever a
  feature seems disabled or a meter looks wrong.

**Choosing the right surface** — decide by who authors the data and how it changes:

- **CMS** — editorial, schema-structured content authored by your team and read by many:
  trail guides, blog posts, FAQs, onboarding screens, announcements. Validated against a
  schema, published, and cached for the SDK; read-mostly.
  Example: "publish trail guides with title / summary / region / difficulty" → a
  `trail_guide` content type + entries.

- **App database (DBaaS)** — per-user / transactional data the end user creates and mutates
  at runtime: favorites, saved routes, comments, check-ins, sync state. Arbitrary SQL,
  relations, indexes; metered by rows.
  Example: "let users save and un-save favorite trails" → a `user_favorites` table written
  via execute-database-statement-tool.

  Rule of thumb: editor-authored + read-mostly → CMS; user-generated + read/write → DB.
  (e.g. the trail *guide* is CMS; a user's *favorite* of that trail is DB.)

- **Remote config** — small operational flags/values that change app behavior without a
  release: feature toggles, thresholds, kill switches. Not for content or records.
  Example: "enable the new map UI for app version >= 2.1" → an app config entry.

- **Cloud Code** — server-side logic or secrets that must not live on-device: webhooks,
  scheduled jobs, calling third-party APIs with secret keys, aggregations.
  Example: "nightly recompute of trail popularity" → a function with an event/cron trigger.

**Bulk creation:** when creating more than one content type, entry, function, or SQL
statement, pass the array form in a single call rather than calling the tool repeatedly —
the create tools return per-item results so partial failures are visible.

**Workflow:**
1. Call `get-started-tool` first — it returns the capability map, conventions, and a live snapshot of your apps (with linked-database status) and plan.
2. Use the `app_key` it returns for every subsequent tool call (or call `list-apps-tool` to re-list).
3. Prefer AppAmbit tools over raw SQL for any analytics, crash, event, CMS, or database question.

## 8. Coding conventions

- Naming: `*_view.dart`, `*_viewmodel.dart`, `*_repository.dart`, `*_model.dart` (or the plain entity name in `models/`). Classes `QuoteEditorView`, `QuoteEditorViewModel`, `QuoteEditorState`.
- Prefer `@riverpod` code generation over hand-written providers; `keepAlive: true` only for repositories/services and the router.
- UI must use `core/theme` tokens and `core/widgets` components — no hard-coded colors, font sizes or paddings in features.
- Strings in English (PRD: English first); keep them in one place per feature for later localization.
- `flutter analyze` must pass with zero warnings before finishing a task.

## 9. Testing

- **ViewModels:** unit tests with `ProviderContainer(overrides: [quoteRepositoryProvider.overrideWithValue(FakeQuoteRepository())])`.
- **Repositories:** tests against fake `core/services` (no real AppAmbit calls in tests).
- **Money & validators:** pure unit tests (`core/utils`), including the PRD sample (subtotal $650.50 · GET 4.5% $29.27 · total $679.77).
- **Views:** widget tests for key screens (Home list, Editor totals, Preview buttons enabled/disabled).
- Tests mirror `lib/`: `test/features/quotes/viewmodels/quote_editor_viewmodel_test.dart`.

## 10. Before you finish a task

1. The change matches **PRD.md** (functionality) and **DESIGN.md** (UI).
2. The code sits in the right layer and folder (§5).
3. `flutter analyze` and `flutter test` pass; `build_runner` output is up to date.
