# SFA Mobile Industry & Usability Rechallenge

## 1. Executive Summary

The current SHELA SFA Mobile app is demo-ready as a clickable offline-first prototype, but it is not yet data-model correct for FMCG/distribution transaction reality.

Overall assessment:

| Question | Assessment |
|---|---|
| Demo-ready? | Yes, for a guided prototype demo. The main visit, store activity, and sync flows exist. |
| Structurally correct? | Mostly. Home Menu and Store Page Menu are separated, Store Page is guarded by check-in, and mock state is centralized. |
| Data-model correct? | Not yet. The critical gap is missing UOM and Product + UOM + Qty transaction lines. |
| Easy enough for salesman? | Mixed. Basic flows are usable, but Planogram is too heavy and several forms still require too much field effort. |
| Risky to continue without correction? | Yes. Continuing feature work before fixing UOM and sync audit structure will multiply refactor cost. |

The app has improved in several important areas: competitor brand/product is now master-data based, competitor products are separated from own sellable products, and Planogram / Shelf Check now resembles a retail execution audit. However, the next correction should not be another feature phase. The next correction should stabilize the commercial data foundation, especially UOM and shared product line inputs.

## 2. Industry Benchmark Lens

| Area | Current App Condition | Expected Industry Behavior | Gap | Severity | Recommended Correction |
|---|---|---|---|---|---|
| Visit planning | Today call plan exists with customer selection, sequence, and status. | Route/day plan with customer sequence, visit objective, planned time, reason, and status. | No planned time, visit objective, or route optimization. | MEDIUM | Keep current for demo; add visit objective later. |
| Check-in / check-out | Simulated GPS, fake GPS status, photo capture, visit status lifecycle. | Proof-of-visit with GPS, timestamp, photo, device metadata, geofence tolerance, and audit trail. | GPS/photo are booleans or dummy values; no photo metadata. | MEDIUM | For prototype keep simulation, but model photo/GPS metadata before backend. |
| GPS validation | Auto dummy coordinate from customer location. | Real GPS capture, accuracy, distance to outlet, mock location detection, and blocking rule. | No accuracy, distance tolerance, or real fake GPS detection. | MEDIUM | Add fields for accuracy/distance now; real integration later. |
| Outlet/customer context | Customer detail, address, phone, last visit/order, credit dummy info. | Outlet profile, channel, customer code, price group, credit, visit history, and branch coverage. | Missing customer code/channel/price group. | MEDIUM | Add only display fields needed for demo; defer full customer master. |
| Sales order taking | Regular/canvas order works with own sellable products and qty. | Product + UOM + quantity + price per UOM, promotions, stock validation, and order status. | No UOM; price and canvas stock are product-level only. | CRITICAL | Implement UOM and UOM-aware line item before more order work. |
| UOM-based ordering | Does not exist. | Salesman selects PCS/BOX/CARTON or default UOM; conversion and base quantity are stored. | Quantity is ambiguous. | CRITICAL | Add UOM, ProductUom, and ProductLineItem foundation immediately. |
| Return handling | Return order and return swap exist with product qty, reason, photo. | Return line uses product + UOM + qty + condition/reason + photo evidence. | No UOM; return condition/photo metadata limited. | HIGH | Refactor after sales order line item foundation. |
| Promo execution | Promo selection, compliance status, photo, notes, SyncItem. | Program checklist, display/photo evidence, compliance reason, and audit timestamp. | Good prototype, but photo is only boolean. | MEDIUM | Keep current; add photo metadata later. |
| Competitor activity tracking | Uses competitor brand/product selectors and local quick add. | Master-data selectors, searchable product/brand, quick add if not found, optional approval later. | Direction is correct; lacks UOM/pack context for price observation. | MEDIUM | Add search-first quick add and observed pack/UOM. |
| Planogram / shelf execution | Rich audit with before/after photo, shelf location, rows, competitor presence, analysis, action. | Fast shelf audit with photo, own SKU visibility, facing, competitor presence, issue/action, compliance. | Structurally strong but too heavy for salesman. | HIGH | Split into Basic Mode and Advanced Mode. |
| Stock check | Product rows with quantity and stock status. | Product + UOM + quantity, shelf/backroom distinction, expiry/batch optional. | No UOM; quantity is ambiguous. | HIGH | Add UOM per stock row. |
| Offline transaction queue | SyncItems are created for all listed activities and Sync Now updates status. | Local queue with retry, attempts, timestamps, and durable transaction references. | Queue works but timeline is shallow. | MEDIUM | Keep prototype behavior; add sync timestamp fields. |
| Sync history | Sync Center list/detail exists. | Created-on-device, queued, attempt, sent, success/failure, retry count, error. | Missing separate event timestamps and attempt count. | HIGH | Upgrade SyncItem or add SyncEvent/SyncAttempt model. |
| Supervisor/audit traceability | Basic createdAt/status fields exist. | Proof trail with who, when, where, photo metadata, sync attempts, failure reason. | Not audit-grade yet. | HIGH | Add metadata fields before backend integration. |

## 3. Salesman Usability Lens

| Flow | Salesman Ease Score 1-5 | Main Friction | Recommended UX Simplification |
|---|---:|---|---|
| Login | 4 | Company code adds one field, but it is necessary for SaaS context. | Remember company code and prefill during app session. |
| Home | 4 | Good dashboard, but Customer/Profile are still placeholders. | Keep Home focused on today work and sync summary. |
| Visit / Call Plan | 4 | Add call plan is simple; no route/time guidance. | Keep list short; add customer search and quick status visibility. |
| Check-in | 4 | Auto GPS helps; photo simulation is clear. | Keep one primary action and show requirement checklist. |
| Store Page | 4 | Menu is complete but can become dense. | Keep grouped sections; make Sales / Order and End Visit visually obvious. |
| Sales Order | 3 | Product search and qty are easy, but missing UOM makes real use ambiguous. | Add default UOM selector with one-tap quantity controls. |
| Return | 3 | Reason/photo are clear; product qty lacks UOM. | Use same Product + UOM + Qty row pattern as sales order. |
| Promo Check | 4 | Simple selector/photo/status flow. | Keep as is; avoid adding more mandatory fields. |
| Competitor Activity | 3 | Selectors are correct, but quick-add can interrupt store work. | Search first, then quick add with minimum fields only. |
| Planogram / Shelf Check | 2 | Current retail audit is too long for a salesman visit. | Add Basic Mode and move detailed audit to Advanced Mode. |
| Stock Check | 3 | Multiple rows are useful, but UOM is missing. | Add product + UOM + qty row and allow quick duplicate/add row. |
| End Visit | 4 | Summary is useful and final action is clear. | Keep warning concise; do not block unless required by policy. |
| Sync Center | 3 | Useful queue view, but detail can become technical. | Show salesman-friendly status first; keep timeline detail secondary. |

## 4. Data Standardization Rechallenge

Free text should only be used for notes, descriptions, or exception explanations. Repeatable business objects should be master data or enums.

| Object | Should Be | Current Implementation | Risk If Free Text | Recommended Fix |
|---|---|---|---|---|
| Company Code | Configuration/master lookup | Text input validated against accepted codes | Wrong company context, support issues | Keep text input but validate against resolved company context. |
| Customer | Master data | Customer model and dummy data | Duplicate outlets, wrong branch visibility | Keep master data; add customer code/channel later. |
| Product | Master data | Product model with own/competitor type | Duplicate SKU, wrong product in transaction | Keep master data; add UOM relationship. |
| UOM | Master data | Missing | Ambiguous quantities and pricing | Add UOM and ProductUom immediately. |
| Brand | Master data | Brand model exists | Duplicate competitor brands | Keep master data; add search and normalized duplicate checks. |
| Competitor Brand | Master data | Selector plus local quick add | Dirty competitor reporting | Keep selector; quick add should be searchable and normalized. |
| Competitor Product | Product master record | Competitor Product with `isSellable = false` | Free-text product names cannot be analyzed | Keep Product Master approach; add pack/UOM context. |
| Activity Type | Enum | CompetitorActivityType enum | Inconsistent reporting | Keep enum. |
| Promo Program | Master data | Dummy promo list | Cannot measure program execution | Keep promo master data. |
| Return Reason | Enum/master list | Static reason list | Dirty return analytics | Keep enum/list. |
| Visit Result | Enum | Visit result options | Inconsistent visit outcome reporting | Keep enum; allow notes for exceptions. |
| Shelf Area | Enum | ShelfArea enum | Hard to compare execution locations | Keep enum. |
| Shelf Level | Enum | ShelfLevel enum | Hard to audit placement quality | Keep enum, optional in Basic Mode. |
| Placement Status | Enum | ProductPlacementStatus enum | Inconsistent shelf compliance | Keep enum. |
| Stock Status | Enum | Stock status enum | Inconsistent stock reporting | Keep enum. |
| Main Issue | Enum | PlanogramMainIssue enum | Dirty issue reporting | Keep enum. |
| Recommended Action | Enum | RecommendedAction enum | Inconsistent follow-up | Keep enum, but consider auto-suggesting. |
| Action Taken | Enum | MerchandiserActionTaken enum | Inconsistent execution proof | Keep enum. |

## 5. Product + UOM Rechallenge

The proposed Product + UOM + Qty correction is necessary and should be the first correction foundation. Product alone is not enough for FMCG/distribution SFA because a salesman may sell, return, count, or compare products in PCS, pack, box, carton, or display unit.

| Question | Answer |
|---|---|
| Should UOM be required for Sales Order? | Yes. This is mandatory. Order quantity without UOM is commercially ambiguous. |
| Should UOM be required for Return? | Yes. Returned quantity must specify unit. |
| Should UOM be required for Stock Check? | Yes. Store stock quantity must specify unit. |
| Should UOM be required for Planogram facing? | Partly. Facing count itself is normally visible facings/SKU, not sales UOM. But if the row records physical quantity or replenishment need, UOM is needed. |
| Should UOM be required for Competitor Product? | For product master, at least default pack/UOM should exist. For price observation, UOM or pack size is important. |
| Should price be per UOM or product-level only? | Industry-correct: price should be per selected UOM or price list UOM. Prototype can use product base price with a default UOM first, but line must store UOM. |
| Should canvas stock be per UOM or product-level only? | Industry-correct: store in base UOM and display/validate selected UOM via conversion. Prototype can simulate base UOM stock first. |

Pragmatic recommendation:

| Action | Timing |
|---|---|
| Add `Uom`, `ProductUom`, and default UOM per product | Must implement now |
| Add shared `ProductLineItem` or value object with Product + UOM + Qty + baseQty | Must implement now |
| Refactor Sales Order and Canvas Order first | Must implement now |
| Refactor Return and Stock Check next | Must implement now or immediately after order |
| Add UOM display in Product & Price List and Order History | Can simulate for now |
| Add full price-list-per-UOM, tax, pack hierarchy | Can defer to backend phase |

## 6. Competitor Activity Rechallenge

The correction direction is industry-correct: competitor activity should use Brand Master and Product Master, with competitor products stored as `COMPETITOR_PRODUCT` and `isSellable = false`. This prevents competitor products from leaking into Sales Order while keeping competitor observations analyzable.

Recommended structure:

| Element | Rechallenge |
|---|---|
| Brand Master | Correct and mandatory. |
| Product Master | Correct and mandatory for repeatable competitor products. |
| Competitor Product Type | Correct. Must remain excluded from Sales Order. |
| Add New Brand CTA | Useful, but should be secondary after search. |
| Add New Competitor Product CTA | Useful, but should not slow down normal submit. |
| Approval later or local queue only | Prototype can keep local only; real app should queue for supervisor/master-data approval. |
| Duplicate detection | Mandatory, case-insensitive and normalized. |
| Searchable selector | Strongly recommended before the next usability pass. |

Is it still easy for salesman?
- Mostly, if the competitor brand/product already exists.
- It becomes slow if the salesman must create a product during a store visit.

Recommended simplification:
- Search first.
- If not found, show Quick Add.
- Quick Add minimum fields:
  - Brand
  - Product Name
  - Category optional
  - Estimated Price optional

Mandatory fields for submit:
- Competitor Brand
- Competitor Product
- Activity Type
- Photo

Optional fields:
- Price
- Promo description
- Notes
- Category for quick-added product

## 7. Planogram / Shelf Check Rechallenge

The revised Planogram / Shelf Check is more industry-correct than the earlier shallow version, but it is too heavy if every field is mandatory for a normal salesman visit. It fits a merchandiser or supervisor audit better than a fast salesman execution check.

Field classification:

| Field / Section | Recommendation |
|---|---|
| Before Photo | Mandatory |
| Shelf Area | Mandatory in advanced audit; optional/defaulted in basic check |
| Shelf Level | Optional or Advanced Mode |
| Own Product Facing | Mandatory, but keep row entry fast |
| Missing SKU | Auto-derived from own product visibility/availability |
| Competitor Shelf Presence | Optional in Basic Mode, Advanced Mode for detailed audit |
| Share of Shelf Estimate | Optional or auto-suggested from facing counts |
| Main Issue | Mandatory |
| Recommended Action | Auto-suggest from main issue, editable |
| Action Taken | Mandatory |
| After Photo | Mandatory only if action taken is not `NO_ACTION_TAKEN` |
| Compliance Status | Mandatory, can be suggested from issue/action |

What is too much for salesman:
- Detailed competitor product facing rows for every visit.
- Shelf level plus area plus share-of-shelf plus recommended action if all are mandatory.
- Requiring both analysis and action fields when the store has no issue.

How to make it fast:
- Use Basic Mode by default.
- Auto-fill `NO_ISSUE`, `NO_ACTION`, or `NO_ACTION_TAKEN` paths when appropriate.
- Derive missing SKUs from own product rows.
- Add common product checklist instead of long dropdown row creation.

Recommended modes:

### Basic Mode for salesman

- Before photo
- Select own products visible/missing
- Facing count
- Main issue
- Action taken
- After photo if action taken
- Submit

### Advanced Mode for merchandiser/supervisor

- Shelf area
- Shelf level
- Row/column or detailed placement
- Competitor facing
- Share of shelf
- Recommended action
- Detailed analysis notes

## 8. Sync Center Rechallenge

The current Sync Center is good enough for a prototype queue, but not yet a real offline operations log.

What salesman should see:
- Pending sync count
- Failed sync count
- Last sync time
- Transaction list
- Status
- Created time
- Synced time
- Retry failed action
- Simple failed reason

What should only support/admin see later:
- Raw payload
- Server endpoint
- Device id
- Detailed conflict payload
- Auth token/session diagnostics
- Full technical retry trace

What is enough for mobile prototype:
- Home: pending sync count, failed sync count, last sync time.
- Sync Center: transaction list, status, created time, synced time, retry failed.
- Sync Detail: reference id, error message, and simple timeline if available.

Recommended model direction:
- Add `queuedAt`, `syncingAt`, `lastAttemptAt`, `sentToServerAt`, `completedAt`, `attemptCount`.
- Either extend `SyncItem` or add a lightweight `SyncEvent` timeline.
- Do not overcomplicate the salesman screen; keep detailed timeline collapsible or in detail page only.

## 9. Correction Priority Rechallenge

| Issue | Industry Severity | Salesman Usability Impact | Correction Priority | Recommendation |
|---|---|---|---|---|
| Missing UOM model | CRITICAL | HIGH | Critical before continuing | Add UOM and ProductUom foundation now. |
| Sales Order lacks Product + UOM + Qty | CRITICAL | HIGH | Critical before continuing | Refactor order line input first. |
| Canvas stock is product-level only | HIGH | MEDIUM | Critical before continuing | Store/validate in base UOM for prototype. |
| Return rows lack UOM | HIGH | HIGH | Critical before continuing | Refactor after sales order line item foundation. |
| Stock Check rows lack UOM | HIGH | HIGH | Critical before continuing | Add UOM per stock row. |
| Planogram is too complex for salesman | HIGH | HIGH | Important but can be after demo | Add Basic Mode and Advanced Mode. |
| Competitor price lacks pack/UOM context | MEDIUM | MEDIUM | Important but can be after demo | Add observed UOM/pack field. |
| SyncItem lacks timeline/attempt fields | HIGH | LOW to MEDIUM | Important but can be after demo | Add SyncEvent or extended timestamps. |
| Photo capture stored as boolean only | MEDIUM | LOW | Important but can be after demo | Add dummy photo metadata model. |
| Customer/Profile Home menu placeholders | LOW | MEDIUM | Nice to have | Add simple read-only pages later. |
| Planogram incomplete competitor rows silently dropped | MEDIUM | MEDIUM | Important but can be after demo | Validate or clearly mark row incomplete. |
| Sync detail does not resolve related object deeply | MEDIUM | LOW | Nice to have | Resolve customer/order/visit in detail. |

## 10. Final Recommended Correction Plan

### Correction Batch 1: Product + UOM + ProductLineItem foundation

Goal:
- Introduce UOM correctness without changing every feature at once.

Files likely affected:
- `lib/data/models/uom.dart`
- `lib/data/models/product.dart`
- `lib/data/models/product_line_item.dart`
- `lib/data/dummy/dummy_data.dart`
- `lib/data/repositories/mock_sfa_repository.dart`

Risk:
- High, because product line shape is used across commercial flows.

Acceptance criteria:
- Products have default and available UOMs.
- UOM conversion exists in dummy data.
- Shared line item can store product, UOM, entered qty, conversion, and base qty.
- Competitor products remain non-sellable.

### Correction Batch 2: Refactor Sales Order / Return / Stock Check to Product + UOM + Qty

Goal:
- Fix the commercial and inventory-facing forms that rely on product quantity.

Files likely affected:
- `lib/data/models/sales_order.dart`
- `lib/features/sales_order/presentation/order_entry_page.dart`
- `lib/data/models/return_order.dart`
- `lib/features/return_order/presentation/return_order_page.dart`
- `lib/features/return_order/presentation/return_swap_order_page.dart`
- `lib/data/models/stock_check.dart`
- `lib/features/stock_check/presentation/stock_check_page.dart`
- `lib/data/repositories/mock_sfa_repository.dart`

Risk:
- High. Existing created dummy history and details need display changes.

Acceptance criteria:
- Regular order requires UOM per line.
- Canvas order validates stock through selected UOM conversion.
- Return and return swap show UOM.
- Stock check rows show product + UOM + qty.
- Order/return/stock SyncItems still create as QUEUED.

### Correction Batch 3: Competitor Brand/Product master selector

Goal:
- Improve the already-correct master-data direction for field usability.

Files likely affected:
- `lib/features/competitor_activity/presentation/competitor_activity_page.dart`
- `lib/data/models/competitor_activity.dart`
- `lib/data/repositories/mock_sfa_repository.dart`
- Possibly shared selector widgets.

Risk:
- Medium. The structure is already mostly correct.

Acceptance criteria:
- Brand and product selectors are searchable.
- Quick Add appears only after search/no result or secondary CTA.
- Quick-added competitor products remain `COMPETITOR_PRODUCT` and `isSellable = false`.
- Price observation can include pack/UOM context.

### Correction Batch 4: Planogram simplified retail execution audit

Goal:
- Keep industry correctness while making the flow realistic for a salesman.

Files likely affected:
- `lib/data/models/planogram_check.dart`
- `lib/features/planogram/presentation/planogram_check_page.dart`
- `lib/features/planogram/presentation/planogram_check_detail_page.dart`
- `lib/data/repositories/mock_sfa_repository.dart`

Risk:
- Medium to high. Current form has many required sections.

Acceptance criteria:
- Basic Mode can be completed quickly.
- Advanced Mode preserves detailed audit fields.
- Missing SKU is derived where possible.
- After photo remains required when action is taken.
- Planogram SyncItem still creates as QUEUED.

### Correction Batch 5: Sync Center history/log correction

Goal:
- Upgrade from simple queue status to operational sync trace.

Files likely affected:
- `lib/data/models/sync_item.dart`
- Optional `lib/data/models/sync_event.dart`
- `lib/data/repositories/mock_sfa_repository.dart`
- `lib/features/sync/presentation/sync_center_page.dart`
- `lib/features/sync/presentation/sync_detail_page.dart`
- `lib/features/home/presentation/home_page.dart`

Risk:
- Medium. Mostly additive if carefully modeled.

Acceptance criteria:
- Sync item records queued time, attempt time, synced/failed time, and attempt count.
- Retry Failed updates attempt fields.
- Home still shows only summary.
- Sync Center shows useful transaction history without overwhelming salesman.

### Correction Batch 6: Salesman usability simplification

Goal:
- Reduce time and taps for the most frequent store tasks.

Files likely affected:
- Sales order, return, competitor activity, planogram, stock check, sync pages.
- Possible shared widgets for selectors and line rows.

Risk:
- Medium. UX changes can accidentally change behavior.

Acceptance criteria:
- Repeated row entry is faster.
- Default UOM reduces taps.
- Planogram Basic Mode is default.
- Clear submit success and queued status remain visible.

## 11. Acceptance Criteria for "Good Enough for Salesman"

The prototype should be considered good enough for salesman only when:

- Login can be completed in under 10 seconds.
- Check-in can be completed in under 20 seconds after GPS loads.
- Regular order can be created in under 60 seconds for 3 products.
- Return can be created in under 60 seconds.
- Competitor activity can be submitted in under 45 seconds if product exists.
- Planogram basic check can be submitted in under 90 seconds.
- Sync status is understandable in under 5 seconds.
- No critical task requires long free-text typing.
- Every submitted activity clearly shows local queued status.
- Product quantity is never ambiguous because UOM is visible on every transaction line.

## 12. Open Questions

- What are the official selling UOMs for the demo products: PCS, PACK, BOX, CARTON, or other?
- Should default order UOM be the smallest unit or the most common sales unit?
- Should prices be maintained per UOM, or derived from base price and conversion?
- Should canvas stock be counted in base UOM or selected UOM?
- Should returns allow a different UOM than the original sale?
- Does the business treat planogram facing as SKU facing only, or should pack/UOM be captured too?
- Should competitor product quick-add create a sync item as a mobile-created master-data request?
- Should quick-added competitor brands/products require supervisor approval before appearing in master data?
- What minimum photo metadata is required for audit: timestamp, coordinate, type, local path, or all of these?
- How much sync timeline should a salesman see versus supervisor/support later?
- Should Customer and Profile Home menu placeholders become read-only pages before demo?
- Should the app support draft transaction recovery before End Visit blocks completion?
