# SFA_MOBILE_PROTOTYPE_PRD.md

## Objective

Build a clickable functional prototype for SHELA SFA Mobile using Flutter and dummy data.

This is not production yet.

The goal is to create a complete, user-friendly, offline-first SFA prototype that can be used for demo, validation, and future backend integration planning.

The prototype must feel like a real SFA product, not random screens.

## Main Prototype Flow

The most important flow is:

1. Salesman opens app
2. Salesman logs in
3. Salesman lands on Home Dashboard
4. Salesman taps Visit menu
5. Salesman sees Today's Call Plan
6. If call plan is empty, salesman can Add Call Plan
7. Salesman selects customer
8. Call Plan is created
9. Salesman taps Start Visit
10. Salesman goes to Check-in Gate
11. App simulates GPS capture
12. App simulates anti fake GPS check
13. Salesman captures selfie / store photo
14. Salesman taps Check In
15. Store Page is opened
16. Salesman uses Store Page menu
17. Salesman creates Sales Order
18. Salesman submits Sales Order
19. Sales Order status becomes QUEUED
20. Salesman records other store activities if needed
21. Salesman ends visit
22. Visit status becomes COMPLETED
23. Salesman opens Sync Center
24. Salesman taps Sync Now
25. QUEUED items become SYNCED

## Scope Boundary

This is SFA Mobile only.

Do not build:
- admin dashboard
- tenant management
- company management
- branch management
- employee management
- user management
- role management
- permission management
- SSO management
- subscription management
- module management
- ERP invoice
- delivery order
- payment
- collection
- finance
- HRIS
- WMS

## Target User

Salesman.

## Active Context

After dummy login, simulate:

- user_id: user_001
- username: budi.sales
- employee_id: emp_001
- employee_name: Budi Santoso
- tenant_id: tenant_001
- tenant_name: PT Demo Group
- company_id: company_001
- company_name: PT Demo Distributor
- branch_id: branch_001
- branch_name: Daan Mogot
- role: salesman
- app_code: SHELA_SFA_MOBILE

## MVP Data Rule

Branch-based access only.

Customer belongs to branch.
Employee belongs to branch.
Call Plan connects customer and employee.
Visit is created from Call Plan.
Store Page is opened after successful check-in.
Store activities are created from active Visit.

No route, area, territory, customer coverage, or sales assignment in this prototype.

---

# UI / UX Direction

## Visual Theme

Use a professional field-sales theme:

Primary:
- Deep Navy / Enterprise Blue

Accent:
- Emerald Green

Background:
- Soft Gray / Off White

Cards:
- White

Text:
- Dark Slate / Charcoal

Status:
- Success: Green
- Warning: Amber
- Danger: Red
- Info: Blue

## UX Feel

The app must feel:
- clean
- modern
- fast
- calm
- enterprise-ready
- comfortable for daily field usage

## Field Usage Principle

Salesman may use this app while walking, standing, or inside a store.

Therefore:
- Buttons must be easy to tap.
- Text must be readable.
- Actions must be obvious.
- Avoid too many nested screens.
- Avoid long paragraphs.
- Avoid tiny controls.

---

# Menu Structure

## Home Menu

Home is the global dashboard before entering a store.

Home Menu:
- Visit
- Sales Order
- Customer
- Sync Center
- Profile

## Store Page Menu

Store Page is the active visit workspace after successful check-in.

Store Page Menu:
- Sales / Order
- Return
- Promo Check
- Competitor Activity
- Planogram / Shelf Check
- Stock Check
- Product & Price List
- Order History
- Customer Info
- Visit Notes
- Store Photo
- End Visit

Do not mix Home Menu and Store Page Menu.

---

# Offline Mode Requirement

## Principle

The app must be local-first and sync-later.

For prototype:
- use dummy local state
- no real database
- no real backend
- all submitted activities become QUEUED
- Sync Now changes QUEUED to SYNCED

## SyncItem Model

Every submitted activity creates a SyncItem.

SyncItem fields:
- id
- type
- reference_id
- title
- description
- status
- created_at
- synced_at

Sync item types:
- VISIT_CHECK_IN
- VISIT_CHECK_OUT
- REGULAR_ORDER
- CANVAS_ORDER
- RETURN_ORDER
- RETURN_SWAP_ORDER
- PROMO_CHECK
- COMPETITOR_ACTIVITY
- PLANOGRAM_CHECK
- STOCK_CHECK
- VISIT_NOTE
- STORE_PHOTO

Sync statuses:
- QUEUED
- SYNCING
- SYNCED
- FAILED
- CONFLICT

## Sync Center

Sync Center must show all queued/synced activities, not only orders.

---

# Screen Details

## 1. Login Page

### Purpose

Allow salesman to enter the app using dummy login.

### UI

Show:
- SHELA logo / text
- App name: SHELA SFA
- Username field
- Password field
- Login button

### Behavior

- Any non-empty username and password can login.
- On login, create dummy active context.
- Navigate to Home Dashboard.

### Must Not Include

- Register
- Forgot password
- SSO
- Company setup
- Tenant setup

---

## 2. Home Dashboard

### Purpose

Give salesman a clear summary of today's work before entering any store.

### UI

Show:
- Greeting: Good morning, Budi
- Branch: Daan Mogot
- Date
- Online/offline indicator
- Last sync time
- Pending sync count

Summary cards:
- Today's Visit Plan
- Completed Visit
- Pending Visit
- Sales Today
- Pending Sync

Main menu cards:
- Visit
- Sales Order
- Customer
- Sync Center
- Profile

### Behavior

- Tapping Visit opens Visit / Call Plan Page.
- Tapping Sales Order opens Sales Order List.
- Tapping Customer opens Customer List.
- Tapping Sync Center opens Sync Center.
- Tapping Profile opens Profile.

### UX Priority

Visit menu should be the most visually important action.

---

## 3. Visit / Call Plan Page

### Purpose

This is the main page for daily visit execution.

### UI

Show:
- Page title: Visit
- Today date
- Call plan count
- Add Call Plan button
- List of today's call plans

Each call plan card shows:
- Visit sequence
- Customer name
- Customer address
- Call plan status chip
- Start Visit button

### Empty State

If no call plan exists, show:

"No visit plan for today."

Subtext:
"Add a customer to start your visit plan."

Button:
"Add Call Plan"

### Statuses

- NOT_STARTED
- IN_PROGRESS
- COMPLETED
- MISSED

### Behavior

- Add Call Plan opens Customer Selection Page.
- Start Visit opens Check-in Page.
- Completed call plans cannot be started again.

---

## 4. Add Call Plan / Customer Selection Page

### Purpose

Allow salesman to add customer into today's call plan.

### UI

Show:
- Search input
- Customer list filtered by active branch
- Customer name
- Customer address
- Phone number
- Last visit
- Last order amount

### Behavior

When salesman selects customer:
- Create call plan for today.
- call_plan.employee_id = active employee_id
- call_plan.customer_id = selected customer
- call_plan.branch_id = active branch_id
- status = NOT_STARTED
- planned_sequence = next available sequence
- Return to Visit / Call Plan Page

### Validation

- Customer must belong to active branch.
- Same customer cannot be added twice for today.
- If duplicate, show message:
  "Customer already exists in today's call plan."

---

## 5. Check-in Page

### Purpose

Validate salesman presence before opening Store Page.

### Entry Point

User arrives here after tapping Start Visit from a call plan.

### UI

Show:
- Customer name
- Customer address
- Current GPS coordinate
- GPS capture status
- Anti fake GPS status
- Selfie / store photo capture section
- Check In button

### Prototype Validation

Check-in requires:

1. GPS captured = true
2. Fake GPS detected = false
3. Selfie/photo captured = true

For prototype:
- GPS can use dummy coordinate.
- Fake GPS can be simulated as "No fake GPS detected".
- Selfie/photo can be simulated using a capture button.

### Blocking Rules

If GPS is not captured:
- Disable Check In.
- Show: "Location is required to check in."

If fake GPS is detected:
- Disable Check In.
- Show: "Fake GPS detected. Check-in is blocked."

If selfie/photo is missing:
- Disable Check In.
- Show: "Please take a selfie or store photo before check-in."

### Successful Check-in

On successful check-in:
- Create Visit with status IN_PROGRESS.
- Save check_in_at.
- Save dummy GPS coordinate.
- Save selfie/photo captured status.
- Change Call Plan status to IN_PROGRESS.
- Create SyncItem type VISIT_CHECK_IN with status QUEUED.
- Navigate to Store Page.

---

## 6. Store Page

### Purpose

Store Page is the active visit workspace.

This page can only open after successful check-in.

### UI

Show:
- Customer name
- Customer address
- Visit status: IN_PROGRESS
- Check-in time
- GPS status
- Selfie/photo status
- Pending sync indicator for this visit

### Store Menu

Group the menu into sections.

## Primary Sales

- Sales / Order
- Return

## Retail Execution

- Promo Check
- Competitor Activity
- Planogram / Shelf Check
- Stock Check

## Store Information

- Product & Price List
- Order History
- Customer Info

## Visit Completion

- Visit Notes
- Store Photo
- End Visit

### Critical Rule

Sales Order and all Store activities should be created from this Store Page, not freely from outside visit.

---

# Store Page Menu Details

## 7. Sales / Order Menu

### Purpose

Allow salesman to create order during active visit.

### Sub-menu

- Regular Order
- Canvas Order
- Draft Order

### Regular Order

Normal order from store.

Flow:
- Select Product
- Input Qty
- Cart
- Apply dummy discount
- Submit Order
- Status becomes QUEUED

### Canvas Order

Order from available canvas stock carried by salesman.

For prototype:
- use dummy canvas stock
- reduce dummy canvas stock after submit
- create SyncItem type CANVAS_ORDER with status QUEUED

### Draft Order

Saved order not yet submitted.

For prototype:
- simple placeholder list is acceptable
- do not overbuild

---

## 8. Return Menu

### Purpose

Allow salesman to record product return during active visit.

### Sub-menu

- Return Order
- Return Swap Order

### Return Order

Flow:
- Select Product
- Input Return Qty
- Select Reason
- Simulate Photo Capture
- Submit Return
- Create SyncItem type RETURN_ORDER with status QUEUED

Return reasons:
- Expired
- Damaged
- Wrong Item
- Slow Moving
- Customer Request

### Return Swap Order

Flow:
- Select Returned Product
- Input Return Qty
- Select Replacement Product
- Input Replacement Qty
- Add reason
- Submit Swap
- Create SyncItem type RETURN_SWAP_ORDER with status QUEUED

---

## 9. Promo Check

### Purpose

Allow salesman to check active company promo/program execution in store.

### UI

Show:
- Active Promo list
- Eligible Promo
- Promo compliance status
- Promo photo capture
- Notes

Promo compliance status:
- Installed
- Not Installed
- Partially Installed

### Behavior

Submit Promo Check:
- Save locally
- Create SyncItem type PROMO_CHECK with status QUEUED

---

## 10. Competitor Activity

### Purpose

Allow salesman to record competitor promo, price, product, or display.

### UI

Fields:
- Competitor brand
- Competitor product
- Activity type
- Price
- Promo description
- Notes
- Photo capture

Activity type:
- Discount
- Bundling
- Buy 1 Get 1
- Free Gift
- Price Cut
- Display Promo
- New Product

### Behavior

Submit Competitor Activity:
- Save locally
- Create SyncItem type COMPETITOR_ACTIVITY with status QUEUED

---

## 11. Planogram / Shelf Check

### Purpose

Allow salesman to record shelf condition and planogram compliance.

### UI

Fields:
- Shelf photo
- Compliance status
- Facing count
- Missing SKU
- Notes

Compliance status:
- Compliant
- Partially Compliant
- Not Compliant

### Behavior

Submit Planogram Check:
- Save locally
- Create SyncItem type PLANOGRAM_CHECK with status QUEUED

No AI image detection in this prototype.

---

## 12. Stock Check

### Purpose

Allow salesman to record store stock condition.

### UI

Fields:
- Product
- Store stock quantity
- Stock status
- Notes

Stock status:
- Available
- Low Stock
- Out of Stock

### Behavior

Submit Stock Check:
- Save locally
- Create SyncItem type STOCK_CHECK with status QUEUED

---

## 13. Product & Price List

### Purpose

Allow salesman to browse product catalog and prices.

### UI

Show:
- Product search
- Product category filter optional
- Product name
- SKU
- Price
- Promo badge if eligible
- Dummy stock indicator

### Behavior

- View-only from Store Page
- Can have "Add to Regular Order" shortcut if easy

---

## 14. Order History

### Purpose

Show previous dummy orders for selected customer.

### UI

Show:
- Order number
- Order date
- Total amount
- Status

Action:
- Repeat Order

For prototype:
- Repeat Order can prefill Regular Order cart if simple
- otherwise show placeholder

---

## 15. Customer Info

### Purpose

Show customer detail.

### UI

Show:
- Customer name
- Address
- Phone
- Last visit date
- Last order amount
- Customer status

---

## 16. Visit Notes

### Purpose

Allow salesman to write visit notes.

### UI

Fields:
- Visit result
- Notes
- Next follow-up date optional

Visit result:
- Order Created
- No Order
- Store Closed
- Owner Not Available
- Stock Full
- Competitor Dominant

### Behavior

Save Visit Note:
- Save locally
- Create SyncItem type VISIT_NOTE with status QUEUED

---

## 17. Store Photo

### Purpose

Allow salesman to capture store-related photos.

### Photo types:
- Front Store Photo
- Shelf Photo
- Promo Display Photo
- Competitor Photo
- Return Product Photo

### Behavior

For prototype:
- simulate capture button
- save photo metadata locally
- create SyncItem type STORE_PHOTO with status QUEUED

---

## 18. End Visit Confirmation

### Purpose

Complete active visit.

### UI

Show:
- Customer name
- Check-in time
- Check-out time
- Duration
- Total orders created
- Total returns created
- Promo checks submitted
- Competitor reports submitted
- Planogram checks submitted
- Stock checks submitted
- Visit note
- Confirm End Visit button

### Behavior

On confirm:
- Visit status becomes COMPLETED.
- Call Plan status becomes COMPLETED.
- Save check_out_at.
- Create SyncItem type VISIT_CHECK_OUT with status QUEUED.
- Navigate back to Visit / Call Plan Page.

### Validation

If user has unsaved cart/order:
- Show warning:
  "You have unsaved sales order. Please submit or discard before ending visit."

For prototype, simple warning is enough.

---

## 19. Sales Order List Page

### Purpose

Show orders created by salesman.

### UI

Show:
- Order number
- Customer name
- Order date
- Grand total
- Sync status chip

Sync statuses:
- QUEUED
- SYNCED
- FAILED

### Behavior

- Tap order opens Sales Order Detail.

Must not include:
- invoice
- payment
- delivery order
- collection

---

## 20. Sales Order Detail Page

### Purpose

Show submitted order detail.

### UI

Show:
- Order number
- Customer
- Order date
- Product items
- Subtotal
- Discount
- Grand total
- Sync status

---

## 21. Sync Center Page

### Purpose

Show dummy transaction sync status.

### UI

Show:
- Pending sync count
- Failed sync count
- Last sync time
- List of queued/synced sync items
- Sync Now button

Sync item card:
- Type chip
- Title
- Description
- Status chip
- Created time
- Synced time if available

### Behavior

- Sync Now changes all QUEUED items to SYNCED.
- Update last sync time.

No real backend sync.

---

## 22. Customer List Page

### Purpose

Allow salesman to see customers in active branch.

### UI

Show:
- Search customer
- Customer list
- Customer name
- Address
- Phone
- Last visit
- Last order

### Behavior

- Tap customer opens Customer Info Page.
- From Customer Info, salesman can Start Visit.

---

## 23. Profile Page

### Purpose

Show active salesman context.

### UI

Show:
- Employee name
- Role
- Tenant
- Company
- Branch
- App version
- Logout button

### Must Not Include

- Edit employee
- Manage user
- Manage branch
- Manage company
- Manage permission

---

# Dummy Data

## Active User

- user_id: user_001
- username: budi.sales
- employee_id: emp_001
- employee_name: Budi Santoso
- tenant_id: tenant_001
- tenant_name: PT Demo Group
- company_id: company_001
- company_name: PT Demo Distributor
- branch_id: branch_001
- branch_name: Daan Mogot
- role: salesman
- app_code: SHELA_SFA_MOBILE

## Customers

1. Toko Sumber Jaya
   - id: cust_001
   - branch_id: branch_001
   - address: Jl. Daan Mogot No. 12
   - phone: 081234567001
   - last_visit: 2026-05-06
   - last_order_amount: 750000
   - latitude: -6.1611
   - longitude: 106.7689

2. Toko Makmur Abadi
   - id: cust_002
   - branch_id: branch_001
   - address: Jl. Pesing Raya No. 8
   - phone: 081234567002
   - last_visit: 2026-05-05
   - last_order_amount: 1200000
   - latitude: -6.1662
   - longitude: 106.7781

3. Toko Berkah Jaya
   - id: cust_003
   - branch_id: branch_001
   - address: Jl. Jelambar Baru No. 21
   - phone: 081234567003
   - last_visit: 2026-05-04
   - last_order_amount: 500000
   - latitude: -6.1523
   - longitude: 106.7891

## Products

1. Nabati Wafer 50g
   - id: prod_001
   - sku: NAB-WFR-50
   - price: 10000
   - canvas_stock: 50

2. Nabati Nextar
   - id: prod_002
   - sku: NAB-NXT-01
   - price: 12000
   - canvas_stock: 40

3. Richeese Wafer
   - id: prod_003
   - sku: RCH-WFR-01
   - price: 15000
   - canvas_stock: 25

4. Nabati Richoco
   - id: prod_004
   - sku: NAB-RCO-01
   - price: 11000
   - canvas_stock: 30

5. Nabati Ahh
   - id: prod_005
   - sku: NAB-AHH-01
   - price: 9000
   - canvas_stock: 60

## Initial Call Plan

Initial call plan should be empty by default to demonstrate Add Call Plan flow.

## Dummy Discount Rule

Apply these rules for Regular Order and Canvas Order:

1. If subtotal >= 500000, fixed discount = 25000
2. If total quantity >= 10, percentage discount = 5%
3. If both eligible, use the bigger discount

## Dummy Historical Orders

For each customer, create 1–2 dummy historical orders for Order History page.

## Dummy GPS

Use customer coordinate as dummy captured GPS.

Fake GPS status default:
- false

Selfie/photo status default:
- false until user taps simulated capture button.

---

# Acceptance Criteria

## Overall

- Prototype feels like a complete SFA mobile flow.
- User can complete salesman daily flow from login to sync.
- Offline-first behavior is visible from the beginning.
- No admin feature exists in mobile app.

## Login

- User can login with dummy credentials.
- Active context is created.
- User lands on Home.

## Home

- Home shows employee name.
- Home shows branch.
- Home shows online/offline indicator.
- Home shows last sync time.
- Home shows pending sync count.
- Home shows summary cards.
- Visit menu is prominent.

## Visit / Call Plan

- Visit menu opens Call Plan page.
- Empty call plan state appears if no call plan exists.
- User can add call plan by selecting customer.
- Added call plan appears in today's call plan.
- Duplicate customer cannot be added twice for today.

## Check-in

- Start Visit opens Check-in Page.
- Check-in shows GPS status.
- Check-in shows fake GPS status.
- Check-in requires selfie/photo.
- Store Page only opens after successful check-in.
- Check-in creates SyncItem VISIT_CHECK_IN with status QUEUED.

## Store Page

- Store Page shows active visit.
- Store Page has its own Store Menu.
- Store Menu is different from Home Menu.
- User can access Sales / Order.
- User can access Return.
- User can access Promo Check.
- User can access Competitor Activity.
- User can access Planogram Check.
- User can access Stock Check.
- User can access Visit Notes.
- User can end visit.

## Sales / Order

- User can create Regular Order.
- User can create Canvas Order.
- User can add products.
- User can input quantity.
- Subtotal is calculated.
- Discount is calculated.
- Grand total is calculated.
- Submitted order status is QUEUED.
- Order creates SyncItem with status QUEUED.
- Order appears in Sales Order List.
- Order appears in Sync Center.

## Return

- User can create Return Order.
- User can create Return Swap Order.
- Return activity creates SyncItem with status QUEUED.

## Retail Execution

- User can submit Promo Check.
- User can submit Competitor Activity.
- User can submit Planogram Check.
- User can submit Stock Check.
- Each submitted activity creates SyncItem with status QUEUED.

## End Visit

- User can end visit.
- Visit status becomes COMPLETED.
- Call Plan status becomes COMPLETED.
- End visit creates SyncItem VISIT_CHECK_OUT with status QUEUED.

## Sync Center

- Sync Center shows all queued activities, not only orders.
- Sync Now changes QUEUED to SYNCED.
- Last sync time updates.

## UI Quality

- Color theme is consistent.
- Buttons are clear.
- Status chips are readable.
- Empty states are helpful.
- App feels usable for field salesman.
- Screens are not cluttered.

## Scope Control

- No tenant admin.
- No company admin.
- No branch management.
- No employee management.
- No user management.
- No SSO management.
- No backend API.
- No real database.