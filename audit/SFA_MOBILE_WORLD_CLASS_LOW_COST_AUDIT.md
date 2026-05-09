# SFA Mobile World-Class Low-Cost Audit

## 1. Executive Verdict

Direct verdict:

| Question | Verdict |
|---|---|
| Is the app demo-ready? | Yes, for a guided product demo. The core SFA journey exists end to end. |
| Is the app enterprise-grade enough? | Not yet. It feels like a serious prototype, but the transaction data foundation is not enterprise-grade. |
| Is the app structurally correct? | Mostly yes. Home Menu and Store Page Menu are separated, Store Page is guarded, and state is centralized. |
| Is the app easy enough for salesman? | Partly. Basic flows are workable; Planogram and product transaction flows need simplification and UOM correctness. |
| Is the app cheap enough to build and maintain? | Yes, the architecture is lean and dependency-light. The risk is duplicated feature-specific line item logic. |
| Is the app safe to continue to UI polish? | No. UI polish should pause until Product + UOM + Qty and sync audit foundations are corrected. |
| Should we pause and fix foundation first? | Yes. Fix foundation first, then polish. |

Scores:

| Dimension | Score 1-5 | Rationale |
|---|---:|---|
| Overall maturity score | 3 | Acceptable lean demo, not yet strong low-cost enterprise prototype. |
| Product maturity score | 3 | Good SFA coverage, but missing core FMCG UOM behavior. |
| UX maturity score | 3 | Clear enough, but several forms are too heavy or ambiguous. |
| Data model maturity score | 2 | Product, sync, and photo models are still shallow. |
| Technical architecture score | 4 | Lean, feature-based, centralized mock state, minimal dependencies. |
| SFA industry correctness score | 3 | Visit/store/activity structure is right; commercial line model is wrong. |
| Demo readiness score | 4 | Can demo main flow if weaknesses are avoided or explained. |
| Low-cost maintainability score | 4 | Cheap stack and simple architecture, but line item duplication must be stopped. |
| Performance readiness score | 4 | Lightweight Flutter app with small mock data and no heavy services. |

The app follows the spirit of "Murah tapi bukan murahan" better than many prototypes: it avoids admin bloat, microservices thinking, real backend dependency, map SDK dependency, and expensive visual tricks. But the next step must be domain correctness, not more screens.

## 2. Lean World-Class Principle Check

| Principle | Current Condition | Gap | Severity | Recommendation |
|---|---|---|---|---|
| Simple architecture | Feature folders, `MockSfaRepository`, `ChangeNotifier`, `AppStateScope`, `go_router`. | Good lean base. | LOW | Keep this architecture for prototype. |
| No unnecessary dependencies | `pubspec.yaml` only uses Flutter and `go_router`, plus Flutter test/lints. | Excellent low-cost discipline. | LOW | Avoid adding packages unless a real need appears. |
| No backend dependency for prototype | Fully local mock state. | Good. | LOW | Keep backend out until data shape is stable. |
| Offline-first local state | Submitted activities become local records and SyncItems. | Sync history is shallow. | MEDIUM | Add lightweight sync timestamps/events later. |
| Centralized mock state | Business state is centralized in `MockSfaRepository`. | Temporary form state is scattered, acceptable for forms. | LOW | Keep central business state; avoid global form state. |
| Reusable models | Core models exist. | No shared ProductLineItem; UOM missing. | CRITICAL | Add UOM and shared line item foundation. |
| Reusable line item pattern | Not present. Sales, return, stock, and planogram each have their own row shape. | Duplicated line behavior. | HIGH | Create a small shared line item value object. |
| Minimal typing for salesman | Most fields use selectors; notes are optional. | Product line UOM missing; competitor quick add can be slow. | MEDIUM | Use defaults and searchable selectors. |
| Low-end Android friendly | No heavy packages, no maps, no real camera/images, small lists. | Long forms may still feel heavy. | LOW | Keep lists simple and avoid expensive UI effects. |
| Fast navigation | `go_router` routes are direct and guarded. | Some history pages add depth, but acceptable. | LOW | Keep route tree flat. |
| Clear status | Status chips exist; sync counts visible. | Sync timeline/status detail incomplete. | MEDIUM | Add simple sync timeline later. |
| Easy future backend integration | Models and repository create a seam for backend later. | Models are not backend-ready because UOM/sync metadata missing. | HIGH | Stabilize models before API design. |
| No overengineered microservice thinking | No backend or microservice assumptions in app. | Good. | LOW | Keep future backend as modular monolith. |
| No admin complexity inside mobile | No admin modules found. | Good. | LOW | Continue blocking admin scope from mobile. |
| Professional UI without expensive complexity | Cards, chips, forms, and menus are consistent enough. | Some screens are dense; Planogram is heavy. | MEDIUM | Use simple layout hardening, not custom graphics. |

## 3. Current App Map

Current relevant folder structure:

```text
lib/
  app.dart
  main.dart
  config/app_config.dart
  core/
    router/app_router.dart
    theme/app_theme.dart
    utils/
    widgets/
  data/
    dummy/dummy_data.dart
    models/
    repositories/
  features/
    auth/
    check_in/
    competitor_activity/
    home/
    planogram/
    promo_check/
    return_order/
    sales_order/
    stock_check/
    store/
    store_info/
    sync/
    visit/
    visit_completion/
  shared/widgets/app_logo.dart
```

Main files:

| Area | Main Files |
|---|---|
| App entry | `lib/main.dart`, `lib/app.dart` |
| Routing | `lib/core/router/app_router.dart` |
| Theme | `lib/core/theme/app_theme.dart` |
| Shared UI | `lib/core/widgets/menu_tile.dart`, `status_chip.dart`, `summary_card.dart` |
| Mock state | `lib/data/repositories/mock_sfa_repository.dart`, `app_state_scope.dart` |
| Dummy data | `lib/data/dummy/dummy_data.dart` |
| Models | `lib/data/models/*.dart` |

Routing map:

| Route | Page |
|---|---|
| `/login` | `LoginPage` |
| `/home` | `HomePage` |
| `/visit` | `VisitPage` |
| `/visit/add-call-plan` | `CustomerSelectionPage` |
| `/check-in/:callPlanId` | `CheckInPage` |
| `/store` | `StorePage` |
| `/store/sales-order` | `SalesOrderMenuPage` |
| `/store/sales-order/regular` | `OrderEntryPage(regular)` |
| `/store/sales-order/canvas` | `OrderEntryPage(canvas)` |
| `/sales-orders` | `SalesOrderListPage` |
| `/sales-orders/:orderId` | `SalesOrderDetailPage` |
| `/sales-orders/:orderId/success` | `OrderSuccessPage` |
| `/store/return` | `ReturnMenuPage` |
| `/store/return/order` | `ReturnOrderPage` |
| `/store/return/swap` | `ReturnSwapOrderPage` |
| `/returns` | `ReturnListPage` |
| `/returns/:returnOrderId` | `ReturnDetailPage` |
| `/returns/:returnOrderId/success` | `ReturnSuccessPage` |
| `/store/promo-check` | `PromoCheckPage` |
| `/promo-checks` | `PromoCheckListPage` |
| `/promo-checks/:promoCheckId` | `PromoCheckDetailPage` |
| `/store/competitor-activity` | `CompetitorActivityPage` |
| `/competitor-activities` | `CompetitorActivityListPage` |
| `/competitor-activities/:activityId` | `CompetitorActivityDetailPage` |
| `/store/planogram-check` | `PlanogramCheckPage` |
| `/planogram-checks` | `PlanogramCheckListPage` |
| `/planogram-checks/:checkId` | `PlanogramCheckDetailPage` |
| `/store/stock-check` | `StockCheckPage` |
| `/stock-checks` | `StockCheckListPage` |
| `/stock-checks/:checkId` | `StockCheckDetailPage` |
| `/store/product-price-list` | `ProductPriceListPage` |
| `/store/product-price-list/:productId` | `ProductDetailPage` |
| `/store/order-history` | `OrderHistoryPage` |
| `/store/order-history/:orderId` | `OrderHistoryDetailPage` |
| `/store/customer-info` | `CustomerInfoPage` |
| `/store/visit-notes` | `VisitNotesPage` |
| `/store/store-photo` | `StorePhotoPage` |
| `/store/end-visit` | `EndVisitPage` |
| `/sync-center` | `SyncCenterPage` |
| `/sync-center/:syncItemId` | `SyncDetailPage` |

Active pages:
- All main phase pages exist and are route-connected.

Pages not connected to routes:
- No obvious unconnected `*Page` classes were found.
- `shared/widgets/app_logo.dart` appears unused.
- Home `Customer` and `Profile` menu items are placeholders, not routes.

Duplicate pages:
- No problematic duplicate route/page implementation was found.

State and data:
- `MockSfaRepository` stores active user, call plans, visits, orders, returns, promo checks, competitor activities, planogram checks, stock checks, visit notes, store photos, SyncItems, local competitor brands/products, and canvas stock.
- `SyncItem` is stored in `_syncItems` inside `MockSfaRepository`.
- Business state is centralized; form state remains local inside pages.

## 4. Feature Inventory

| Feature | Current Status | Route/Page | Data Model | SyncItem Created? | Main Issue | Maturity Score | Cost Risk |
|---|---|---|---|---|---|---:|---|
| Login | Implemented with company code | `/login` | `UserContext` | No, not needed | Session-only company context | 4 | Low |
| Home | Implemented | `/home` | `HomeDashboardSnapshot` | Reads SyncItems | Customer/Profile placeholders | 4 | Low |
| Visit / Call Plan | Implemented | `/visit` | `CallPlan` | No, plan creation local only | No visit objective/time window | 4 | Low |
| Add Call Plan | Implemented | `/visit/add-call-plan` | `Customer`, `CallPlan` | No | Simple only | 4 | Low |
| Check-in | Implemented | `/check-in/:callPlanId` | `Visit` | Yes | Simulated GPS/photo only | 4 | Low |
| Store Page | Implemented and guarded | `/store` | `Visit`, `Customer` | Reads visit SyncItems | Dense menu | 4 | Low |
| Sales Order | Implemented | `/store/sales-order/regular` | `SalesOrder`, `SalesOrderItem` | Yes | No UOM | 2 | High |
| Canvas Order | Implemented | `/store/sales-order/canvas` | `SalesOrder`, canvas stock map | Yes | Product-level stock, no UOM | 2 | High |
| Return Order | Implemented | `/store/return/order` | `ReturnOrder`, `ReturnOrderItem` | Yes | No UOM/photo metadata | 3 | Medium |
| Return Swap Order | Implemented | `/store/return/swap` | `ReturnOrder` | Yes | No UOM | 3 | Medium |
| Promo Check | Implemented | `/store/promo-check` | `PromoCheck` | Yes | Photo boolean only | 4 | Low |
| Competitor Activity | Implemented with selectors | `/store/competitor-activity` | `CompetitorActivity`, `Brand`, `Product` | Yes | No pack/UOM for price | 4 | Low |
| Planogram / Shelf Check | Implemented rich audit | `/store/planogram-check` | `PlanogramCheck` | Yes | Too heavy; no UOM/photo metadata | 3 | Medium |
| Stock Check | Implemented | `/store/stock-check` | `StockCheck` | Yes | No UOM | 2 | High |
| Product & Price List | Implemented | `/store/product-price-list` | `Product` | No | No UOM/price per UOM | 3 | Medium |
| Order History | Implemented | `/store/order-history` | `OrderHistory`, `SalesOrderItem` | No | Inherits no-UOM issue | 3 | Medium |
| Customer Info | Implemented view-only | `/store/customer-info` | `Customer` | No | Shallow customer master | 4 | Low |
| Visit Notes | Implemented | `/store/visit-notes` | `VisitNote` | Yes | Good enough | 4 | Low |
| Store Photo | Implemented | `/store/store-photo` | `StorePhoto` | Yes | Photo boolean only | 3 | Medium |
| End Visit | Implemented | `/store/end-visit` | `Visit`, `CallPlan` | Yes | Summary only; no checkout GPS/photo | 4 | Low |
| Sync Center | Implemented | `/sync-center` | `SyncItem` | N/A | No event timeline/attempt count | 3 | Medium |

## 5. International SFA Benchmark Audit with Low-Cost Lens

| Area | Current App | Expected International SFA Behavior | Gap | Severity | Low-Cost Recommendation | Expensive Overengineering to Avoid |
|---|---|---|---|---|---|---|
| Company code login context | Text input validates `demo-distributor`, `demo`, `shela-demo`. | Resolve company/tenant context before login. | Prototype-only lookup. | MEDIUM | Keep static resolver for prototype; later REST lookup. | SSO, tenant admin setup in mobile. |
| Branch/employee/customer context | Active user has tenant/company/branch/employee and branch customers. | Branch-scoped data visibility. | No employee/customer master lifecycle. | LOW | Keep dummy scoped data. | User/employee management screens. |
| Visit planning | Today plans and add customer. | Planned route, sequence, objective, window. | No objective/window. | MEDIUM | Add optional visit objective later. | Territory optimization now. |
| GPS check-in/check-out | Simulated GPS/photo/fake GPS. | GPS accuracy, distance, timestamp, mock-location detection. | No real metadata. | MEDIUM | Add model fields before integration. | Map SDK or background geolocation now. |
| Offline-first behavior | Local records and SyncItems. | Durable local storage and retryable queue. | In-memory only. | MEDIUM | Keep in-memory prototype; add simple persistence later. | Full offline database migration too early. |
| UOM-based order taking | Missing. | Product + UOM + Qty + price per UOM. | Critical commercial gap. | CRITICAL | Add UOM and shared line item. | Full pricing engine. |
| Pricing and discount visibility | Simple product price and dummy discount. | Price list, promo/discount rules, line totals. | No UOM price or price group. | HIGH | Show dummy UOM price; keep discount simple. | Complex trade promotion engine. |
| Return management | Product qty, reason, photo. | Product + UOM + Qty + condition/reason/photo. | UOM missing. | HIGH | Reuse UOM line item. | Return approval workflow now. |
| Promo execution | Good simple compliance/photo flow. | Program audit with photo and compliance reason. | Photo metadata shallow. | MEDIUM | Add photo metadata later. | Promo claim engine. |
| Competitor intelligence | Brand/product selectors and quick add. | Master-data based observation with photo and price/pack context. | No observed UOM/pack. | MEDIUM | Add optional observed pack/UOM. | Competitor catalog admin module in mobile. |
| Planogram and shelf execution | Rich audit page. | Fast basic audit plus advanced details. | Too heavy for salesman. | HIGH | Split Basic/Advanced Mode. | AI planogram recognition. |
| Stock check | Product qty/status rows. | Product + UOM + Qty + stock status. | UOM missing. | HIGH | Add UOM selector per row. | Full inventory engine. |
| Product catalog | Product list/detail. | Price, UOM, category, promo, stock availability. | No UOM. | MEDIUM | Display default/available UOM. | Product management module. |
| Customer profile | View-only customer info. | Customer context, credit, last order, status. | Good for demo, shallow for real. | LOW | Keep view-only. | Customer edit/admin. |
| Order history | Local/historical orders. | Customer order history with line UOM and status. | No UOM in history lines. | MEDIUM | Display line UOM after model fix. | ERP invoice/payment detail. |
| Sync queue and traceability | Queue, filters, retry, fail simulation. | Attempt count, event timeline, failure reason, server acknowledgment. | Timeline missing. | HIGH | Add lightweight sync event fields. | Distributed event sourcing. |
| Field usability | Most pages use cards and bottom actions. | Few taps, low typing, clear next step. | Planogram and quick-add can be slow. | MEDIUM | Defaults, search, Basic Mode. | Heavy dashboard/charts. |
| Auditability | CreatedAt/status exist. | Who/when/where/photo/sync trace. | Photo/GPS/sync metadata shallow. | HIGH | Add metadata fields cheaply. | Supervisor audit platform now. |
| Operational control | No admin complexity. | Mobile focuses on execution, web handles admin later. | Correct boundary. | LOW | Maintain boundary. | Admin screens inside mobile. |

## 6. Data Model Audit

| Model | File Location | Current Fields | Missing Fields | Normalization / Free Text Issue | Performance / Cost Concern | Recommended Improvement | Low-Cost Approach |
|---|---|---|---|---|---|---|---|
| UserContext | `lib/data/models/user_context.dart` | user/company/tenant/branch/role/app/companyCode | token/session metadata | Good enough | None | Keep lean | Static dummy context now |
| Customer | `lib/data/models/customer.dart` | id, branch, name, address, phone, last visit/order, GPS, type, status, credit dummy fields | customer code, channel, price group | Some fields are strings | Low | Add customer code/channel later | Dummy fields only |
| Branch | No model | Stored inside UserContext | Full Branch model | Not needed yet | Low | Defer | Keep branch context on user |
| Company/Tenant context | UserContext only | tenant/company ids/names/code | Resolver model | No admin needed | Low | Defer | Company code maps to dummy context |
| Brand | `lib/data/models/brand.dart` | id, name, brandType, status | category/owner/effective date | Good master data | Low | Keep | Local dummy master |
| Product | `lib/data/models/product.dart` | id, name, sku, brand, productType, category, price, canvasStock, isSellable | UOM, conversion, barcode, price per UOM | Good own/competitor split, but no UOM | High future refactor cost | Add ProductUom/default UOM | Minimal UOM fields first |
| UOM | Missing | None | all UOM fields | Critical missing model | Critical correction cost if delayed | Create `Uom` and `ProductUom` | PCS/BOX/CARTON dummy |
| ProductLineItem | Missing | None | product+uom+qty+baseQty | Each feature invents row shape | High duplication | Create shared value object | Small immutable model |
| CallPlan | `lib/data/models/call_plan.dart` | id, employee, customer, branch, date, sequence, status | objective/window/source | Good enough | Low | Add objective later | Optional string/enum |
| Visit | `lib/data/models/visit.dart` | id, callPlan, customer, employee, branch, status, checkInAt, lat/lng, photo, fakeGps, checkOutAt | accuracy, distance, photo id, checkout GPS | Photo boolean only | Low | Add metadata later | Add fields, no real GPS yet |
| SalesOrder | `lib/data/models/sales_order.dart` | header, items, subtotal, discount, grandTotal, syncStatus, createdAt | order status, remarks, UOM lines | Line missing UOM | High | Refactor item | Reuse ProductLineItem |
| SalesOrderItem | `lib/data/models/sales_order.dart` | productId/name/sku, quantity, price | UOM, baseQty, line discount | Critical | High | Add UOM fields | Default UOM first |
| ReturnOrder | `lib/data/models/return_order.dart` | header, items, returned/replacement item, reason, photo, sync | UOM, condition, photo id | Reason string/list in UI | Medium | UOM line fields | Reuse line item |
| PromoCheck | `lib/data/models/promo_check.dart` | promo id/name, visit/customer/employee, compliance, photo, notes, sync | photo id, reason | Good enough | Low | Add photo metadata later | Boolean now acceptable |
| CompetitorActivity | `lib/data/models/competitor_activity.dart` | brand/product ids/names, type, price, promo desc, photo, notes, sync | UOM/pack, photo id | Good selector model | Low | Add observed UOM/pack | Optional field |
| PlanogramCheck | `lib/data/models/planogram_check.dart` | before/after photo flags, shelf, own/competitor rows, analysis, action, compliance | UOM, photo ids, numeric shelf share | Good but heavy | Medium | Basic/Advanced Mode | Keep model, simplify UX |
| StockCheck | `lib/data/models/stock_check.dart` | product rows with qty/status, notes, sync | UOM, baseQty | Critical quantity ambiguity | High | Add UOM per row | Reuse line concept |
| StorePhoto | `lib/data/models/store_photo.dart` | type, captured bool, notes, sync | local path, GPS, timestamp metadata | Boolean only | Low | Add metadata later | Keep no binary storage |
| VisitNote | `lib/data/models/visit_note.dart` | result, notes, follow-up, sync | none critical | Good enough | Low | Keep | Enum + optional notes |
| SyncItem | `lib/data/models/sync_item.dart` | id, type, reference, title, desc, status, createdAt, syncedAt, error | queuedAt, syncingAt, attemptCount, sentAt, timeline | Status only | Medium | Extend or add SyncEvent | Lightweight timeline |
| SyncHistory / SyncEvent | Missing | None | all event fields | Missing audit trace | Medium | Add later | Simple list of events |

Specific Product + UOM + Qty answer:
- Not supported anywhere in current product transaction lines.
- This is the most important foundation gap.

## 7. Product, UOM, and Line Item Audit

Answers:

| Question | Answer |
|---|---|
| Does UOM model exist? | No. |
| Does Product have base UOM? | No. |
| Does Product have available UOM list? | No. |
| Does Product support price per UOM? | No. Price is product-level integer. |
| Does Product support stock per UOM? | No. Canvas stock is product-level integer. |
| Do transaction pages use Product + UOM + Qty? | No. They use Product + Qty. |
| Are order line items structured properly? | No, UOM/base quantity missing. |
| Are return line items structured properly? | No, UOM missing. |
| Are stock check rows structured properly? | No, UOM missing. |
| Are planogram product rows structured properly? | Partly. Facing count is present, but UOM/pack context is missing if quantity is interpreted beyond facings. |

Flow audit:

| Flow | Current Input | Expected Input | UOM Support? | Issue | Severity | Low-Cost Fix |
|---|---|---|---|---|---|---|
| Regular Order | Product + Qty | Product + UOM + Qty | No | Quantity ambiguous | CRITICAL | Add UOM selector/default per product |
| Canvas Order | Product + Qty, stock cap | Product + UOM + Qty, stock conversion | No | Canvas stock product-level only | CRITICAL | Store stock in base UOM; display selected UOM |
| Return Order | Product + return qty | Product + UOM + Qty + reason | No | Return quantity ambiguous | HIGH | Reuse UOM line item |
| Return Swap Order | Returned product/qty and replacement product/qty | Returned Product + UOM + Qty, Replacement Product + UOM + Qty | No | Swap units unclear | HIGH | Add UOM to both sides |
| Stock Check | Product + stock qty + status | Product + UOM + Qty + status | No | Stock count unclear | HIGH | Add UOM selector per row |
| Planogram Own Product Facing | Product + facing count + availability + placement | Product + facing count, optional UOM/pack if quantity captured | No | Facing can be okay, but pack context unclear | MEDIUM | Clarify facing as count; add optional pack/UOM later |
| Planogram Competitor Facing | Competitor brand/product + facing count | Competitor brand/product + facing count + optional pack/UOM | No | Competitor comparison lacks pack context | MEDIUM | Add optional observed pack/UOM |

Minimum acceptable low-cost prototype:
- Product selector.
- UOM selector.
- Qty input.
- Display selected UOM in the line item.
- Simple dummy price per selected UOM if available.
- Otherwise use base price but still capture UOM.

Avoid:
- Full pricing engine.
- Complex unit conversion engine.
- Warehouse stock integration.
- Multi-level packaging conversion beyond simple dummy conversion.
- Real inventory module.

## 8. Master Data vs Free Text Audit

| Object | Current Implementation | Correct Type MASTER_DATA/ENUM/FREE_TEXT | Risk If Free Text | Low-Cost Fix |
|---|---|---|---|---|
| Company Code | Text with allowed dummy values | MASTER_DATA/config lookup | Wrong company context | Keep local resolver |
| Customer | Dummy `Customer` master | MASTER_DATA | Duplicate outlets | Keep branch customer list |
| Product | Dummy `Product` master | MASTER_DATA | Dirty SKU/order data | Add UOM relationship |
| UOM | Missing | MASTER_DATA | Ambiguous quantities | Add dummy UOM |
| Brand | `Brand` model | MASTER_DATA | Duplicate brand names | Keep normalized duplicate check |
| Competitor Brand | Selector + quick add | MASTER_DATA | Bad competitor analytics | Add searchable selector |
| Competitor Product | Product master with competitor type | MASTER_DATA | Bad product intelligence | Keep Product Master approach |
| Promo Program | Dummy promo list | MASTER_DATA | Cannot audit programs | Keep local master |
| Return Reason | Static list/string | ENUM | Dirty return reasons | Keep enum/list |
| Visit Result | Enum | ENUM | Dirty visit outcome | Keep enum |
| Activity Type | Enum | ENUM | Dirty competitor report | Keep enum |
| Shelf Area | Enum | ENUM | Bad shelf analytics | Keep enum |
| Shelf Level | Enum | ENUM | Bad placement analytics | Keep enum |
| Placement Status | Enum | ENUM | Bad shelf compliance | Keep enum |
| Stock Status | Enum | ENUM | Bad stock reports | Keep enum |
| Main Issue | Enum | ENUM | Dirty issue reports | Keep enum |
| Recommended Action | Enum | ENUM | Bad follow-up reporting | Keep enum/auto-suggest |
| Action Taken | Enum | ENUM | Bad execution proof | Keep enum |
| Notes | Text fields | FREE_TEXT | Acceptable only for explanation | Keep optional |

Low-cost approach:
- Use local dummy master data.
- Use searchable selectors for long lists.
- Allow quick-add only where needed.
- Save quick-add locally.
- No approval workflow yet.
- No admin screen inside mobile.

## 9. Own Product vs Competitor Product Audit

| Area | Current | Expected | Gap | Severity | Low-Cost Fix | Overengineering to Avoid |
|---|---|---|---|---|---|---|
| Product type | `ProductType.ownProduct` and `competitorProduct` exist | Product type required | Good | LOW | Keep | Separate competitor module too early |
| Sellable flag | `isSellable` exists | Competitor products not sellable | Good | LOW | Keep repository guard | Complex permission engine |
| Competitor products in master | Dummy competitor products exist | Competitor Product in Product Master | Good | LOW | Keep | Admin catalog UI in mobile |
| Sales Order filter | Uses `getOwnSellableProducts()` and submit guard | Only own sellable products | Good | LOW | Keep guard after UOM refactor | Trust UI only |
| Competitor Activity fields | Stores brand/product IDs and names | IDs from master selectors | Good | LOW | Improve labels/search | Raw text fallback |
| Add competitor brand/product | Exists with duplicate name checks | Quick add local | Good prototype | MEDIUM | Search first, quick add second | Approval workflow now |
| Product & Price List | Shows own product catalog | Own sellable products primarily | Good | LOW | Keep separate from competitor catalog | Mixing competitor products in order catalog |

## 10. Salesman Usability Audit

| Flow | Ease Score 1-5 | Main Friction | Time Risk | Low-Cost Simplification |
|---|---:|---|---|---|
| Login | 4 | Three fields | Low | Remember company code in session |
| Home | 4 | Customer/Profile placeholders | Low | Keep summary, make placeholders less prominent or implement read-only |
| Visit / Call Plan | 4 | No route/time objective | Low | Keep simple list and search |
| Check-in | 4 | Simulated photo step | Low | Keep automatic location and checklist |
| Store Page | 4 | Many menu items | Medium | Keep grouped sections and prominent primary actions |
| Sales Order | 3 | No UOM | High | Default UOM plus stepper quantity |
| Return | 3 | No UOM | High | Reuse order line component |
| Promo Check | 4 | Mostly fine | Low | Keep short |
| Competitor Activity | 3 | Quick add can slow field work | Medium | Searchable selector and minimal quick add |
| Planogram / Shelf Check | 2 | Too many sections for salesman | High | Basic Mode default |
| Stock Check | 3 | No UOM, row entry effort | High | Product + UOM + qty row with defaults |
| End Visit | 4 | Warning only | Low | Keep final action obvious |
| Sync Center | 3 | Technical filters/details | Medium | Salesman-friendly default view |

Answers:
- Too complicated: Planogram / Shelf Check.
- Too shallow: Product transaction lines, SyncItem audit trail, photo metadata.
- Feels amateur if exposed: any order/stock quantity without UOM; boolean-only photo evidence in technical reviews.
- Acceptable for demo: Login, Home, Visit, Check-in, Store Page, Promo Check, Customer Info, End Visit, basic Sync Center.
- Needs redesign before serious demo: Sales/Return/Stock UOM, Planogram Basic Mode.

## 11. UI Professionalism / "Murah Tapi Gak Murahan" Audit

| Screen | Professionalism Score 1-5 | What Feels Cheap / Norak | Low-Cost Improvement |
|---|---:|---|---|
| Login | 4 | Prototype validation only | Keep clean branding; remember company code |
| Home | 4 | Placeholder Customer/Profile menu | Add read-only pages or mark clearly later |
| Visit | 4 | Simple call plan | Add better empty/action hierarchy if needed |
| Check-in | 4 | Simulated photo/GPS acceptable | Add metadata labels without real services |
| Store Page | 4 | Many menu tiles | Keep sections; reduce visual density where possible |
| Sales Order | 3 | No UOM makes it feel toy-like to FMCG users | Add UOM display and line row consistency |
| Return | 3 | No UOM/photo metadata | Add UOM and clearer evidence card |
| Promo Check | 4 | Good enough | Keep concise |
| Competitor Activity | 4 | Some validation wording still can feel off | Use "select" wording and searchable selectors |
| Planogram | 3 | Too much form density | Basic Mode and cleaner sections |
| Stock Check | 3 | No UOM | Add UOM, keep rows compact |
| Sync Center | 3 | Debug "Simulate Failed Sync" visible in normal flow | Hide debug action or label as demo tool |

Cheap UI improvements:
- Better spacing.
- Consistent card patterns.
- Reusable status chips.
- Better empty states.
- Clearer section headers.
- Fewer colors.
- Fewer random icons.
- Better button hierarchy.
- Standardized form layout.

Avoid:
- Heavy animation.
- Complex graphics.
- Expensive custom UI.
- Overdesigned dashboard.
- Too many charts.
- Unnecessary map SDK.
- Unnecessary realtime features.

## 12. Performance and Low-End Android Audit

| Area | Current Risk | Performance Impact | Low-Cost Fix |
|---|---|---|---|
| Dependencies | Very low; only `go_router` beyond Flutter | Good for low-end devices | Keep dependency budget strict |
| Local state | Central repository notifies whole app | Fine for small prototype; can rebuild more than needed later | Keep data small; split only if needed |
| Large widget rebuilds | `InheritedNotifier` can rebuild subscribed pages | Low with current data | Use scoped selectors later only if needed |
| List rendering | `ListView` and small lists | Low | Use `ListView.builder` if datasets grow |
| Forms | Planogram form is long | Medium UX/performance perception | Basic Mode, collapsible sections |
| Images/assets | No real image binaries | Good | Keep photo as metadata until storage strategy |
| Route complexity | Moderate number of routes | Low | Keep route tree flat |
| Search optimization | In-memory filtering | Fine for dummy data | Debounce only if lists grow |
| Memory risk | All state in memory | Fine for prototype | Add persistence later, no binary blobs |
| Hot path screens | Home, Visit, Store, Order are simple | Good | Avoid charts/maps/animation |

Low-cost performance guidance:
- Use simple lists.
- Avoid heavy animation.
- Keep state centralized but lightweight.
- Avoid unnecessary dependencies.
- Lazy render long lists if needed.
- Avoid real map SDK for prototype.
- Use simulated GPS.
- Keep image/photo as metadata placeholder.
- Avoid storing large binary assets in state.
- Keep mock data small but structured.

## 13. Cost Architecture Audit

| Concern | Current App / Direction | Cost Risk | Low-Cost Recommendation |
|---|---|---|---|
| Backend assumption | None required | Low | Keep local prototype until model stable |
| Sync design | Simple local queue | Medium if expanded badly | Add simple event/timestamp model |
| Poor internet support | Local-first simulation | Low | Later use local persistence and retry |
| Backend architecture later | Not specified | Medium | Use modular monolith, not microservices |
| External dependencies | Minimal | Low | Maintain package discipline |
| Third-party services | None | Low | Avoid maps/camera uploads until needed |
| Realtime | None | Low | Do not add realtime sync now |
| Map/routing | None | Low | Avoid until routing/territory is real requirement |
| AI/OCR/image recognition | None | Low | Do not add before manual planogram is correct |
| Admin scope | Absent | Low | Keep admin on web platform later |

Preferred future architecture:
- Modular monolith backend.
- PostgreSQL.
- Simple REST API.
- Offline queue from mobile.
- Cheap object storage later for photos.
- No microservices until revenue/scale requires.
- No realtime unless needed.
- No map SDK unless routing/territory is required.
- No AI planogram until manual flow is correct.

## 14. Planogram / Retail Execution Audit

Current implementation:
- Before photo exists.
- After photo exists and is required if action taken is not `NO_ACTION_TAKEN`.
- Shelf area exists.
- Shelf level exists.
- Own product rows exist with product, facing count, availability, placement.
- Missing SKU summary exists.
- Competitor shelf presence exists.
- Share of shelf estimate exists.
- Main issue exists.
- Recommended action exists.
- Merchandiser action taken exists.
- Compliance status exists.
- SyncItem is created.

What is missing:
- UOM/pack context where quantity interpretation matters.
- Photo metadata beyond boolean.
- Basic/Advanced split.
- Faster default path for no-issue shelves.

Is it too shallow?
- No. It is no longer shallow.

Is it too complex?
- Yes for normal salesman usage. It is closer to merchandiser/supervisor audit.

Is it easy for salesman?
- Not enough. It has too many required decisions for a fast outlet visit.

Low-cost version:

| Category | Fields |
|---|---|
| Basic Mode fields | Before photo, own product rows, facing count, missing SKU auto-summary, main issue, action taken, after photo if action taken, compliance status, optional notes |
| Advanced Mode fields | Shelf area, shelf level, competitor facing, share of shelf, recommended action, detailed notes |
| Mandatory fields | Before photo, at least one own product row, main issue, action taken, compliance status, after photo if action taken |
| Optional fields | Shelf level, competitor rows, share estimate, detailed notes |
| Auto-derived fields | Missing SKU summary, suggested recommended action, suggested compliance |
| Defer | AI detection, shelf measurement, supervisor scoring |

Avoid for now:
- AI detection.
- Image recognition.
- Automatic shelf measurement.
- Complex planogram template builder.
- Supervisor scoring engine.

## 15. Competitor Activity Audit

Current fields:
- Customer context.
- Competitor Brand selector.
- Competitor Product selector.
- Activity Type dropdown.
- Optional price.
- Promo description.
- Photo capture simulation.
- Notes.

Current UI:
- Uses dropdown selectors.
- Provides `+ Add New Competitor Brand`.
- Provides `+ Add New Competitor Product`.
- Requires active visit.

Current data model:
- Stores competitor brand id/name.
- Stores competitor product id/name.
- Stores enum activity type.
- Stores optional price, promo description, photo boolean, notes, sync status.

Current sync behavior:
- `submitCompetitorActivity` creates `SyncItem` type `COMPETITOR_ACTIVITY` with status `QUEUED`.

Issues:
- No observed UOM/pack size for competitor price.
- Quick-add may interrupt field flow if not search-first.
- Photo is boolean only.

Industry gap:
- Competitor observation should be analyzable by brand, product, activity, price, pack/UOM, outlet, and time.

Usability gap:
- If product does not exist, creating it inside the visit can slow the salesman.

Low-cost fix:
- Searchable local selectors.
- Quick-add bottom sheet with minimum fields.
- Add optional observed pack/UOM.
- Keep notes free text only.

Mandatory:
- Competitor brand selector.
- Competitor product selector.
- Activity type.
- Photo.

Optional:
- Price.
- Promo description.
- Notes.
- Category for quick-added product.

Defer:
- Approval workflow.
- Full product management.
- Image recognition.
- Competitor catalog admin inside mobile.

## 16. Sync Architecture Audit

| Question | Current Answer |
|---|---|
| Is SyncItem centralized? | Yes, in `MockSfaRepository._syncItems`. |
| Does every submitted activity create SyncItem? | Yes for the requested activity list. |
| Does SyncItem include created_on_device? | Only generic `createdAt`. |
| Does SyncItem include queued_at? | No. |
| Does SyncItem include syncing_at? | No. |
| Does SyncItem include sent_to_server_at / synced_at? | `syncedAt` only. |
| Does SyncItem include attempt_count? | No. |
| Does SyncItem include last_attempt_at? | No. |
| Does SyncItem include error_message? | Yes. |
| Does SyncItem have event timeline? | No. |
| Does Home only show summary? | Mostly yes: pending, failed, last sync, summary cards. |
| Does Sync Center show detailed logs? | Partially: list/detail, no full timeline. |
| Can failed sync be retried? | Yes, prototype retry. |
| Can user understand what has not been sent? | Yes at basic status level. |

Matrix:

| Feature | Creates SyncItem? | Type | Missing Timestamp? | Missing History? | Issue | Low-Cost Fix |
|---|---|---|---|---|---|---|
| Visit Check-in | Yes | `VISIT_CHECK_IN` | Yes | Yes | No queued/attempt timeline | Add SyncEvent fields |
| Visit Check-out | Yes | `VISIT_CHECK_OUT` | Yes | Yes | Same | Add SyncEvent fields |
| Regular Order | Yes | `REGULAR_ORDER` | Yes | Yes | Also no UOM | UOM first, sync timeline later |
| Canvas Order | Yes | `CANVAS_ORDER` | Yes | Yes | Also no UOM/base stock | UOM first |
| Return Order | Yes | `RETURN_ORDER` | Yes | Yes | No UOM | UOM first |
| Return Swap Order | Yes | `RETURN_SWAP_ORDER` | Yes | Yes | No UOM | UOM first |
| Promo Check | Yes | `PROMO_CHECK` | Yes | Yes | Photo boolean | Add metadata later |
| Competitor Activity | Yes | `COMPETITOR_ACTIVITY` | Yes | Yes | No pack/UOM | Add observed UOM |
| Planogram Check | Yes | `PLANOGRAM_CHECK` | Yes | Yes | Heavy flow/photo boolean | Basic Mode |
| Stock Check | Yes | `STOCK_CHECK` | Yes | Yes | No UOM | UOM first |
| Visit Note | Yes | `VISIT_NOTE` | Yes | Yes | Good enough | Add sync timeline |
| Store Photo | Yes | `STORE_PHOTO` | Yes | Yes | Photo metadata missing | Add metadata later |

Low-cost event timeline:
- `CREATED_ON_DEVICE`
- `QUEUED`
- `SYNC_STARTED`
- `SENT_TO_SERVER`
- `SYNC_SUCCESS`
- `SYNC_FAILED`

Avoid:
- Complex conflict resolution engine.
- Real background worker.
- Push-based sync.
- Realtime sync.
- Distributed event sourcing.

## 17. Offline-First Audit

What works:
- Local-first records for activities.
- Local IDs generated.
- SyncItem queue exists.
- Status visibility exists.
- Retry failed exists.
- Failed state exists.
- No backend dependency.
- Pending count updates from central state.

Fake but acceptable for prototype:
- In-memory state only.
- Sync Now always succeeds after delay.
- GPS/photo are simulated.
- Failed sync simulation is manual.

Dangerous even for prototype:
- Product quantities without UOM because it teaches the wrong business model.
- Sync detail without event timestamps if shown as "full sync history".
- Boolean-only photo evidence if positioned as audit-grade.

Must be fixed before backend integration:
- UOM and line item foundation.
- Sync attempt/timeline metadata.
- Photo metadata shape.
- Local persistence strategy.

## 18. Navigation and Flow Audit

| Issue | Location | User Impact | Severity | Low-Cost Fix |
|---|---|---|---|---|
| Store Page guard exists but redirects silently | Router/store activity routes | User may not know why returned to Visit | LOW | Show snackbar/error on guarded pages if possible |
| Completed visit no longer active | Repository `activeVisit` only in-progress | Correct behavior | LOW | Keep |
| Home Customer/Profile placeholders | Home menu | Demo can feel incomplete | LOW | Add read-only pages or avoid demoing |
| Debug sync action visible | Sync Center | Can look non-production | MEDIUM | Hide under demo/debug section |
| Direct history pages route-connected | Routes | Good | LOW | Keep |
| Home/Store menu separation | Home/Store Page | Correct | LOW | Keep strict separation |

## 19. Validation and Error Handling Audit

| Flow | Missing Validation | Risk | Low-Cost Fix |
|---|---|---|---|
| Login | No real user/password auth, expected prototype | Low | Keep dummy rule |
| Add Call Plan | Duplicate validation exists | Low | Keep |
| Check-in | Simulated GPS/photo validation exists | Low | Add GPS accuracy fields later |
| Sales Order | Missing UOM validation | Critical | Require UOM per line |
| Canvas Order | Missing UOM/base stock validation | Critical | Validate selected UOM against base stock |
| Return Order | Missing UOM validation | High | Require UOM per return line |
| Return Swap | Missing UOM validation | High | Require UOM on both products |
| Promo Check | Main required fields exist | Low | Keep |
| Competitor Activity | Selector validation exists; wording can improve | Low | Change "enter" to "select" later |
| Planogram | Required fields exist; incomplete competitor rows risk | Medium | Validate incomplete rows or ignore with visible warning |
| Stock Check | Missing UOM validation | High | Require UOM per row |
| End Visit | No unsaved cart tracking | Medium | Add simple draft/cart dirty flag if needed |
| Sync Center | No attempt count/timeline | Medium | Add lightweight sync event metadata |

## 20. Demo Readiness Audit

| Audience | Demo Ready? | Risk During Demo | Fix Before Demo |
|---|---|---|---|
| Internal leadership | Yes | They may ask why no UOM | Explain correction plan or fix first |
| Potential customer | Conditional | FMCG users will notice UOM quickly | Fix UOM before serious distributor demo |
| FMCG distributor | Not yet for deep demo | Order/stock/return quantity ambiguity | Product + UOM + Qty first |
| Technical stakeholder | Conditional | Sync/photo metadata shallow | Show lean architecture, admit next foundation |
| Investor | Yes for product vision | Needs polish and defensible roadmap | Demo happy path |

Minimum demo path that currently works:
1. Login with company code.
2. Home.
3. Visit.
4. Add call plan.
5. Check-in.
6. Store Page.
7. Promo Check or Competitor Activity.
8. Sales Order simple order.
9. End Visit.
10. Sync Center Sync Now.

Demo path that will expose weaknesses:
- Canvas order with pack/carton questions.
- Stock check with cases/pcs.
- Return swap with different units.
- Planogram under time pressure.
- Sync detail audit questions.

Screens to avoid until fixed:
- Deep Sales/Stock/Return discussion with FMCG operators.
- Planogram as mandatory salesman workflow.
- Sync detail as "complete audit log".

Screens that look strong:
- Login.
- Home.
- Visit/Call Plan.
- Check-in.
- Store Page grouped menu.
- Competitor Activity master selectors.
- Sync Center summary.

## 21. Root Cause Analysis

Root causes:
- Feature-first implementation arrived before commercial domain foundation.
- Product model started shallow and later absorbed own/competitor separation, but UOM was not added.
- No shared line item pattern exists, so sales, return, stock, and planogram each model product rows differently.
- Sync model was built as a queue status, not as an operational audit log.
- Forms were implemented screen-by-screen rather than from shared workflow primitives.
- Local state is centralized for business data but scattered for draft line entry.
- UI coverage moved fast, which created breadth before depth.
- Planogram was corrected toward domain richness, but not yet simplified for salesman speed.
- Photo/GPS are prototype booleans, good for clickability but not audit-grade.
- UI polish would now hide domain debt instead of solving it.

## 22. Recommended Correction Strategy

| Batch | Goal | Files Affected | Risk | Acceptance Criteria | Cost Control Principle |
|---|---|---|---|---|---|
| 1. Product + UOM + ProductLineItem foundation | Fix quantity meaning | `product.dart`, new `uom.dart`, new line item model, `dummy_data.dart`, repository | HIGH | Product has default/available UOM; line item stores Product+UOM+Qty | Minimal UOM, no pricing engine |
| 2. Refactor transaction flows to Product + UOM + Qty | Apply foundation to money/stock flows | sales, return, stock models/pages/repository | HIGH | Sales/return/stock lines require UOM | Reuse one line component |
| 3. Own Product vs Competitor Product governance | Preserve product filtering after refactor | product/repository/order/competitor/planogram | MEDIUM | Competitor products never appear in order | Repository guard, no admin UI |
| 4. Competitor Activity selector + quick add | Improve field speed | competitor page/model/repository | LOW | Search-first selector and minimal quick add | No approval workflow |
| 5. Planogram Basic Mode redesign | Make retail execution usable | planogram page/model/detail | MEDIUM | Basic Mode submit under 90 seconds | No AI/template builder |
| 6. SyncItem + lightweight SyncHistory correction | Improve auditability | sync model/repository/pages/home | MEDIUM | Attempt/timeline fields visible in detail | Simple events only |
| 7. Home sync summary + Sync Center log view | Keep salesman view simple | home/sync pages | LOW | Home summary only; Sync Center logs | No support dashboard |
| 8. Low-cost UI professionalism hardening | Make app feel serious | shared widgets and hot screens | MEDIUM | Consistent cards/chips/forms/buttons | No heavy custom UI |
| 9. Regression and demo scenario | Protect flow | tests/manual checklist | LOW | Main demo path works | Manual + analyze only |

## 23. What Not To Build Yet

| Feature | Why Tempting | Why Avoid Now | When To Build Later |
|---|---|---|---|
| Microservices | Sounds scalable | High cost, slow iteration | When modular monolith becomes bottleneck |
| Real-time sync | Feels modern | Salesman does not need it now | If supervisor live tracking becomes paid feature |
| Map routing | Visual demo appeal | SDK cost/complexity | When route planning is in scope |
| Territory optimization | Enterprise feature | Not current MVP | When coverage planning exists |
| AI planogram recognition | World-class buzz | Expensive and wrong before manual flow is correct | After photo dataset and scoring rules exist |
| OCR | Automation appeal | Not core field flow now | If invoice/shelf tag scanning is required |
| Image detection | Impressive demo | Expensive and brittle | After manual photo evidence is adopted |
| Complex pricing engine | Realistic enterprise feature | Too costly before UOM foundation | Backend phase |
| Complex discount engine | Promo sophistication | Current dummy discount enough | After real trade terms are known |
| Full inventory engine | Canvas stock can lead there | Mobile SFA is not WMS | If distributor inventory integration is required |
| Supervisor dashboard | Common SFA module | Mobile app is salesman-only | Web platform later |
| Admin module in mobile | Convenient | Violates scope | Web only |
| Complex approval workflow | Governance | Slows prototype and field flow | After quick-add usage is validated |
| Full offline database migration | Durable offline | Too early before model stabilizes | After UOM/sync model stabilizes |
| Heavy animation | Premium feel | Hurts low-end Android | Rare, subtle transitions only |
| Custom chart dashboard | Looks executive | Not useful in store | Web dashboard later |
| Push notifications | Engagement | Not needed for current flow | After backend scheduling exists |
| Background geolocation | Audit/tracking | Battery/privacy/cost risk | If business requires route compliance |

## 24. Critical Fix List

| Rank | Issue | Why It Matters | Severity | Fix Batch | Low-Cost Fix |
|---:|---|---|---|---|---|
| 1 | Missing UOM model | All product quantities are ambiguous | CRITICAL | 1 | Add dummy `Uom` |
| 2 | Missing ProductUom/default UOM | Products cannot be ordered in real units | CRITICAL | 1 | Add simple ProductUom mapping |
| 3 | Missing shared ProductLineItem | Duplicated row logic across flows | HIGH | 1 | Small immutable line model |
| 4 | Sales Order no UOM | Main commercial flow is not industry-correct | CRITICAL | 2 | Add UOM selector |
| 5 | Canvas stock product-level only | Stock validation wrong for packs/cases | CRITICAL | 2 | Base UOM stock |
| 6 | Return no UOM | Return quantity unclear | HIGH | 2 | Reuse line item |
| 7 | Return Swap no UOM | Swap quantities unclear | HIGH | 2 | UOM both sides |
| 8 | Stock Check no UOM | Store stock count unclear | HIGH | 2 | UOM per row |
| 9 | Order History no UOM | Historical lines incomplete | MEDIUM | 2 | Display UOM after refactor |
| 10 | Planogram too heavy | Salesman may skip or rush | HIGH | 5 | Basic Mode |
| 11 | Planogram rows no pack/UOM context | Shelf comparison incomplete | MEDIUM | 5 | Optional pack/UOM |
| 12 | Sync timeline missing | Weak audit and supportability | HIGH | 6 | Simple event fields |
| 13 | Attempt count missing | Retry history invisible | MEDIUM | 6 | Add attempt count |
| 14 | Photo metadata missing | Evidence is not audit-grade | MEDIUM | 6/8 | Metadata object, no binary |
| 15 | Debug sync action visible | Looks prototype-ish | MEDIUM | 8 | Hide under demo/debug |
| 16 | Home Customer/Profile placeholders | Demo incompleteness | LOW | 8 | Add simple read-only or defer visibly |
| 17 | Competitor price no UOM/pack | Price intelligence weak | MEDIUM | 4 | Optional observed UOM |
| 18 | Competitor selectors not searchable | Slower in field | MEDIUM | 4 | Searchable selector |
| 19 | Incomplete planogram competitor rows may confuse | Lost input risk | MEDIUM | 5 | Validate or warn |
| 20 | In-memory only state | App reset loses demo data | MEDIUM | Later | Add simple persistence after model stable |

## 25. Acceptance Criteria for World-Class Low-Cost Prototype

- Salesman can login in under 10 seconds.
- Check-in can be completed in under 20 seconds after location capture.
- Regular order for 3 products can be completed in under 60 seconds.
- Every product transaction line requires Product + UOM + Qty.
- Competitor brand/product are selected from master data or quick-added with duplicate prevention.
- Planogram Basic Mode can be submitted in under 90 seconds.
- Every submitted activity appears in Sync Center.
- Home only shows sync summary.
- Sync Center shows created time, status, synced time, and failure reason.
- Sales Order never shows competitor products.
- No critical flow depends on long free-text typing.
- Store Page cannot open without active checked-in visit.
- Completed visit cannot be edited accidentally.
- UI has consistent spacing, status chips, page titles, and button hierarchy.
- App remains usable on low-end Android.
- No unnecessary external service dependency.
- No expensive backend assumption is required for prototype.

## 26. Final Recommendation

Do not continue Phase 11 polish now.

Execute correction batches first, starting with Batch 1: Product + UOM + ProductLineItem foundation.

Safest next prompt:

```text
Implement Correction Batch 1 only: add UOM, ProductUom/default UOM, and shared ProductLineItem foundation. Do not refactor all screens yet. Keep app compile-ready and preserve own-vs-competitor product filtering.
```

Cheapest path to look world-class:
1. Fix UOM foundation.
2. Refactor Sales Order, Return, and Stock Check to use Product + UOM + Qty.
3. Make Planogram Basic Mode the default.
4. Add lightweight sync timeline fields.
5. Then do UI professionalism hardening with shared cards, chips, form rows, and button hierarchy.

This path is cheap because it avoids backend, microservices, maps, AI, OCR, full pricing engines, and admin scope. It is world-class enough because it fixes the business objects that FMCG/distribution users will immediately judge: visit proof, product units, transaction queue, and field usability.
