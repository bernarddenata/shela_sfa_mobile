# Phase 12 Manual QA Checklist

## Login Test Cases

- Open the app and confirm Login page appears.
- Leave Company Code empty and tap Sign In.
  - Expected: "Company code is required."
- Enter an invalid Company Code and valid username/password.
  - Expected: "Company code is not recognized."
- Leave Username empty.
  - Expected: "Username is required."
- Leave Password empty.
  - Expected: "Password is required."
- Login with `demo-distributor`, `demo`, or `shela-demo`.
  - Expected: user is navigated to Home.
- Toggle Remember Company Code.
  - Expected: company code is kept during app session only.

## Visit / Call Plan Test Cases

- From Home, tap Visit.
  - Expected: Visit page opens.
- If no call plans exist, verify empty state.
  - Expected: "No visit plan for today" and Add Call Plan button.
- Tap Add Call Plan.
  - Expected: Customer Selection page opens.
- Search by customer name, address, or phone.
  - Expected: customer list filters.
- Select a customer.
  - Expected: call plan is created and Visit page opens.
- Try adding the same customer again.
  - Expected: "Customer already exists in today's call plan."
- Verify call plan card shows sequence, customer, status, and action button.

## Check-in Test Cases

- On a NOT_STARTED call plan, tap Start Visit.
  - Expected: Check-in page opens.
- Confirm location auto-capture starts.
  - Expected: "Getting your location..." then "Location captured."
- Confirm coordinate, distance, and captured time are visible.
- Tap Refresh Location.
  - Expected: timestamp updates after simulated capture.
- Before photo capture, Check In should be disabled.
- Tap Take Selfie / Store Photo.
  - Expected: Photo captured state appears.
- Tap Check In.
  - Expected: Store Page opens.

## Store Page Test Cases

- Try opening Store Page before check-in by direct route if possible.
  - Expected: redirects to Visit page or shows check-in required message.
- After check-in, Store Page shows:
  - active customer
  - visit status
  - check-in time
  - GPS/photo/fake GPS status
  - pending sync indicator
  - grouped Store Menu sections
- Press AppBar back from Store Page.
  - Expected: returns to Visit Plan, visit stays active.
- Press Home icon from Store Page.
  - Expected: returns to Home, visit stays active.
- On Visit page, in-progress call plan shows Continue Visit.
  - Expected: Continue Visit returns to Store Page.

## Sales Order Test Cases

- From Store Page, open Sales / Order.
  - Expected: Sales / Order menu opens.
- Open Regular Order.
  - Expected: product list and cart summary are visible.
- Submit with empty cart.
  - Expected: Submit button disabled or validation prevents submit.
- Add at least one product quantity.
  - Expected: cart summary updates.
- Submit order.
  - Expected: Order Success page opens with queued sync status.
- Tap Back to Store Page.
  - Expected: Store Page opens.
- From Home, open Sales Order.
  - Expected: created order appears in Sales Order list.

## Return Test Cases

- From Store Page, open Return.
  - Expected: Return menu opens.
- Open Return Order.
  - Submit without products.
    - Expected: "Add at least one returned product."
  - Submit without reason.
    - Expected: "Return reason is required."
  - Submit without photo.
    - Expected: "Photo is required."
  - Complete required fields and submit.
    - Expected: Return Success page opens.
- Open Return Swap Order.
  - Submit without returned product.
    - Expected: "Returned product is required."
  - Submit with zero returned quantity.
    - Expected: "Returned quantity must be greater than 0."
  - Submit without replacement product.
    - Expected: "Replacement product is required."
  - Submit with zero replacement quantity.
    - Expected: "Replacement quantity must be greater than 0."
  - Complete required fields and submit.
    - Expected: Return Success page opens.
- From Return menu, open Return History.
  - Expected: created return appears.

## Promo Check Test Cases

- From Store Page, open Promo Check.
- Submit with missing promo/status/photo.
  - Expected: submit remains disabled or validation message appears.
- Select promo and compliance status.
- Capture promo photo.
- Submit.
  - Expected: Store Page opens and SyncItem is queued.
- Open Promo Check History.
  - Expected: submitted promo check appears.

## Competitor Activity Test Cases

- From Store Page, open Competitor Activity.
- Submit without brand.
  - Expected: "Please select competitor brand."
- Submit without product.
  - Expected: "Please select competitor product."
- Add New Competitor Brand with a duplicate name in different casing.
  - Expected: duplicate is rejected.
- Add New Competitor Product.
  - Expected: product is added locally and selectable.
- Enter negative price.
  - Expected: price validation blocks submit.
- Capture competitor photo and submit.
  - Expected: Store Page opens and SyncItem is queued.
- Open Competitor Activity History.
  - Expected: submitted activity appears.

## Planogram Test Cases

- From Store Page, open Planogram / Shelf Check.
- Submit without before photo.
  - Expected: blocked.
- Submit without shelf area.
  - Expected: blocked.
- Submit with incomplete own product row.
  - Expected: blocked.
- Add a partially filled competitor row.
  - Expected: submit shows "Please complete or remove incomplete competitor product rows."
- Complete required fields.
- If action taken is not NO_ACTION_TAKEN, leave after photo empty.
  - Expected: after photo validation blocks submit.
- Submit valid form.
  - Expected: Store Page opens and SyncItem is queued.
- Open Planogram History.
  - Expected: submitted check appears.

## Stock Check Test Cases

- From Store Page, open Stock Check.
- Submit with empty row.
  - Expected: "Please select product."
- Select product but leave quantity empty.
  - Expected: "Please enter store stock quantity."
- Enter negative quantity.
  - Expected: "Store stock quantity must be greater than or equal to 0."
- Leave stock status empty.
  - Expected: "Please select stock status."
- Submit valid stock check.
  - Expected: Store Page opens and SyncItem is queued.
- Open Stock Check History.
  - Expected: submitted stock check appears.

## End Visit Test Cases

- From Store Page, open End Visit.
  - Expected: summary page opens.
- If no activity exists, confirm warning appears.
- Confirm End Visit.
  - Expected:
    - Visit status becomes COMPLETED.
    - Call Plan status becomes COMPLETED.
    - Visit Completed success page opens.
    - Back to Visit Plan button works.
    - Go to Home button works.
- After End Visit, try opening Store Page.
  - Expected: Store Page is no longer active and user is sent to Visit Plan.
- Completed call plan button should be disabled and labeled Completed.

## Sync Center Test Cases

- From Home, open Sync Center.
  - Expected: Sync Center opens.
- Verify summary cards:
  - Pending Sync
  - Synced Today
  - Failed Sync
  - Last Sync
- Verify queued activities appear in list.
- Tap Sync Now.
  - Expected: queued items become synced, last sync time updates.
- Return to Home.
  - Expected: pending sync count updates.
- Use Demo tools > Simulate Failed Sync if a queued item exists.
  - Expected: one queued item becomes failed.
- Tap Retry Failed.
  - Expected: failed item becomes synced.
- Tap a SyncItem.
  - Expected: Sync Detail opens with status and timeline.

## Known Limitations

- Data is local prototype state and is not persisted across logout/app reset.
- GPS and photo capture are simulated.
- Backend sync is simulated.
- Product + UOM support exists in the current prototype, but it is still simplified.
- No real camera upload, map, GPS validation, backend, or database is included.
- Customer and Profile Home menu items remain simple professional placeholders.
- Draft Order and Repeat Order are not implemented yet.

## Issues Found and Fixed in Phase 12

- Replaced visible "dummy data" wording on Login with professional sample-data copy.
- Standardized placeholder wording for Customer/Profile, Draft Order, and Repeat Order.
- Corrected Competitor Activity validation copy from "enter" to "select" for selector fields.
- Added validation to prevent partially filled Planogram competitor rows from being silently ignored.
- Verified `flutter analyze` has no issues before code changes.
