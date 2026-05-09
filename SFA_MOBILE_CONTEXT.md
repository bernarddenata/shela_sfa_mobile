# SFA_MOBILE_CONTEXT.md

## Product Name

SHELA SFA Mobile

## Product Type

Mobile app for field sales execution.

## Product Goal

Help salesman execute daily store visits and sales activities quickly, clearly, and reliably.

The prototype should feel complete enough for demo and stakeholder validation, even though it uses dummy data.

## Target User

Primary user:
- Salesman

Salesman uses this app every day to:
- see today's visit plan
- add call plan if needed
- visit customer/store
- check in with GPS and selfie/store photo
- open store workspace
- create sales order
- record return
- check promo
- record competitor activity
- check planogram/shelf
- check store stock
- end visit
- sync transactions

## Out of Scope

This mobile app does not manage:
- tenant
- company
- branch
- employee
- user account
- SSO
- role
- permission
- subscription
- module configuration

Those are handled by the web platform.

## Active Context

After dummy login, the app simulates this active context:

Tenant: PT Demo Group
Company: PT Demo Distributor
Branch: Daan Mogot
Employee: Budi Santoso
Role: Salesman
App: SHELA SFA Mobile

## Business Hierarchy

Tenant
→ Company
→ Branch

Branch has:
- Customers
- Employees

## SFA Operational Flow

Call Plan = Customer x Employee

Then:

Call Plan
→ Check-in
→ Visit
→ Store Page
→ Store Activities
→ End Visit
→ Sync

## Menu Structure

There are two different menu levels.

## 1. Home Menu

Home is the global salesman dashboard before entering a store.

Home Menu:
- Visit
- Sales Order
- Customer
- Sync Center
- Profile

## 2. Store Page Menu

Store Page is only available after successful check-in.

Store Page is the active customer/store workspace.

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

## Important Rules

1. Salesman can only see customers in active branch.
2. Salesman can only see call plans assigned to active employee.
3. Visit must start from a call plan or newly added call plan.
4. Check-in must happen before Store Page is opened.
5. Store Page is the active visit workspace.
6. Sales Order is created from Store Page.
7. Return Order is created from Store Page.
8. Promo Check is created from Store Page.
9. Competitor Activity is created from Store Page.
10. Planogram Check is created from Store Page.
11. Stock Check is created from Store Page.
12. Submitted activity becomes QUEUED.
13. Sync Center can change QUEUED activity to SYNCED.

## Offline-First Principle

SFA Mobile must be designed as local-first and sync-later.

Salesman must be able to continue working even when internet is unstable.

For prototype:
- offline mode is simulated using dummy local state
- no real database is required
- no real backend is required

For later production:
- mock local state can be replaced with SQLite or Drift
- mock sync can be replaced with real sync engine

## Offline-Capable Data

The following data must be available locally:

- Active user context
- Customers
- Products
- Prices
- Promotions
- Call Plans
- Visit records
- Sales Orders
- Return Orders
- Promo Checks
- Competitor Activities
- Planogram Checks
- Stock Checks
- Visit Notes
- Store Photo metadata
- Sync Queue

## Offline Transaction Rule

All field activities must be saved locally first.

These activities must not require immediate backend connection:
- Check-in
- Check-out
- Regular Order
- Canvas Order
- Return Order
- Return Swap Order
- Promo Check
- Competitor Activity
- Planogram Check
- Stock Check
- Visit Note
- Store Photo

After local save, transaction status becomes QUEUED.

## Design Personality

SHELA SFA Mobile should feel like:
- modern enterprise sales app
- calm and professional
- easy for field users
- not too flashy
- not too complicated

Recommended style:
- Deep Navy / Enterprise Blue as primary
- Emerald Green as action accent
- Soft Gray background
- White cards
- Clear status colors
- Large primary buttons
- Clean icons
- Minimal clutter