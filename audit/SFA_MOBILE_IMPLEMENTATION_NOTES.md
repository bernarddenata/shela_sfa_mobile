# SFA Mobile — Core Correction Pack Implementation Notes

Generated: 2026-05-09

---

## 1. Current Folder Structure Summary

```
lib/
  app.dart
  main.dart
  config/app_config.dart
  core/
    router/app_router.dart
    theme/app_theme.dart
    utils/currency_formatters.dart, date_formatters.dart
    widgets/menu_tile.dart, status_chip.dart, summary_card.dart
  data/
    dummy/dummy_data.dart
    models/
      brand.dart, call_plan.dart, competitor_activity.dart, customer.dart
      order_history.dart, planogram_check.dart, product.dart, promo_check.dart
      return_order.dart, sales_order.dart, stock_check.dart, store_photo.dart
      sync_item.dart, user_context.dart, visit.dart, visit_note.dart
    repositories/
      app_state_scope.dart
      mock_sfa_repository.dart
  features/
    auth/, check_in/, competitor_activity/, home/, planogram/
    promo_check/, return_order/, sales_order/, stock_check/
    store/, store_info/, sync/, visit/, visit_completion/
  shared/widgets/app_logo.dart
```

---

## 2. Current Model Files Found

| Model | File | Status Before Change |
|---|---|---|
| Brand | data/models/brand.dart | OK — has brandType, brandStatus |
| CallPlan | data/models/call_plan.dart | OK — not changed |
| CompetitorActivity | data/models/competitor_activity.dart | Needs 4 more activity types |
| Customer | data/models/customer.dart | OK — not changed |
| OrderHistory | data/models/order_history.dart | OK — references SalesOrderItem |
| PlanogramCheck | data/models/planogram_check.dart | Needs UOM in row models |
| Product | data/models/product.dart | Needs baseUomId, availableUomIds |
| PromoCheck | data/models/promo_check.dart | OK — not changed |
| ReturnOrder | data/models/return_order.dart | Needs UOM in ReturnOrderItem |
| SalesOrder | data/models/sales_order.dart | Needs UOM in SalesOrderItem |
| StockCheck | data/models/stock_check.dart | Needs UOM in StockCheckItem |
| StorePhoto | data/models/store_photo.dart | OK — not changed |
| SyncItem | data/models/sync_item.dart | Needs timing/attempt fields |
| UserContext | data/models/user_context.dart | OK — not changed |
| Visit | data/models/visit.dart | OK — not changed |
| VisitNote | data/models/visit_note.dart | OK — not changed |

---

## 3. Product Model Location and Fields (Before)

File: `lib/data/models/product.dart`

Fields: id, name, sku, brandId, brandName, productType, category, price, canvasStock, isSellable

Missing: baseUomId, availableUomIds

---

## 4. UOM Model Existence

**Does NOT exist** before this implementation. Created as `lib/data/models/uom.dart`.

---

## 5. ProductLineItem Existence

**Does NOT exist** before this implementation. Created as `lib/data/models/product_line_item.dart`.

---

## 6. Dummy Products Location

`lib/data/dummy/dummy_data.dart` — `DummyData.products` (static const)

Own products (5): Nabati Wafer 50g, Nabati Nextar, Richeese Wafer, Nabati Richoco, Nabati Ahh
Competitor products (3): Tango Wafer 50g, Roma Kelapa, Khong Guan Assorted Biscuit

---

## 7. Sales Order Product Filtering

In `lib/data/repositories/mock_sfa_repository.dart`:
- `getOwnSellableProducts()` — filters `productType == ownProduct && isSellable`
- `submitSalesOrder()` — validates each product is OWN + sellable before adding to order
- `OrderEntryPage` calls `getOwnSellableProducts()` for product list

Competitor products are already blocked from Sales Order at both UI and repository levels.

---

## 8. Competitor Products Handling

- In `DummyData.products`: 3 competitor products with `productType = competitorProduct, isSellable = false`
- In `MockSfaRepository.addCompetitorProduct()`: creates product with `productType = competitorProduct, isSellable = false`
- `submitCompetitorActivity()` validates that brand is competitor brand and product is competitor product
- `CompetitorActivityPage` calls `getCompetitorBrands()` and `getCompetitorProducts(brandId: ...)`

---

## 9. SyncItem Location

- Model: `lib/data/models/sync_item.dart`
- State: `List<SyncItem> _syncItems` in `MockSfaRepository`
- Missing before: queuedAt, syncingAt, lastAttemptAt, attemptCount, SyncEvent history

---

## 10. Files Planned to Change

### New files:
- `lib/data/models/uom.dart`
- `lib/data/models/product_line_item.dart`
- `lib/data/models/sync_event.dart`

### Updated model files:
- `lib/data/models/product.dart` — add baseUomId, availableUomIds
- `lib/data/models/sales_order.dart` — add uomId/uomCode to SalesOrderItem
- `lib/data/models/return_order.dart` — add uomId/uomCode to ReturnOrderItem
- `lib/data/models/stock_check.dart` — add uomId/uomCode to StockCheckItem
- `lib/data/models/planogram_check.dart` — add uomId/uomCode to row models
- `lib/data/models/competitor_activity.dart` — add 4 activity types
- `lib/data/models/sync_item.dart` — add queuedAt, syncingAt, lastAttemptAt, attemptCount

### Updated data files:
- `lib/data/dummy/dummy_data.dart` — add UOMs, update products with UOM, add Richeese brand
- `lib/data/repositories/mock_sfa_repository.dart` — major: UOM methods, updated submit sigs, sync events

### Updated feature pages:
- `lib/features/sales_order/presentation/order_entry_page.dart` — UOM selector per product
- `lib/features/return_order/presentation/return_order_page.dart` — UOM selector per product
- `lib/features/return_order/presentation/return_swap_order_page.dart` — UOM selector per product
- `lib/features/stock_check/presentation/stock_check_page.dart` — UOM per row
- `lib/features/planogram/presentation/planogram_check_page.dart` — Basic Mode simplification + UOM
- `lib/features/sync/presentation/sync_detail_page.dart` — event timeline + new timestamp fields

---

## 11. Files That Will NOT Be Touched

- `lib/core/router/app_router.dart` — routes unchanged
- `lib/core/theme/app_theme.dart` — theme unchanged
- `lib/core/widgets/` — shared widgets unchanged
- `lib/data/models/brand.dart` — already correct
- `lib/data/models/customer.dart` — unchanged
- `lib/data/models/promo_check.dart` — unchanged
- `lib/data/models/store_photo.dart` — unchanged
- `lib/data/models/user_context.dart` — unchanged
- `lib/data/models/visit.dart` — unchanged
- `lib/data/models/visit_note.dart` — unchanged
- `lib/data/models/call_plan.dart` — unchanged
- `lib/data/models/order_history.dart` — reuses SalesOrderItem (gets UOM fields passively)
- `lib/data/repositories/app_state_scope.dart` — unchanged
- `lib/features/auth/presentation/login_page.dart` — unchanged
- `lib/features/check_in/presentation/check_in_page.dart` — unchanged
- `lib/features/home/presentation/home_page.dart` — already shows sync summary; no change needed
- `lib/features/store/presentation/store_page.dart` — unchanged
- `lib/features/visit/` — unchanged
- `lib/features/promo_check/` — unchanged
- `lib/features/competitor_activity/presentation/competitor_activity_detail_page.dart` — unchanged
- `lib/features/competitor_activity/presentation/competitor_activity_list_page.dart` — unchanged
- Detail pages (sales_order_detail, return_detail, stock_check_detail, planogram_check_detail) — passively benefit from model changes; no forced changes

---

## 12. Risk Areas

| Risk | Mitigation |
|---|---|
| `const Product(...)` in dummy_data requires new UOM fields | All const Product constructors updated; fields required |
| `const SalesOrderItem(...)` in historical dummy orders | uomId/uomCode given defaults so existing constructors still compile |
| `submitSalesOrder` signature change breaks OrderEntryPage | Both changed together in this batch |
| `submitReturnOrder` signature change breaks ReturnOrderPage | Both changed together |
| `submitReturnSwapOrder` signature change | Both changed together |
| Planogram page simplified — shelfLevel/shareOfShelf/recommendedAction removed from UI | Passed as hardcoded defaults to repository; model fields kept |
| Canvas stock check with UOM: no conversion factor | Known limitation; qty compared directly to canvas stock regardless of UOM |
| SyncEvent map in repository resets on logout | Expected prototype behavior; not persisted |
| Historical order SalesOrderItem show default UOM (PCS) | Acceptable — historical data predates UOM model |

---

## 13. Key Design Decisions

1. **UOM in line items**: UOM is stored for traceability. Price is always per-base-unit (PCS). No conversion factor in subtotal. Subtotal = qty × unit_price regardless of UOM selected.

2. **Product.availableUomIds**: Own products get [uom_pcs, uom_ctn]. Competitor products get [uom_pcs].

3. **SyncItem enhancements**: queuedAt set on creation. syncingAt/lastAttemptAt set during sync. Events stored separately in repository map.

4. **Planogram Basic Mode**: ShelfLevel, ShareOfShelfEstimate, RecommendedAction removed from UI; hardcoded defaults passed to repository. Notes required if actionTaken=NO_ACTION_TAKEN and mainIssue≠NO_ISSUE.

5. **Competitor brand/product**: Already model-based (not free text). Quick-add dialogs already exist. This batch adds missing CompetitorActivityType values.

6. **Richeese brand**: Added as OWN_BRAND. Products prod_003 (Richeese Wafer) updated to use brand_own_richeese.
