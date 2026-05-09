# SFA Mobile App Audit

## 1. Audit Summary

The current Flutter app is a functional local-only SHELA SFA Mobile prototype with login, home, visit planning, check-in, Store Page activities, local mock state, and a Sync Center. The app is broadly aligned with the intended SFA-only boundary: no backend, no admin modules, no invoice/payment/delivery/collection flows.

The strongest implemented areas are route coverage, active-visit guarding for Store Page activities, local SyncItem creation for submitted activities, own-vs-competitor product separation, and a reasonably centralized mock repository.

The biggest structural gap is product transaction modeling. Product-based transaction rows still use Product + integer quantity only. There is no UOM model, no Product-UOM relationship, no line-level UOM, and no shared product line item abstraction. This affects Sales Order, Canvas Order, Return Order, Return Swap Order, Stock Check, Planogram / Shelf Check, and Order History.

The Sync Center exists and shows SyncItems, but the sync data model is still shallow for a real offline audit trail. It has createdAt, syncedAt, status, and optional errorMessage, but it does not track created-on-device, queued time, attempt time, sent-to-server time, success/failure time as separate fields, attempt count, or a sync event timeline.

## 2. Current Folder Structure

Relevant current folders and files:

```text
lib/
  app.dart
  main.dart
  config/
    app_config.dart
  core/
    router/app_router.dart
    theme/app_theme.dart
    utils/currency_formatters.dart
    utils/date_formatters.dart
    widgets/menu_tile.dart
    widgets/status_chip.dart
    widgets/summary_card.dart
  data/
    dummy/dummy_data.dart
    models/
      brand.dart
      call_plan.dart
      competitor_activity.dart
      customer.dart
      order_history.dart
      planogram_check.dart
      product.dart
      promo_check.dart
      return_order.dart
      sales_order.dart
      stock_check.dart
      store_photo.dart
      sync_item.dart
      user_context.dart
      visit.dart
      visit_note.dart
    repositories/
      app_state_scope.dart
      mock_sfa_repository.dart
  features/
    auth/presentation/login_page.dart
    check_in/presentation/check_in_page.dart
    competitor_activity/presentation/
    home/presentation/home_page.dart
    planogram/presentation/
    promo_check/presentation/
    return_order/presentation/
    sales_order/presentation/
    stock_check/presentation/
    store/presentation/store_page.dart
    store_info/presentation/
    sync/presentation/
    visit/presentation/
    visit_completion/presentation/
  shared/widgets/app_logo.dart
test/widget_test.dart
```

Observations:
- Feature-based folders are present.
- `shared/widgets/app_logo.dart` exists but is not referenced in current code search.
- No `uom.dart` or shared `ProductLineItem` model exists.
- No database/backend/data source folder exists, which is consistent with prototype rules.

## 3. Current Routing Map

Routes are defined in `lib/core/router/app_router.dart`.

| Route | Page |
|---|---|
| `/` | Redirects to `/login` |
| `/login` | `LoginPage` |
| `/home` | `HomePage` |
| `/sync-center` | `SyncCenterPage` |
| `/sync-center/:syncItemId` | `SyncDetailPage` |
| `/visit` | `VisitPage` |
| `/visit/add-call-plan` | `CustomerSelectionPage` |
| `/check-in/:callPlanId` | `CheckInPage` |
| `/store` | `StorePage` |
| `/store/sales-order` | `SalesOrderMenuPage` |
| `/store/sales-order/regular` | `OrderEntryPage(orderType: regular)` |
| `/store/sales-order/canvas` | `OrderEntryPage(orderType: canvas)` |
| `/sales-orders` | `SalesOrderListPage` |
| `/sales-orders/:orderId/success` | `OrderSuccessPage` |
| `/sales-orders/:orderId` | `SalesOrderDetailPage` |
| `/store/return` | `ReturnMenuPage` |
| `/store/return/order` | `ReturnOrderPage` |
| `/store/return/swap` | `ReturnSwapOrderPage` |
| `/returns` | `ReturnListPage` |
| `/returns/:returnOrderId/success` | `ReturnSuccessPage` |
| `/returns/:returnOrderId` | `ReturnDetailPage` |
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

Route guards:
- Unauthenticated users are redirected to `/login`.
- `/store` redirects to `/visit` if there is no active visit.
- Store activity routes under sales order, return, promo, competitor, planogram, stock, store information, visit notes, store photo, and end visit redirect to `/visit` if no active visit exists.

Pages that exist but are not connected to any route:
- No obvious unconnected `*Page` classes were found in current route inspection.
- `shared/widgets/app_logo.dart` exists but appears unused. It is not a route/page.
- Home `Customer` and `Profile` menu items still show placeholder snackbars and do not open pages.

## 4. Current State Management / Repository Structure

State is centralized in `MockSfaRepository` (`lib/data/repositories/mock_sfa_repository.dart`), which extends `ChangeNotifier`.

`ShelaSalesApp` creates one `MockSfaRepository` in `lib/app.dart` and exposes it using `AppStateScope`, an `InheritedNotifier<MockSfaRepository>`.

Mock state stored centrally includes:
- Active user context.
- Last sync time and online flag.
- Call plans.
- Visits.
- SyncItems.
- Sales orders.
- Return orders.
- Promo checks.
- Competitor activities.
- Planogram checks.
- Stock checks.
- Visit notes.
- Store photos.
- Local mock-added competitor brands/products.
- Canvas stock map.

The app uses a centralized state holder for persisted mock business state, but feature pages still keep temporary form state locally with controllers, maps, selected dropdown values, and draft row classes. This is acceptable for a prototype, but transaction line item shape is duplicated across multiple pages.

## 5. Current Data Models

### UserContext

File: `lib/data/models/user_context.dart`

Fields:
- `userId`
- `username`
- `employeeId`
- `employeeName`
- `tenantId`
- `tenantName`
- `companyId`
- `companyName`
- `branchId`
- `branchName`
- `role`
- `appCode`
- `companyCode`

Missing fields:
- No token/session metadata.
- No permissions/feature flags, intentionally not needed for current mobile prototype.

Risk:
- Low. Fits current SFA prototype. Company code is session-only context, not a real tenant resolution implementation.

### Customer

File: `lib/data/models/customer.dart`

Fields:
- `id`
- `branchId`
- `name`
- `address`
- `phone`
- `lastVisit`
- `lastOrderAmount`
- `latitude`
- `longitude`
- `customerType`
- `status`
- `creditLimit`
- `outstandingAmount`
- `paymentStatus`
- `notes`

Missing fields:
- No customer code, channel, price group, tax group, address hierarchy, or outlet classification beyond simple strings.

Risk:
- Medium for commercial accuracy later; acceptable for current demo.

### Product

File: `lib/data/models/product.dart`

Fields:
- `id`
- `name`
- `sku`
- `brandId`
- `brandName`
- `productType`: `OWN_PRODUCT` or `COMPETITOR_PRODUCT`
- `category`
- `price`
- `canvasStock`
- `isSellable`

Missing fields:
- No UOM list.
- No base UOM.
- No conversion factors.
- No barcode.
- No tax/discount eligibility metadata.
- No per-branch or per-customer price.

Risk:
- High. Product is currently overloaded as a sellable catalog item, competitor catalog item, and stock-bearing item, but it lacks UOM needed for SFA transaction lines.

### Brand

File: `lib/data/models/brand.dart`

Fields:
- `id`
- `name`
- `brandType`: `OWN_BRAND` or `COMPETITOR_BRAND`
- `status`: `ACTIVE` or `INACTIVE`

Missing fields:
- No owner company, category, effective dates, or display order.

Risk:
- Low to medium. Works for current selector needs.

### UOM

File: Not found.

Fields:
- None. No UOM model exists.

Missing fields:
- UOM id/code/name.
- Base UOM flag.
- Product-UOM conversion factor.
- Sellable/returnable/stock count usage flags.

Risk:
- High. This is the main blocker for realistic product transaction input.

### Visit

File: `lib/data/models/visit.dart`

Fields:
- `id`
- `callPlanId`
- `customerId`
- `employeeId`
- `branchId`
- `status`
- `checkInAt`
- `latitude`
- `longitude`
- `photoCaptured`
- `fakeGpsDetected`
- `checkOutAt`

Missing fields:
- No explicit check-in photo id/path.
- No check-out GPS/photo.
- No cancellation reason.

Risk:
- Medium. Good enough for prototype lifecycle but limited for audit-grade proof of visit.

### CallPlan

File: `lib/data/models/call_plan.dart`

Fields:
- `id`
- `employeeId`
- `customerId`
- `branchId`
- `plannedDate`
- `plannedSequence`
- `status`

Missing fields:
- No planned time window.
- No objective/reason.
- No source/type.

Risk:
- Low for current flow.

### SalesOrder

File: `lib/data/models/sales_order.dart`

Fields:
- `id`
- `orderNumber`
- `orderType`
- `visitId`
- `customerId`
- `employeeId`
- `branchId`
- `items`
- `subtotal`
- `discount`
- `grandTotal`
- `syncStatus`
- `createdAt`

Missing fields:
- No order status beyond sync status.
- No UOM-aware line items.
- No price level, discount detail, tax, promo references, remarks.

Risk:
- High because all sales lines are product + integer quantity only.

### SalesOrderItem

File: `lib/data/models/sales_order.dart`

Fields:
- `productId`
- `productName`
- `sku`
- `quantity`
- `price`
- computed `subtotal`

Missing fields:
- No UOM id/code/name.
- No conversion factor.
- No base quantity.
- No line discount.
- No product type guard at model level.

Risk:
- High. Needs first-class UOM support.

### ReturnOrder

File: `lib/data/models/return_order.dart`

Fields:
- `id`
- `returnNumber`
- `returnType`
- `visitId`
- `customerId`
- `employeeId`
- `branchId`
- `items`
- `returnedItem`
- `replacementItem`
- `reason`
- `notes`
- `photoCaptured`
- `syncStatus`
- `createdAt`

Missing fields:
- No UOM.
- No return condition per line.
- No photo id/path.
- No replacement/returned line grouping abstraction.

Risk:
- High for realistic return capture.

### PromoCheck

File: `lib/data/models/promo_check.dart`

Fields:
- `id`
- `promoId`
- `promoName`
- `visitId`
- `customerId`
- `employeeId`
- `branchId`
- `complianceStatus`
- `photoCaptured`
- `notes`
- `syncStatus`
- `createdAt`

Missing fields:
- No photo id/path.
- No promo asset/type.

Risk:
- Medium.

### CompetitorActivity

File: `lib/data/models/competitor_activity.dart`

Fields:
- `id`
- `visitId`
- `customerId`
- `employeeId`
- `branchId`
- `competitorBrandId`
- `competitorBrand`
- `competitorProductId`
- `competitorProduct`
- `activityType`
- `price`
- `promoDescription`
- `photoCaptured`
- `notes`
- `syncStatus`
- `createdAt`

Missing fields:
- No photo id/path.
- No UOM for competitor price observation.
- No observed quantity/pack size.

Risk:
- Medium. It now uses master references, but price observation lacks UOM/pack context.

### PlanogramCheck

File: `lib/data/models/planogram_check.dart`

Fields:
- `id`
- `visitId`
- `customerId`
- `employeeId`
- `branchId`
- `beforePhotoCaptured`
- `shelfArea`
- `shelfLevel`
- `ownProductRows`
- `missingSkus`
- `competitorProductRows`
- `shareOfShelfEstimate`
- `mainIssue`
- `recommendedAction`
- `actionTaken`
- `afterPhotoCaptured`
- `complianceStatus`
- `notes`
- `syncStatus`
- `createdAt`

Nested row fields:
- `PlanogramOwnProductRow`: product id/name/sku, facing count, availability, placement status.
- `PlanogramCompetitorProductRow`: brand id/name, product id/name, facing count, shelf dominance note.

Missing fields:
- No UOM.
- No photo id/path.
- No shelf width/share numeric measurement.
- No price tag/photo references.

Risk:
- Medium to high. Structure is close to retail execution audit, but product rows still lack UOM and photo metadata.

### StockCheck

File: `lib/data/models/stock_check.dart`

Fields:
- `id`
- `visitId`
- `customerId`
- `employeeId`
- `branchId`
- `items`
- `notes`
- `syncStatus`
- `createdAt`

StockCheckItem fields:
- `productId`
- `productName`
- `sku`
- `quantity`
- `status`

Missing fields:
- No UOM.
- No base quantity/conversion.
- No expiry/batch.

Risk:
- High because store stock count requires UOM.

### StorePhoto

File: `lib/data/models/store_photo.dart`

Fields:
- `id`
- `visitId`
- `customerId`
- `employeeId`
- `branchId`
- `photoType`
- `photoCaptured`
- `notes`
- `syncStatus`
- `createdAt`

Missing fields:
- No file path/blob reference.
- No latitude/longitude/timestamp metadata per photo.

Risk:
- Medium. Prototype-only capture status is acceptable, but not audit-grade.

### SyncItem

File: `lib/data/models/sync_item.dart`

Fields:
- `id`
- `type`
- `referenceId`
- `title`
- `description`
- `status`
- `createdAt`
- `syncedAt`
- `errorMessage`

Missing fields:
- No created-on-device vs queued time separation.
- No queuedAt.
- No syncingAt.
- No lastAttemptAt.
- No sentToServerAt.
- No completedAt/failureAt as separate fields.
- No attemptCount.
- No sync event timeline.

Risk:
- High for real offline-first diagnostics; acceptable for simple demo queue.

### Other relevant models

`OrderHistory` (`lib/data/models/order_history.dart`) reuses `SalesOrderItem`, so it inherits missing UOM risk.

`VisitNote` (`lib/data/models/visit_note.dart`) captures visit result, notes, follow-up date, sync status, and createdAt. It is adequate for current prototype.

## 6. Product and UOM Audit

Does UOM model exist?
- No.

Does Product support available UOM?
- No. Product has price, canvas stock, category, type, and sellable flag, but no UOM list or base UOM.

Does product input support Product + UOM + Qty?
- No. Product inputs support Product + integer Qty only.

Pages currently using product input:
- Regular Order: `OrderEntryPage`
- Canvas Order: `OrderEntryPage`
- Return Order: `ReturnOrderPage`
- Return Swap Order: `ReturnSwapOrderPage`
- Stock Check: `StockCheckPage`
- Planogram / Shelf Check: `PlanogramCheckPage`
- Product & Price List: `ProductPriceListPage` and `ProductDetailPage`
- Order History: `OrderHistoryPage` and `OrderHistoryDetailPage`

Product-based pages that do not support UOM:
- Regular Order
- Canvas Order
- Return Order
- Return Swap Order
- Stock Check
- Planogram / Shelf Check
- Product & Price List
- Order History

Which model should be changed first to support UOM properly?
- Add a UOM model and Product-UOM relationship first.
- Then add a shared product line item model or value object.
- After that, refactor `SalesOrderItem`, `ReturnOrderItem`, `StockCheckItem`, and `PlanogramOwnProductRow` to include UOM id/code/name, entered quantity, conversion factor, and base quantity.

## 7. Own Product vs Competitor Product Audit

Does Product model support product_type?
- Yes. `ProductType.ownProduct` and `ProductType.competitorProduct`.

Does Product model support is_sellable?
- Yes. `isSellable` is present.

Are competitor products stored as Product Master records?
- Yes. Dummy data contains competitor product records such as Tango Wafer 50g, Roma Kelapa, and Khong Guan Assorted Biscuit with `productType: competitorProduct` and `isSellable: false`.

Does Sales Order filter only sellable own products?
- Yes. `OrderEntryPage` uses `repository.getOwnSellableProducts()`.
- `MockSfaRepository.submitSalesOrder` also defensively ignores products that are not own sellable products.

Does Competitor Activity use product selector or raw text?
- It uses selectors. `CompetitorActivityPage` uses `DropdownButtonFormField<Brand>` and `DropdownButtonFormField<Product>`.

Does Planogram support competitor product rows?
- Yes. `PlanogramCheckPage` has competitor shelf presence rows with competitor brand selector, competitor product selector, facing count, and shelf dominance note.

What is wrong and where?
- UOM is still missing everywhere.
- `Product & Price List` filters to own products only, which is reasonable for a store information price list but means competitor product master is not visible there.
- Competitor product add flow is local mock only and available from Competitor Activity, not a shared master-data UI.

## 8. Competitor Activity Audit

File location:
- `lib/features/competitor_activity/presentation/competitor_activity_page.dart`

Current fields:
- Customer context.
- Competitor Brand selector.
- Competitor Product selector.
- Activity Type dropdown.
- Optional price field.
- Promo description.
- Simulated competitor photo capture.
- Notes.

Current UI behavior:
- Requires active visit.
- Brand selector is populated from `repository.getCompetitorBrands()`.
- Product selector is populated from `repository.getCompetitorProducts(brandId: selectedBrand.id)`.
- Submit button is enabled when brand, product, activity type, and photo are present.

Whether brand is free text or selector:
- Selector.

Whether product is free text or selector:
- Selector.

Whether Add New Competitor Brand exists:
- Yes. `+ Add New Competitor Brand` opens a dialog and calls `repository.addCompetitorBrand`.

Whether Add New Competitor Product exists:
- Yes. `+ Add New Competitor Product` opens a dialog and calls `repository.addCompetitorProduct`.

Whether SyncItem is created:
- Yes. `MockSfaRepository.submitCompetitorActivity` creates a `SyncItem` with type `COMPETITOR_ACTIVITY`, status `QUEUED`.

What needs to be corrected:
- Add UOM/pack context for competitor price observation.
- Consider moving local add-brand/add-product dialogs into a reusable mock master-data helper if reused elsewhere.
- Validation messages still say "Please enter competitor brand/product" even though the UI uses selectors; wording should become "select".

## 9. Planogram / Shelf Check Audit

File location:
- `lib/features/planogram/presentation/planogram_check_page.dart`

Current fields:
- Customer context.
- Before photo.
- Shelf area.
- Shelf level.
- Own product rows.
- Missing SKU summary.
- Competitor shelf presence rows.
- Shelf analysis.
- Main issue.
- Recommended action.
- Merchandiser action taken.
- After photo.
- Compliance status.
- Notes.

Current UI behavior:
- Requires active visit.
- Submit disabled until required fields are complete.
- After photo is required if action taken is not `NO_ACTION_TAKEN`.
- Own product rows use own sellable product selector, facing count, availability, and placement status.
- Competitor rows use competitor brand/product selectors and facing count.

Whether before photo exists:
- Yes.

Whether after photo exists:
- Yes.

Whether shelf location exists:
- Yes. Shelf area and shelf level.

Whether own product facing rows exist:
- Yes.

Whether missing SKU summary exists:
- Yes, derived from own rows where availability is NO or placement is NOT_DISPLAYED.

Whether competitor shelf presence exists:
- Yes.

Whether shelf analysis exists:
- Yes. Share of shelf estimate, main issue, recommended action.

Whether merchandiser action exists:
- Yes. Action taken dropdown.

Whether compliance status exists:
- Yes.

Whether SyncItem is created:
- Yes. `MockSfaRepository.submitPlanogramCheck` creates a `SyncItem` with type `PLANOGRAM_CHECK`, status `QUEUED`.

What needs to be corrected:
- Add UOM to own product facing rows if facing is intended to distinguish units/cases/inner packs.
- Add photo metadata instead of boolean capture flags.
- Add richer planogram history list summaries if needed.
- Planogram currently validates competitor rows only if complete; incomplete competitor rows are silently dropped on submit rather than blocking with a message.

## 10. Sync Center Audit

File location:
- `lib/features/sync/presentation/sync_center_page.dart`
- `lib/features/sync/presentation/sync_detail_page.dart`

Current SyncItem model:
- `id`
- `type`
- `referenceId`
- `title`
- `description`
- `status`
- `createdAt`
- `syncedAt`
- `errorMessage`

Current Sync Center page behavior:
- Shows summary cards: Pending Sync, Synced Today, Failed Sync, Last Sync.
- Shows actions: Sync Now, Retry Failed, Simulate Failed Sync, Clear Synced when applicable.
- Shows type filters: ALL, VISIT, ORDER, RETURN, PROMO, COMPETITOR, PLANOGRAM, STOCK, PHOTO, NOTE.
- Shows status filters: ALL, QUEUED, SYNCED, FAILED, CONFLICT.
- Lists sync items with title, description, type, status, created time, and synced time when available.
- Tapping an item opens detail.

Whether Home uses central SyncItem state:
- Yes. Home dashboard uses `MockSfaRepository.getHomeDashboard()`, which counts `_syncItems` by status and uses `_lastSyncAt`.

Whether Home only shows summary:
- Mostly yes. Home shows Last sync, Pending sync, optional Failed sync pill, and summary cards for Pending Sync and Failed Sync. It does not list sync items.

Whether Sync Center shows detailed history:
- Partially. It shows current SyncItems and a detail page, but it does not show a complete event timeline.

Whether `created_at_on_device` exists:
- No. `createdAt` exists but is not explicitly named as device-created time.

Whether `queued_at` exists:
- No.

Whether `syncing_at` exists:
- No.

Whether `synced_at` exists:
- Yes, as `syncedAt`.

Whether `last_attempt_at` exists:
- No.

Whether `attempt_count` exists:
- No.

Whether `error_message` exists:
- Yes, as `errorMessage`.

Whether sync event timeline exists:
- No.

Which features create SyncItem:
- Visit check-in.
- Visit check-out.
- Regular order.
- Canvas order.
- Return order.
- Return swap order.
- Promo check.
- Competitor activity.
- Planogram check.
- Stock check.
- Visit note.
- Store photo.

Which features should create SyncItem but do not:
- Based on requested offline-first activity list, no missing SyncItem creation was found for the listed field activities.
- Add competitor brand/product does not create SyncItem. This is currently a local mock master-data action, not a field activity; if treated as a real mobile-created master-data request later, it would need sync.

## 11. Feature-by-Feature SyncItem Creation Matrix

| Feature | Creates SyncItem? | Sync Type | Status | Issue |
|---|---:|---|---|---|
| Visit Check-in | Yes | `VISIT_CHECK_IN` | `QUEUED` | Uses `createdAt`; no queuedAt/device timeline |
| Visit Check-out | Yes | `VISIT_CHECK_OUT` | `QUEUED` | Uses `createdAt`; no queuedAt/device timeline |
| Regular Order | Yes | `REGULAR_ORDER` | `QUEUED` | Sales lines lack UOM |
| Canvas Order | Yes | `CANVAS_ORDER` | `QUEUED` | Sales lines lack UOM; canvas stock is product-level only |
| Return Order | Yes | `RETURN_ORDER` | `QUEUED` | Return lines lack UOM |
| Return Swap Order | Yes | `RETURN_SWAP_ORDER` | `QUEUED` | Returned/replacement lines lack UOM |
| Promo Check | Yes | `PROMO_CHECK` | `QUEUED` | Photo is boolean only |
| Competitor Activity | Yes | `COMPETITOR_ACTIVITY` | `QUEUED` | Price observation lacks UOM/pack context |
| Planogram Check | Yes | `PLANOGRAM_CHECK` | `QUEUED` | Product rows lack UOM; photo fields are boolean only |
| Stock Check | Yes | `STOCK_CHECK` | `QUEUED` | Stock quantities lack UOM |
| Visit Note | Yes | `VISIT_NOTE` | `QUEUED` | Adequate for prototype |
| Store Photo | Yes | `STORE_PHOTO` | `QUEUED` | Photo metadata is boolean only |

## 12. UI / UX Structural Issues

Structural issues found:
- Product transaction input is too shallow: product + qty only, no UOM.
- UOM absence affects ordering, returns, stock count, planogram facing, and order history.
- Several transaction models duplicate product line ideas separately instead of using a shared line-item value object.
- Stock Check and Return forms use product rows but no UOM, making quantity ambiguous.
- Planogram is structurally richer now, but incomplete competitor rows are ignored rather than blocking or warning.
- Sync Detail labels "Customer" but currently displays the SyncItem description, not a resolved customer object.
- Sync Center status filters do not include CANCELLED or SYNCING explicitly.
- Home `Customer` and `Profile` menu entries are placeholders, not routes/pages.
- Add competitor brand/product is embedded inside Competitor Activity rather than reusable master-data support.

No major Home/Store menu mixing issue was found. Store Page menu remains separate from Home Menu.

## 13. Root Cause Analysis

Likely root causes:
- Initial product model was intentionally shallow for prototype speed.
- No shared `ProductLineItem` or `ProductUom` abstraction exists, so each feature created its own row model.
- Offline sync started as a queue status model, not an audit-grade sync log/timeline.
- Feature work was phased, causing several feature-specific forms to evolve independently.
- Product master was expanded later to include competitor products, but UOM was not introduced at the same time.
- Current mock state is centralized, but form state and line-draft logic are scattered locally in widgets.

## 14. Recommended Correction Order

Recommended safe correction order based on actual code:

1. Add UOM model and dummy UOM data.
2. Add Product-UOM relationship to Product or a separate ProductUom model.
3. Add shared product line item/value object for Product + UOM + entered quantity + base quantity.
4. Refactor SalesOrderItem and OrderEntryPage to use Product + UOM + Qty.
5. Refactor ReturnOrderItem, ReturnOrderPage, and ReturnSwapOrderPage to use UOM.
6. Refactor StockCheckItem and StockCheckPage to use UOM for store stock quantity.
7. Refactor PlanogramOwnProductRow and PlanogramCheckPage to include UOM where facing/count semantics require it.
8. Update Product & Price List and Product Detail to display available UOMs.
9. Update Order History and details to show UOM per line.
10. Confirm own product vs competitor product filters after UOM changes.
11. Upgrade SyncItem into sync log or add SyncHistory/SyncAttempt model.
12. Update Sync Center detail to show full timeline and attempt count.
13. Run regression through login, visit, check-in, each Store Page activity, Sync Now, and End Visit.

## 15. Files That Need Changes

| File | Change Needed | Risk | Priority |
|---|---|---|---|
| `lib/data/models/product.dart` | Add available UOM/base UOM or link to ProductUom | High | P0 |
| `lib/data/models/uom.dart` | Create UOM/ProductUom model | High | P0 |
| `lib/data/dummy/dummy_data.dart` | Add dummy UOM and product UOM mappings | High | P0 |
| `lib/data/models/sales_order.dart` | Add UOM fields to SalesOrderItem | High | P0 |
| `lib/features/sales_order/presentation/order_entry_page.dart` | Add UOM selector per product row and use base qty | High | P0 |
| `lib/data/repositories/mock_sfa_repository.dart` | Accept UOM-aware line inputs, validate sellable products and UOMs | High | P0 |
| `lib/data/models/return_order.dart` | Add UOM fields to ReturnOrderItem | High | P1 |
| `lib/features/return_order/presentation/return_order_page.dart` | Add UOM selector | High | P1 |
| `lib/features/return_order/presentation/return_swap_order_page.dart` | Add UOM selector for returned/replacement product | High | P1 |
| `lib/data/models/stock_check.dart` | Add UOM/base quantity to StockCheckItem | High | P1 |
| `lib/features/stock_check/presentation/stock_check_page.dart` | Add UOM selector per row | High | P1 |
| `lib/data/models/planogram_check.dart` | Add UOM to own product rows if required | Medium | P2 |
| `lib/features/planogram/presentation/planogram_check_page.dart` | Add UOM selector or clarify facing units | Medium | P2 |
| `lib/data/models/order_history.dart` | Support/display UOM-aware historical rows | Medium | P2 |
| `lib/features/store_info/presentation/order_history_detail_page.dart` | Display UOM per line | Medium | P2 |
| `lib/features/store_info/presentation/product_price_list_page.dart` | Display product UOMs | Medium | P2 |
| `lib/features/store_info/presentation/product_detail_page.dart` | Display product UOMs and conversions | Medium | P2 |
| `lib/data/models/sync_item.dart` | Add queuedAt/syncingAt/lastAttemptAt/attemptCount/timeline or split SyncHistory | High | P3 |
| `lib/features/sync/presentation/sync_center_page.dart` | Show timeline fields and more status filters | Medium | P3 |
| `lib/features/sync/presentation/sync_detail_page.dart` | Resolve related customer/visit/order; show actual timeline | Medium | P3 |
| `lib/features/home/presentation/home_page.dart` | Keep only sync summary; verify card density after Sync Center expansion | Low | P3 |
| `lib/features/competitor_activity/presentation/competitor_activity_page.dart` | Change validation copy from "enter" to "select"; add UOM/pack for observed price if needed | Low | P3 |

## 16. Phase 10.5 Correction Plan

Proposed Phase 10.5: Product UOM and Sync Audit Foundation.

Scope:

1. Add `Uom` and `ProductUom` models.
2. Add dummy UOMs such as PCS, BOX, CARTON with conversion examples per product.
3. Add a shared line input model:
   - product id/name/sku
   - UOM id/code/name
   - entered quantity
   - conversion factor
   - base quantity
4. Refactor Sales Order and Canvas Order first because they are the main commercial transaction path.
5. Refactor repository submit order API to receive structured line items instead of `Map<String, int>`.
6. Update sales order list/detail and order history display.
7. Add repository validation so competitor products and invalid UOMs cannot be submitted.
8. Keep Sync Center unchanged except ensuring order SyncItems still queue.
9. Run regression tests manually and with `flutter analyze`.

Out of scope for Phase 10.5:
- Backend sync.
- Real database.
- Admin/master-data management screens.
- Full SyncHistory event timeline. That should be the next correction after UOM line item stability.

## 17. Open Questions / Assumptions

- What are the real UOMs for the demo products: PCS, BOX, CARTON, PACK, or something else?
- Should prices be per base unit, per selected UOM, or selected UOM with conversion?
- Should canvas stock be stored in base unit or per UOM?
- Should returns allow UOMs different from original sales UOM?
- Does planogram facing require UOM, or is facing always a count of visible units/SKUs?
- Should competitor price observation include competitor UOM/pack size?
- Should Product & Price List show competitor product master anywhere, or remain own-product only?
- Should local Add Competitor Brand/Product create SyncItems as mobile-created master-data requests?
- Should Sync Center retain cleared synced items in history, or is removal acceptable for prototype?
- Should cancelled sync items be visible under status filters?
- Should sync detail resolve related customer by reference id for each type instead of using description?
