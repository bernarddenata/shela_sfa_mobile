# SFA Mobile Master Correction Strategy

## 1. Executive Decision

Do not continue UI polish now.

Pause and fix foundation first. The app is already a strong guided demo, but the audits agree that the main risk is not visual quality. The biggest root problem is the missing Product + UOM + Qty foundation. Current product-based transactions still treat quantity as a plain integer against a product, which is not correct for FMCG/distribution SFA.

The safest correction path is:
1. Fix shared product/UOM/line item models.
2. Refactor product-based transaction flows to use those shared models.
3. Preserve own-product vs competitor-product rules.
4. Simplify high-friction field workflows.
5. Upgrade sync history without building a real backend.
6. Only then harden UI polish.

The cheapest path to make the app look world-class is not more animation, dashboards, maps, or backend work. It is to fix the business objects that experienced FMCG users will notice immediately: UOM-aware ordering, clean product master rules, usable planogram flow, and understandable sync status.

## 2. Consolidated Audit Verdict

Combined verdict from:
- `audit/SFA_MOBILE_APP_AUDIT.md`
- `audit/SFA_MOBILE_INDUSTRY_USABILITY_RECHALLENGE.md`
- `audit/SFA_MOBILE_WORLD_CLASS_LOW_COST_AUDIT.md`

| Dimension | Final Score 1-5 | Why This Score |
|---|---:|---|
| Overall maturity score | 3 | The app is a complete lean demo, but not yet a strong enterprise prototype because product transactions are not UOM-correct. |
| Product maturity score | 3 | The SFA flow coverage is broad, but commercial transaction modeling is incomplete. |
| UX maturity score | 3 | Basic field flows are usable; Planogram is too heavy and product rows are ambiguous. |
| Data model maturity score | 2 | Missing UOM, ProductUom, shared ProductLineItem, SyncHistory, and richer photo/GPS metadata. |
| Technical architecture score | 4 | Lean feature folders, centralized mock repository, minimal dependencies, no backend/admin bloat. |
| SFA industry correctness score | 3 | Visit/store/sync structure is right; UOM and audit traceability are not yet industry-correct. |
| Low-cost maintainability score | 4 | The project is cheap to maintain now, but duplicated line item logic will get expensive if not fixed. |
| Performance readiness score | 4 | Lightweight Flutter app, small dummy data, no heavy packages, no maps/images/realtime. |
| Demo readiness score | 4 | Good for a guided demo; risky for a deep FMCG distributor demo before UOM correction. |

Scores are taken from the world-class low-cost audit where available because it is the most complete and most realistic. The app is not scored lower because architecture and demo flow are solid. It is not scored higher because the core transaction model is wrong for FMCG.

## 3. Consolidated Critical Issues

| Rank | Issue | Source Audit(s) | Severity | User Impact | Technical Impact | Cost Impact | Fix Batch |
|---:|---|---|---|---|---|---|---|
| 1 | Missing UOM model | All audits | CRITICAL | Salesman cannot express PCS/BOX/CARTON correctly | Product transactions are structurally incomplete | Refactor cost grows with every new feature | Batch 1 |
| 2 | Missing ProductUom/default UOM | All audits | CRITICAL | Product price/stock/unit meaning is unclear | Product model cannot support real line input | Forces later model migration | Batch 1 |
| 3 | Missing shared ProductLineItem | All audits | HIGH | Product rows behave inconsistently across screens | Sales/return/stock/planogram duplicate line logic | Maintenance cost rises quickly | Batch 1 |
| 4 | Sales Order uses Product + Qty only | All audits | CRITICAL | Main order flow feels toy-like to FMCG users | `SalesOrderItem` lacks UOM/baseQty | High future refactor risk | Batch 2 |
| 5 | Canvas Order stock is product-level only | Industry + world-class audits | CRITICAL | Stock cap is ambiguous for packs/cases | Canvas stock cannot convert by UOM | Wrong stock logic if extended | Batch 2 |
| 6 | Return Order / Return Swap lack UOM | All audits | HIGH | Returned quantity is unclear | `ReturnOrderItem` too shallow | Medium-high refactor cost | Batch 2 |
| 7 | Stock Check lacks UOM | All audits | HIGH | Store stock count is ambiguous | `StockCheckItem` too shallow | High if stock features expand | Batch 2 |
| 8 | Order History inherits no-UOM lines | App + world-class audits | MEDIUM | Past order lines are incomplete | Reuses `SalesOrderItem` | Needs display refactor after Batch 2 | Batch 2 |
| 9 | Own/competitor product governance must be preserved during refactor | All audits | HIGH | Competitor products must never be sold | Existing filters can regress during UOM work | Low if guarded centrally | Batch 3 |
| 10 | Competitor price observation lacks UOM/pack context | Industry + world-class audits | MEDIUM | Competitor price comparison is weak | `CompetitorActivity` lacks observed unit | Low-medium | Batch 4 |
| 11 | Competitor selectors are not yet optimized for speed | Industry + world-class audits | MEDIUM | Quick-add can slow a visit | UI selector pattern not reusable | Low | Batch 4 |
| 12 | Planogram is too heavy for salesman | Industry + world-class audits | HIGH | Salesman may skip/rush form | Current single mode mixes basic and advanced audit | Medium | Batch 5 |
| 13 | Planogram product rows lack UOM/pack clarity where relevant | App + world-class audits | MEDIUM | Facing/quantity interpretation may be unclear | `PlanogramOwnProductRow` lacks UOM | Medium | Batch 5 |
| 14 | SyncItem lacks queued/syncing/attempt timeline | All audits | HIGH | User/support cannot see real sync history | `SyncItem` is a shallow queue record | Medium | Batch 6 |
| 15 | Sync Center is not yet a real sync log | All audits | HIGH | Failed sync diagnosis is limited | No SyncEvent/attempt history | Medium | Batch 6/7 |
| 16 | Photo evidence is boolean-only | All audits | MEDIUM | Not audit-grade if inspected deeply | Store/promo/planogram/photo models lack metadata | Low now, medium later | Later after Batch 6 |
| 17 | Home Customer/Profile are placeholders | App + world-class audits | LOW | Demo may feel incomplete | Routes/pages not implemented | Low | Batch 8 or later |
| 18 | Debug sync action visible in normal Sync Center | World-class audit | MEDIUM | Looks prototype-ish | Demo utility mixed with user flow | Low | Batch 8 |
| 19 | Local state is centralized for business data but form row state is duplicated | App + world-class audits | MEDIUM | Inconsistent row UX | Page-specific draft row models | Medium | Batch 1/2 |
| 20 | UI polish before domain correction would hide debt | Industry + world-class audits | HIGH | App may look better but fail domain review | Wrong abstraction persists | High rework cost | Pause polish |

## 4. Root Cause Summary

The root causes are:

- Feature-first implementation happened before the product transaction domain model was complete.
- UOM was not introduced when Product became central to sales, returns, stock, planogram, and competitor observations.
- There is no shared ProductLineItem pattern, so each product-based feature created its own row structure.
- Product-based flows were built page-by-page instead of from a shared line item contract.
- Master data is partially standardized: competitor brand/product is now model-based, but UOM and ProductUom are still missing.
- Competitor brand/product is not currently raw free text in the app; the remaining issue is selector speed, quick-add UX, and observed pack/UOM.
- Planogram is no longer shallow, but it is now too complex for a normal salesman workflow.
- SyncItem was designed as a simple queue item, not as a sync history/log record.
- Sync Center shows useful queue status, but not a complete operational log.
- Business state is centralized in `MockSfaRepository`, while temporary form row state is scattered across pages.
- No major duplicate page/route problem was found. Routes are broadly connected.
- UI polish is being considered before foundational domain correction is complete.

## 5. Correction Principles

1. Fix shared models before fixing screens.
2. Do not patch page-by-page if the shared model is wrong.
3. Keep the prototype local-first.
4. Do not add backend.
5. Do not add a real database yet unless explicitly requested later.
6. Do not add expensive packages.
7. Do not build admin screens inside mobile.
8. Do not build a complex pricing engine.
9. Do not build a complex UOM conversion engine.
10. Use simple selectors and enums.
11. Use quick-add only where needed.
12. Free text only for notes, descriptions, or exception explanations.
13. Home shows sync summary only.
14. Sync Center shows sync history/logs.
15. Salesman flow must stay fast.

Additional cost-control rules:
- Prefer dummy master data over backend integration.
- Prefer small immutable models over heavy frameworks.
- Prefer repository-level validation over trusting UI filters.
- Prefer one reusable line item shape over multiple screen-specific row formats.
- Preserve existing working routes and flows during each batch.

## 6. Final Correction Batches

### Batch 1 — Product + UOM + ProductLineItem Foundation

Goal:
- Add/fix UOM model.
- Update Product model.
- Add reusable ProductLineItem.
- Support Product + UOM + Qty foundation.

Acceptance Criteria:
- `Uom` exists.
- Product supports available UOMs or a ProductUom relationship.
- ProductLineItem has product, UOM, entered qty, conversion/base qty where needed.
- Own product and competitor product separation is supported.
- Existing app still compiles.
- No product-based screen refactor is required in this batch unless needed for compile compatibility.

Low-cost boundary:
- Use dummy UOMs such as PCS, BOX, CARTON.
- Use simple conversion factors.
- Do not build a pricing engine.
- Do not add backend or database.

### Batch 2 — Refactor Product-Based Transaction Flows

Goal:
- Sales Order uses Product + UOM + Qty.
- Canvas Order uses Product + UOM + Qty.
- Return Order uses Product + UOM + Qty.
- Return Swap uses Product + UOM + Qty.
- Stock Check uses Product + UOM + Qty.
- Planogram product rows use Product + UOM only where relevant.

Acceptance Criteria:
- No product-based transaction only captures product without UOM.
- Cart/list/detail rows display UOM.
- Sales Order and Canvas Order still create SyncItems.
- Return Order and Return Swap still create SyncItems.
- Stock Check still creates SyncItem.
- Competitor products do not appear in Sales Order.

Low-cost boundary:
- Use default UOM to reduce taps.
- Keep discount rule simple.
- Keep canvas stock simulated.
- Do not build full inventory or pricing engine.

### Batch 3 — Own Product vs Competitor Product Governance

Goal:
- Preserve and harden Product type `OWN_PRODUCT` / `COMPETITOR_PRODUCT`.
- Preserve and harden `is_sellable` rule.
- Keep Brand master support.
- Block competitor products from selling flow.

Acceptance Criteria:
- Sales Order only shows sellable own products.
- Repository submit methods reject competitor products.
- Competitor Activity uses competitor brand/product master.
- Competitor Product can exist locally but is not sellable.
- Product & Price List remains own-product focused unless competitor products are clearly separated.

Low-cost boundary:
- No product admin screen.
- No role/permission engine.
- No approval workflow yet.

### Batch 4 — Competitor Activity Redesign

Goal:
- Replace any remaining slow selector behavior with searchable selectors.
- Keep brand/product as master references, not source-of-truth free text.
- Add quick-add brand/product.
- Preserve duplicate prevention case-insensitive.
- Keep salesman flow fast.

Acceptance Criteria:
- Brand/product stored by ID.
- Display names saved for UI convenience.
- Free text only for notes and promo description.
- Quick-add uses minimum fields.
- Submit creates SyncItem.
- Optional observed pack/UOM can be captured if cheap after Batch 1.

Low-cost boundary:
- No backend approval.
- No competitor catalog admin screen.
- No image recognition.

### Batch 5 — Planogram Basic Mode Redesign

Goal:
- Make planogram retail execution correct but not too heavy.
- Basic Mode for salesman.
- Optional advanced fields if already easy.

Acceptance Criteria:
- Before photo.
- Own product rows.
- Facing count.
- Missing SKU summary.
- Main issue.
- Action taken.
- After photo if action taken.
- Compliance status.
- Submit creates SyncItem.
- Can complete basic planogram in under 90 seconds.

Low-cost boundary:
- No AI planogram.
- No image recognition.
- No shelf measurement engine.
- No template builder.

### Batch 6 — SyncItem + Lightweight SyncHistory

Goal:
- Improve sync traceability without overengineering.
- Every activity creates SyncItem.
- Sync Center can show useful history/log.

Acceptance Criteria:
- SyncItem has created_on_device or equivalent `createdAt`.
- SyncItem has queued_at.
- SyncItem has syncing_at.
- SyncItem has synced_at.
- SyncItem has last_attempt_at.
- SyncItem has attempt_count.
- SyncItem has error_message.
- Sync events exist or equivalent simple history exists.
- Sync Now updates status and history.
- Failed retry works as dummy.

Low-cost boundary:
- No real API sync.
- No conflict resolution engine.
- No background worker.
- No realtime sync.

### Batch 7 — Home Sync Summary + Sync Center Logs

Goal:
- Home only shows summary.
- Sync Center shows detailed logs.

Acceptance Criteria:
- Home shows pending sync count, failed count, last sync.
- Sync Center shows created time, sent/synced time, status, failure reason.
- Home and Sync Center read from the same central SyncItem state.
- Salesman sees a simple default view.
- Technical detail is in Sync Detail, not Home.

Low-cost boundary:
- No support/admin dashboard.
- No raw payload viewer.
- No server diagnostics.

### Batch 8 — Low-Cost UI Professionalism Hardening

Goal:
- Make app look world-class but cheap to maintain.

Acceptance Criteria:
- Consistent spacing.
- Consistent card design.
- Consistent status chips.
- Better section headers.
- Better empty states.
- Clear button hierarchy.
- No toy-looking UI.
- No heavy animations or expensive UI complexity.
- Debug/demo-only controls are hidden or clearly separated.

Low-cost boundary:
- No custom graphics system.
- No charts unless needed.
- No map UI.
- No heavy animation.

### Batch 9 — Regression + Demo Scenario

Goal:
- Verify end-to-end flow.

Acceptance Criteria:
- Login.
- Add Call Plan.
- Check-in.
- Create Order.
- Return.
- Promo Check.
- Competitor Activity.
- Planogram.
- Stock Check.
- Visit Note.
- Store Photo.
- End Visit.
- Sync Now.
- No critical crash.
- Demo flow under 5 minutes.
- `flutter analyze` passes if available.

## 7. Batch Dependency Map

| Batch | Depends On | Why |
|---|---|---|
| Batch 1 | None | It creates the shared model foundation. |
| Batch 2 | Batch 1 | Product-based screens need ProductLineItem and UOM. |
| Batch 3 | Batch 1, Batch 2 | Own/competitor filtering must be verified after product/UOM refactor. |
| Batch 4 | Batch 3 | Competitor Activity relies on product/brand governance. |
| Batch 5 | Batch 1, Batch 3 | Planogram uses own product rows and competitor product rows; it may use UOM where relevant. |
| Batch 6 | None, but safer after Batch 2 | Sync model can be additive, but transaction references stabilize after ProductLineItem refactor. |
| Batch 7 | Batch 6 | Home and Sync Center should read from upgraded SyncItem/SyncHistory. |
| Batch 8 | Batches 1-7 | UI polish should happen after domain and sync behavior are stable. |
| Batch 9 | Batches 1-8 | Regression validates the full corrected flow. |

## 8. Files Likely Affected Per Batch

| Batch | Files Likely Affected | Risk | Notes |
|---|---|---|---|
| Batch 1 | `lib/data/models/uom.dart`, `lib/data/models/product.dart`, `lib/data/models/product_line_item.dart`, `lib/data/dummy/dummy_data.dart`, `lib/data/repositories/mock_sfa_repository.dart` | HIGH | Additive where possible; avoid screen refactor except compile fixes. |
| Batch 2 | `lib/data/models/sales_order.dart`, `lib/features/sales_order/presentation/order_entry_page.dart`, `lib/features/sales_order/presentation/sales_order_detail_page.dart`, `lib/features/sales_order/presentation/order_success_page.dart`, `lib/data/models/order_history.dart`, `lib/features/store_info/presentation/order_history_page.dart`, `lib/features/store_info/presentation/order_history_detail_page.dart`, `lib/data/models/return_order.dart`, `lib/features/return_order/presentation/return_order_page.dart`, `lib/features/return_order/presentation/return_swap_order_page.dart`, `lib/features/return_order/presentation/return_detail_page.dart`, `lib/data/models/stock_check.dart`, `lib/features/stock_check/presentation/stock_check_page.dart`, `lib/features/stock_check/presentation/stock_check_detail_page.dart`, `lib/data/repositories/mock_sfa_repository.dart` | HIGH | Main commercial refactor. Keep behavior local-first. |
| Batch 3 | `lib/data/models/product.dart`, `lib/data/models/brand.dart`, `lib/data/dummy/dummy_data.dart`, `lib/data/repositories/mock_sfa_repository.dart`, `lib/features/sales_order/presentation/order_entry_page.dart`, `lib/features/store_info/presentation/product_price_list_page.dart`, `lib/features/store_info/presentation/product_detail_page.dart` | MEDIUM | Mostly validation and filtering hardening. |
| Batch 4 | `lib/data/models/competitor_activity.dart`, `lib/features/competitor_activity/presentation/competitor_activity_page.dart`, `lib/features/competitor_activity/presentation/competitor_activity_detail_page.dart`, `lib/features/competitor_activity/presentation/competitor_activity_list_page.dart`, `lib/data/repositories/mock_sfa_repository.dart` | MEDIUM | Current selector model is already correct; improve speed and observed UOM/pack. |
| Batch 5 | `lib/data/models/planogram_check.dart`, `lib/features/planogram/presentation/planogram_check_page.dart`, `lib/features/planogram/presentation/planogram_check_detail_page.dart`, `lib/features/planogram/presentation/planogram_check_list_page.dart`, `lib/data/repositories/mock_sfa_repository.dart` | MEDIUM-HIGH | Split Basic vs Advanced without losing current audit fields. |
| Batch 6 | `lib/data/models/sync_item.dart`, optional `lib/data/models/sync_event.dart`, `lib/data/repositories/mock_sfa_repository.dart`, `lib/features/sync/presentation/sync_center_page.dart`, `lib/features/sync/presentation/sync_detail_page.dart` | MEDIUM | Prefer additive fields and helper methods. |
| Batch 7 | `lib/features/home/presentation/home_page.dart`, `lib/features/sync/presentation/sync_center_page.dart`, `lib/features/sync/presentation/sync_detail_page.dart`, `lib/data/repositories/mock_sfa_repository.dart` | LOW-MEDIUM | Keep Home simple; move detail to Sync Center. |
| Batch 8 | `lib/core/widgets/menu_tile.dart`, `lib/core/widgets/status_chip.dart`, `lib/core/widgets/summary_card.dart`, selected feature pages, `lib/core/theme/app_theme.dart` | MEDIUM | Polish hot paths only after foundation is stable. |
| Batch 9 | `test/widget_test.dart`, possible new tests/checklists, no broad app code expected | LOW | Add focused regression coverage if practical. |

## 9. What Not To Fix Yet

Avoid these for cost control:

- Backend integration.
- Real database migration.
- Real GPS.
- Real camera.
- AI planogram.
- OCR.
- Image recognition.
- Map routing.
- Territory optimization.
- Realtime sync.
- Push notification.
- Microservices.
- Complex pricing engine.
- Full discount engine.
- Full inventory engine.
- Supervisor dashboard.
- Admin mobile screens.
- SSO.
- Role/permission management.
- Company/branch/employee/user management.
- ERP invoice, payment, collection, delivery order, WMS, HRIS.

These may sound enterprise-grade, but they would make the prototype expensive before the core SFA mobile workflow is domain-correct.

## 10. Implementation Rules For Future Prompts

Every correction batch must follow these rules:

- Inspect existing files first.
- Modify only files needed for the batch.
- Do not rewrite the whole app.
- Keep the app compile-ready.
- Preserve existing working routes.
- Preserve Home Menu and Store Page Menu separation.
- Preserve Store Page active-visit guard.
- Preserve offline-first local behavior.
- Preserve SyncItem creation for submitted activities.
- Report files changed.
- Report what was intentionally not changed.
- Run `flutter analyze` if possible.
- If uncertain, create notes in audit instead of guessing.
- Do not add backend.
- Do not add real database.
- Do not add expensive packages.
- Do not build admin screens inside mobile.
- Do not hide regressions behind UI polish.

## 11. Recommended Next Prompt

Use this exact next prompt to implement Batch 1 only:

```text
Implement Correction Batch 1 only.

Current app is running with previous phases. Do not rewrite the whole app.
Do not refactor transaction screens yet unless required to keep the app compiling.

Goal:
Add Product + UOM + ProductLineItem foundation for SHELA SFA Mobile.

Scope:
1. Create UOM model.
2. Create ProductUom or equivalent available UOM relationship.
3. Update Product model to support default/available UOM without breaking own/competitor product separation.
4. Create reusable ProductLineItem model/value object with:
   - product_id
   - product_name
   - sku
   - uom_id
   - uom_code
   - uom_name
   - quantity
   - conversion_factor
   - base_quantity
   - price
   - subtotal
5. Add dummy UOM data:
   - PCS
   - BOX
   - CARTON
6. Add simple dummy Product-UOM mappings for existing own products and competitor products where useful.
7. Keep Sales Order, Return, Stock Check, and Planogram behavior unchanged for now unless compile fixes are needed.
8. Preserve:
   - OWN_PRODUCT / COMPETITOR_PRODUCT
   - is_sellable
   - Sales Order must not show competitor products
   - local mock state only
   - no backend
   - no database
   - no admin screens

Low-cost rule:
Do not build complex pricing engine or complex UOM conversion engine.
Use simple conversion factors and default UOM.

After implementation:
Run flutter analyze if possible.
Report:
1. Files changed
2. Models added/changed
3. Dummy UOM data added
4. What was intentionally not refactored yet
5. Any limitation
```
