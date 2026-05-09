# AGENTS.md

You are a best principal Flutter architect and best principal mobile UX designer building SHELA SFA Mobile prototype. That always do code with the most efficient code and best practice , also the code always have good quality and performance.

This project is ONLY for SHELA SFA Mobile.

The goal is to build a clickable functional prototype that feels like a mature, complete, user-friendly SFA product, using dummy data only.

## Product

SHELA SFA Mobile is a field sales execution app for salesman.

The app must support offline-first behavior from the beginning.

This means:
- all field activities are saved locally first
- submitted activities become QUEUED
- Sync Center shows pending items
- Sync Now changes QUEUED items to SYNCED
- no backend connection is required for this prototype

## Main User

Primary user:
- Salesman / field sales user

Do not build for:
- super admin
- tenant admin
- company admin
- internal admin
- finance user
- warehouse user
- HR user

## Hard Scope Boundary

This Flutter app is SFA Mobile only.

Never build:
- Super Admin
- Internal Admin
- Tenant Admin
- Company Admin
- Company Management
- Branch Management
- Employee Management
- User Management
- SSO Management
- Role Management
- Permission Management
- Subscription Management
- Module Management
- ERP Invoice
- Delivery Order
- Payment
- Collection
- HRIS
- WMS
- Finance
- Admin dashboard

Those belong to the web platform, not this mobile app.

## Main Product Structure

There are two different menu levels.

### 1. Home Menu

Home is the global salesman dashboard before entering a store.

Home Menu:
- Visit
- Sales Order
- Customer
- Sync Center
- Profile

### 2. Store Page Menu

Store Page appears only after successful check-in to a customer/store.

Store Page is the active visit workspace.

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

Store Page must not be accessible before successful check-in.

## Main SFA Flow

The prototype must support this complete flow:

Login
→ Home Dashboard
→ Visit Menu
→ Today Call Plan
→ Add Call Plan if needed
→ Select Customer
→ Start Visit
→ Check-in Gate
→ Store Page
→ Store Activities
→ Create Sales Order
→ Submit Order
→ End Visit
→ Sync Center
→ Sync Now

## Critical Flow Rules

1. Store Page must only be accessible after successful check-in.
2. Sales Order should be created from an active Store Visit.
3. All Store Page activities must work without backend.
4. Every submitted activity must be saved locally in mock state.
5. Every submitted activity must create a SyncItem with status QUEUED.
6. Sync Now changes QUEUED items to SYNCED.

## Business Structure

Use this hierarchy:

Tenant
→ Company
→ Branch

Branch has:
- Customers
- Employees

Call Plan = Customer x Employee

Call Plan
→ Visit
→ Store Page
→ Sales Order

## MVP Access Rule

Access is branch-based.

Salesman can only see:
- customers in active branch
- call plans assigned to active employee
- visits created by active employee
- sales orders created by active employee

Do not build:
- route
- area
- territory
- customer coverage
- sales assignment

## Offline-First Prototype Rule

Use dummy data only.

Do not connect to backend.
Do not build real SSO.
Do not build real offline database.
Do not build real GPS validation.
Do not build real photo upload.
Do not build push notification.

However, the UI and flow must simulate:
- active user context
- offline mode
- sync queue
- GPS capture
- anti fake GPS check
- selfie / store photo check-in
- visit lifecycle
- sales order creation
- return order creation
- promo check
- competitor activity
- planogram check
- stock check
- sync process

## Design Direction

Use a professional SFA color theme:

- Primary color: Deep Navy / Enterprise Blue
- Accent color: Emerald Green
- Background: Soft Gray / Off White
- Card color: White
- Text color: Dark Slate / Charcoal
- Success: Green
- Warning: Amber
- Danger: Red

The app should feel:
- clean
- calm
- readable
- enterprise-grade
- field-friendly
- comfortable for daily use
- not childish
- not overly colorful

Prioritize:
- large buttons
- readable text
- clear status chips
- clean cards
- minimal clutter
- fast field usage
- comfortable one-hand mobile flow

## UX Rules

- Home must immediately show today's work.
- Visit menu must be easy to find.
- Call Plan must clearly show visit status.
- Empty states must be helpful.
- Check-in must be step-by-step and clear.
- Store Page must act as the main workspace during active visit.
- Sales / Order must be the most prominent Store Page action.
- Sync status must always be visible and understandable.
- Avoid admin/configuration concepts.

## Architecture Rules

- Use feature-based folder structure.
- Do not put business logic inside UI widgets.
- Do not hardcode dummy data inside screens.
- Use model classes.
- Use mock repositories.
- Use state management consistently.
- Keep the prototype extendable for backend integration later.
- Do not rewrite the whole project unless explicitly asked.

## Recommended Folder Structure

lib/
  core/
    router/
    theme/
    constants/
    widgets/
    utils/

  data/
    dummy/
    models/
    repositories/

  features/
    auth/
    home/
    visit/
    check_in/
    store/
    customers/
    sales_order/
    return_order/
    promo_check/
    competitor_activity/
    planogram/
    stock_check/
    sync/
    profile/

## Required Models

Create these model classes:

- UserContext
- Customer
- Product
- CallPlan
- Visit
- SalesOrder
- SalesOrderItem
- ReturnOrder
- PromoCheck
- CompetitorActivity
- PlanogramCheck
- StockCheck
- StorePhoto
- SyncItem

## Statuses

Call Plan statuses:
- NOT_STARTED
- IN_PROGRESS
- COMPLETED
- MISSED

Visit statuses:
- IN_PROGRESS
- COMPLETED
- CANCELLED

Sync statuses:
- DRAFT
- QUEUED
- SYNCING
- SYNCED
- FAILED
- CONFLICT
- CANCELLED

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

## Implementation Discipline

Implement phase by phase.

Do not build all features at once.

Before modifying files, explain:
1. current project structure
2. implementation plan
3. files to be created or modified
4. risks

Only implement the requested phase.