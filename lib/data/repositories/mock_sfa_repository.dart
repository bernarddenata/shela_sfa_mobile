import 'package:flutter/foundation.dart';

import '../dummy/dummy_data.dart';
import '../models/brand.dart';
import '../models/call_plan.dart';
import '../models/competitor_activity.dart';
import '../models/customer.dart';
import '../models/order_history.dart';
import '../models/planogram_check.dart';
import '../models/product.dart';
import '../models/promo_check.dart';
import '../models/return_order.dart';
import '../models/sales_order.dart';
import '../models/store_photo.dart';
import '../models/sync_event.dart';
import '../models/sync_item.dart';
import '../models/stock_check.dart';
import '../models/uom.dart';
import '../models/user_context.dart';
import '../models/visit.dart';
import '../models/visit_note.dart';

// ---------------------------------------------------------------------------
// Input DTOs for product-based transactions
// ---------------------------------------------------------------------------

class OrderLineInput {
  const OrderLineInput({
    required this.productId,
    required this.uomId,
    required this.uomCode,
    required this.quantity,
  });

  final String productId;
  final String uomId;
  final String uomCode;
  final int quantity;
}

class ReturnLineInput {
  const ReturnLineInput({
    required this.productId,
    required this.uomId,
    required this.uomCode,
    required this.quantity,
  });

  final String productId;
  final String uomId;
  final String uomCode;
  final int quantity;
}

// ---------------------------------------------------------------------------
// Snapshot classes
// ---------------------------------------------------------------------------

class HomeDashboardSnapshot {
  const HomeDashboardSnapshot({
    required this.todayVisitPlan,
    required this.completedVisit,
    required this.pendingVisit,
    required this.salesToday,
    required this.pendingSync,
    required this.failedSync,
    required this.isOnline,
    required this.lastSyncAt,
  });

  final int todayVisitPlan;
  final int completedVisit;
  final int pendingVisit;
  final int salesToday;
  final int pendingSync;
  final int failedSync;
  final bool isOnline;
  final DateTime? lastSyncAt;
}

class SyncCenterSnapshot {
  const SyncCenterSnapshot({
    required this.pendingSync,
    required this.syncedToday,
    required this.failedSync,
    required this.lastSyncAt,
  });

  final int pendingSync;
  final int syncedToday;
  final int failedSync;
  final DateTime? lastSyncAt;
}

class VisitSummarySnapshot {
  const VisitSummarySnapshot({
    required this.regularOrderCount,
    required this.canvasOrderCount,
    required this.salesOrderCount,
    required this.returnOrderCount,
    required this.promoCheckCount,
    required this.competitorActivityCount,
    required this.planogramCheckCount,
    required this.stockCheckCount,
    required this.storePhotoCount,
    required this.visitNoteCount,
    required this.pendingSyncCount,
    this.latestVisitNote,
  });

  final int regularOrderCount;
  final int canvasOrderCount;
  final int salesOrderCount;
  final int returnOrderCount;
  final int promoCheckCount;
  final int competitorActivityCount;
  final int planogramCheckCount;
  final int stockCheckCount;
  final int storePhotoCount;
  final int visitNoteCount;
  final int pendingSyncCount;
  final VisitNote? latestVisitNote;

  bool get hasAnyStoreActivity =>
      salesOrderCount > 0 ||
      returnOrderCount > 0 ||
      promoCheckCount > 0 ||
      competitorActivityCount > 0 ||
      planogramCheckCount > 0 ||
      stockCheckCount > 0 ||
      storePhotoCount > 0 ||
      visitNoteCount > 0;
}

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

class MockSfaRepository extends ChangeNotifier {
  MockSfaRepository();

  UserContext? _activeUser;
  DateTime? _lastSyncAt;
  bool _isOnline = false;
  final List<CallPlan> _callPlans = [];
  final List<Visit> _visits = [];
  final List<SyncItem> _syncItems = [];
  final Map<String, List<SyncEvent>> _syncEvents = {};
  final List<SalesOrder> _salesOrders = [];
  final List<ReturnOrder> _returnOrders = [];
  final List<PromoCheck> _promoChecks = [];
  final List<CompetitorActivity> _competitorActivities = [];
  final List<PlanogramCheck> _planogramChecks = [];
  final List<StockCheck> _stockChecks = [];
  final List<VisitNote> _visitNotes = [];
  final List<StorePhoto> _storePhotos = [];
  final List<Brand> _mockBrands = [];
  final List<Product> _mockProducts = [];
  final Map<String, int> _canvasStockByProductId = {};
  Visit? _lastCompletedVisit;

  UserContext? get activeUser => _activeUser;
  Visit? get lastCompletedVisit => _lastCompletedVisit;

  Visit? get activeVisit {
    for (final visit in _visits.reversed) {
      if (visit.status == VisitStatus.inProgress) {
        return visit;
      }
    }
    return null;
  }

  bool get isAuthenticated => _activeUser != null;

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  bool login({
    required String companyCode,
    required String username,
    required String password,
  }) {
    if (!_isValidCompanyCode(companyCode)) {
      return false;
    }

    _activeUser = DummyData.activeUser.copyWith(
      username: username,
      companyCode: companyCode.trim(),
    );
    _isOnline = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _activeUser = null;
    _callPlans.clear();
    _visits.clear();
    _syncItems.clear();
    _syncEvents.clear();
    _salesOrders.clear();
    _returnOrders.clear();
    _promoChecks.clear();
    _competitorActivities.clear();
    _planogramChecks.clear();
    _stockChecks.clear();
    _visitNotes.clear();
    _storePhotos.clear();
    _mockBrands.clear();
    _mockProducts.clear();
    _canvasStockByProductId.clear();
    _lastCompletedVisit = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // UOM
  // ---------------------------------------------------------------------------

  List<Uom> getUoms() {
    return List.unmodifiable(DummyData.uoms);
  }

  Uom? getUomById(String uomId) {
    for (final uom in DummyData.uoms) {
      if (uom.id == uomId) {
        return uom;
      }
    }
    return null;
  }

  List<Uom> getUomsForProduct(Product product) {
    return product.availableUomIds
        .map((id) => getUomById(id))
        .whereType<Uom>()
        .toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  HomeDashboardSnapshot getHomeDashboard() {
    final callPlans = getTodayCallPlans();
    final completedVisit = callPlans
        .where((callPlan) => callPlan.status == CallPlanStatus.completed)
        .length;
    final pendingVisit = callPlans
        .where((callPlan) => callPlan.status == CallPlanStatus.notStarted)
        .length;

    return HomeDashboardSnapshot(
      todayVisitPlan: callPlans.length,
      completedVisit: completedVisit,
      pendingVisit: pendingVisit,
      salesToday: _salesOrders.fold<int>(
        0,
        (total, order) => total + order.grandTotal,
      ),
      pendingSync: _syncItems
          .where((syncItem) => syncItem.status == SyncStatus.queued)
          .length,
      failedSync: _syncItems
          .where((syncItem) => syncItem.status == SyncStatus.failed)
          .length,
      isOnline: _isOnline,
      lastSyncAt: _lastSyncAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Customers
  // ---------------------------------------------------------------------------

  List<Customer> getBranchCustomers() {
    final user = _activeUser;
    if (user == null) {
      return const [];
    }

    return DummyData.customers
        .where((customer) => customer.branchId == user.branchId)
        .toList(growable: false);
  }

  Customer? getCustomerById(String customerId) {
    for (final customer in DummyData.customers) {
      if (customer.id == customerId) {
        return customer;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Call Plans & Visits
  // ---------------------------------------------------------------------------

  List<CallPlan> getTodayCallPlans() {
    final user = _activeUser;
    if (user == null) {
      return const [];
    }

    final today = DateTime.now();
    final plans =
        _callPlans
            .where(
              (callPlan) =>
                  callPlan.employeeId == user.employeeId &&
                  callPlan.branchId == user.branchId &&
                  _isSameDay(callPlan.plannedDate, today),
            )
            .toList()
          ..sort((a, b) => a.plannedSequence.compareTo(b.plannedSequence));

    return List.unmodifiable(plans);
  }

  CallPlan? getCallPlanById(String callPlanId) {
    for (final callPlan in _callPlans) {
      if (callPlan.id == callPlanId) {
        return callPlan;
      }
    }
    return null;
  }

  Visit? getVisitByCallPlanId(String callPlanId) {
    for (final visit in _visits.reversed) {
      if (visit.callPlanId == callPlanId &&
          visit.status == VisitStatus.inProgress) {
        return visit;
      }
    }
    return null;
  }

  bool hasTodayCallPlanForCustomer(String customerId) {
    return getTodayCallPlans().any(
      (callPlan) => callPlan.customerId == customerId,
    );
  }

  bool addTodayCallPlan(Customer customer) {
    final user = _activeUser;
    if (user == null || customer.branchId != user.branchId) {
      return false;
    }

    if (hasTodayCallPlanForCustomer(customer.id)) {
      return false;
    }

    final todayCallPlans = getTodayCallPlans();
    final nextSequence = todayCallPlans.length + 1;
    _callPlans.add(
      CallPlan(
        id: 'cp_${DateTime.now().microsecondsSinceEpoch}',
        employeeId: user.employeeId,
        customerId: customer.id,
        branchId: user.branchId,
        plannedDate: DateTime.now(),
        plannedSequence: nextSequence,
        status: CallPlanStatus.notStarted,
      ),
    );
    notifyListeners();
    return true;
  }

  Visit? checkIn({
    required String callPlanId,
    required double latitude,
    required double longitude,
    required bool photoCaptured,
    required bool fakeGpsDetected,
  }) {
    final user = _activeUser;
    final callPlan = getCallPlanById(callPlanId);
    if (user == null ||
        callPlan == null ||
        callPlan.employeeId != user.employeeId ||
        callPlan.branchId != user.branchId ||
        callPlan.status == CallPlanStatus.completed ||
        fakeGpsDetected ||
        !photoCaptured) {
      return null;
    }

    final existingVisit = getVisitByCallPlanId(callPlanId);
    if (existingVisit != null) {
      return existingVisit;
    }

    final now = DateTime.now();
    final visit = Visit(
      id: 'visit_${now.microsecondsSinceEpoch}',
      callPlanId: callPlan.id,
      customerId: callPlan.customerId,
      employeeId: user.employeeId,
      branchId: user.branchId,
      status: VisitStatus.inProgress,
      checkInAt: now,
      latitude: latitude,
      longitude: longitude,
      photoCaptured: photoCaptured,
      fakeGpsDetected: fakeGpsDetected,
    );

    _visits.add(visit);
    _replaceCallPlan(callPlan.copyWith(status: CallPlanStatus.inProgress));

    final customer = getCustomerById(callPlan.customerId);
    _createSyncItem(
      id: 'sync_${now.microsecondsSinceEpoch}',
      type: SyncItemType.visitCheckIn,
      referenceId: visit.id,
      title: 'Visit Check-in',
      description: customer?.name ?? 'Customer visit',
      now: now,
    );

    notifyListeners();
    return visit;
  }

  int getPendingSyncCountForVisit(String visitId) {
    final referenceIds = _referenceIdsForVisit(visitId);
    return _syncItems
        .where(
          (syncItem) =>
              referenceIds.contains(syncItem.referenceId) &&
              syncItem.status == SyncStatus.queued,
        )
        .length;
  }

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  List<Product> getProducts() {
    _ensureCanvasStock();
    return [...DummyData.products, ..._mockProducts]
        .map(
          (product) => product.copyWith(
            canvasStock: product.isSellable
                ? (_canvasStockByProductId[product.id] ?? product.canvasStock)
                : 0,
          ),
        )
        .toList(growable: false);
  }

  List<Product> getOwnSellableProducts() {
    return getProducts()
        .where(
          (product) =>
              product.productType == ProductType.ownProduct &&
              product.isSellable,
        )
        .toList(growable: false);
  }

  List<Product> getCompetitorProducts({String? brandId}) {
    return getProducts()
        .where(
          (product) =>
              product.productType == ProductType.competitorProduct &&
              !product.isSellable &&
              (brandId == null || product.brandId == brandId),
        )
        .toList(growable: false);
  }

  Product? getProductById(String productId) {
    for (final product in getProducts()) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Brands
  // ---------------------------------------------------------------------------

  List<Brand> getBrands() {
    return List.unmodifiable([...DummyData.brands, ..._mockBrands]);
  }

  List<Brand> getCompetitorBrands() {
    return getBrands()
        .where(
          (brand) =>
              brand.brandType == BrandType.competitorBrand &&
              brand.status == BrandStatus.active,
        )
        .toList(growable: false);
  }

  Brand? getBrandById(String brandId) {
    for (final brand in getBrands()) {
      if (brand.id == brandId) {
        return brand;
      }
    }
    return null;
  }

  Brand? addCompetitorBrand(String name) {
    final normalizedName = _normalizeName(name);
    if (normalizedName.isEmpty) {
      return null;
    }

    final exists = getBrands().any(
      (brand) => _normalizeName(brand.name) == normalizedName,
    );
    if (exists) {
      return null;
    }

    final now = DateTime.now();
    final brand = Brand(
      id: 'brand_comp_${now.microsecondsSinceEpoch}',
      name: name.trim(),
      brandType: BrandType.competitorBrand,
      status: BrandStatus.active,
    );
    _mockBrands.add(brand);
    notifyListeners();
    return brand;
  }

  Product? addCompetitorProduct({
    required String brandId,
    required String name,
    String sku = '',
    String category = '',
    int price = 0,
  }) {
    final brand = getBrandById(brandId);
    final normalizedName = _normalizeName(name);
    if (brand == null ||
        brand.brandType != BrandType.competitorBrand ||
        normalizedName.isEmpty) {
      return null;
    }

    final exists = getProducts().any(
      (product) => _normalizeName(product.name) == normalizedName,
    );
    if (exists) {
      return null;
    }

    final now = DateTime.now();
    final resolvedSku = sku.trim().isEmpty
        ? 'COMP-${now.millisecondsSinceEpoch.toString().substring(7)}'
        : sku.trim();

    final product = Product(
      id: 'comp_prod_${now.microsecondsSinceEpoch}',
      name: name.trim(),
      sku: resolvedSku,
      brandId: brand.id,
      brandName: brand.name,
      productType: ProductType.competitorProduct,
      category: category.trim().isEmpty ? 'Competitor' : category.trim(),
      baseUomId: 'uom_pcs',
      availableUomIds: const ['uom_pcs'],
      price: price < 0 ? 0 : price,
      canvasStock: 0,
      isSellable: false,
    );
    _mockProducts.add(product);
    notifyListeners();
    return product;
  }

  // ---------------------------------------------------------------------------
  // Promo Programs
  // ---------------------------------------------------------------------------

  List<PromoProgram> getPromoPrograms() {
    return List.unmodifiable(DummyData.promoPrograms);
  }

  PromoProgram? getPromoProgramById(String promoId) {
    for (final promo in DummyData.promoPrograms) {
      if (promo.id == promoId) {
        return promo;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Sales Orders
  // ---------------------------------------------------------------------------

  List<SalesOrder> getSalesOrders() {
    final user = _activeUser;
    if (user == null) {
      return const [];
    }

    final orders =
        _salesOrders
            .where((order) => order.employeeId == user.employeeId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(orders);
  }

  SalesOrder? getSalesOrderById(String orderId) {
    for (final order in _salesOrders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  List<OrderHistory> getOrderHistoryForCustomer(String customerId) {
    final historical = DummyData.historicalOrders
        .where((order) => order.customerId == customerId)
        .toList();
    final local = _salesOrders
        .where((order) => order.customerId == customerId)
        .map(
          (order) => OrderHistory(
            id: order.id,
            orderNumber: order.orderNumber,
            orderType: order.orderType,
            customerId: order.customerId,
            visitId: order.visitId,
            items: order.items,
            subtotal: order.subtotal,
            discount: order.discount,
            grandTotal: order.grandTotal,
            syncStatus: order.syncStatus,
            createdAt: order.createdAt,
          ),
        )
        .toList();
    final orders = [...local, ...historical]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(orders);
  }

  OrderHistory? getOrderHistoryById(String orderId) {
    for (final order in _salesOrders) {
      if (order.id == orderId) {
        return OrderHistory(
          id: order.id,
          orderNumber: order.orderNumber,
          orderType: order.orderType,
          customerId: order.customerId,
          visitId: order.visitId,
          items: order.items,
          subtotal: order.subtotal,
          discount: order.discount,
          grandTotal: order.grandTotal,
          syncStatus: order.syncStatus,
          createdAt: order.createdAt,
        );
      }
    }
    for (final order in DummyData.historicalOrders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  SalesOrder? submitSalesOrder({
    required SalesOrderType orderType,
    required List<OrderLineInput> lineItems,
  }) {
    final visit = activeVisit;
    final user = _activeUser;
    if (visit == null || user == null || lineItems.isEmpty) {
      return null;
    }

    _ensureCanvasStock();
    final items = <SalesOrderItem>[];
    for (final line in lineItems) {
      if (line.quantity <= 0) {
        continue;
      }

      final product = getProductById(line.productId);
      if (product == null ||
          product.productType != ProductType.ownProduct ||
          !product.isSellable) {
        continue;
      }

      if (orderType == SalesOrderType.canvas &&
          line.quantity > (_canvasStockByProductId[product.id] ?? 0)) {
        return null;
      }

      items.add(
        SalesOrderItem(
          productId: product.id,
          productName: product.name,
          sku: product.sku,
          uomId: line.uomId,
          uomCode: line.uomCode,
          quantity: line.quantity,
          price: product.price,
        ),
      );
    }

    if (items.isEmpty) {
      return null;
    }

    final subtotal = items.fold<int>(0, (total, item) => total + item.subtotal);
    final totalQuantity = items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
    final discount = calculateDiscount(
      subtotal: subtotal,
      totalQuantity: totalQuantity,
    );
    final now = DateTime.now();
    final order = SalesOrder(
      id: 'so_${now.microsecondsSinceEpoch}',
      orderNumber: 'SO-${now.millisecondsSinceEpoch.toString().substring(5)}',
      orderType: orderType,
      visitId: visit.id,
      customerId: visit.customerId,
      employeeId: user.employeeId,
      branchId: user.branchId,
      items: List.unmodifiable(items),
      subtotal: subtotal,
      discount: discount,
      grandTotal: subtotal - discount,
      syncStatus: SyncStatus.queued,
      createdAt: now,
    );

    _salesOrders.add(order);
    if (orderType == SalesOrderType.canvas) {
      for (final item in items) {
        _canvasStockByProductId[item.productId] =
            (_canvasStockByProductId[item.productId] ?? 0) - item.quantity;
      }
    }

    final customer = getCustomerById(order.customerId);
    _createSyncItem(
      id: 'sync_${now.microsecondsSinceEpoch}',
      type: orderType == SalesOrderType.regular
          ? SyncItemType.regularOrder
          : SyncItemType.canvasOrder,
      referenceId: order.id,
      title: orderType.label,
      description: '${customer?.name ?? 'Customer'} ${order.grandTotal}',
      now: now,
    );

    notifyListeners();
    return order;
  }

  // ---------------------------------------------------------------------------
  // Return Orders
  // ---------------------------------------------------------------------------

  List<ReturnOrder> getReturnOrders() {
    final user = _activeUser;
    if (user == null) {
      return const [];
    }

    final returns =
        _returnOrders
            .where((returnOrder) => returnOrder.employeeId == user.employeeId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(returns);
  }

  ReturnOrder? getReturnOrderById(String returnOrderId) {
    for (final returnOrder in _returnOrders) {
      if (returnOrder.id == returnOrderId) {
        return returnOrder;
      }
    }
    return null;
  }

  ReturnOrder? submitReturnOrder({
    required List<ReturnLineInput> lineItems,
    required String reason,
    required bool photoCaptured,
    String notes = '',
  }) {
    final visit = activeVisit;
    final user = _activeUser;
    if (visit == null ||
        user == null ||
        reason.isEmpty ||
        !photoCaptured ||
        lineItems.isEmpty) {
      return null;
    }

    final items = <ReturnOrderItem>[];
    for (final line in lineItems) {
      if (line.quantity <= 0) {
        continue;
      }

      final product = getProductById(line.productId);
      if (product == null ||
          product.productType != ProductType.ownProduct ||
          !product.isSellable) {
        continue;
      }

      items.add(
        ReturnOrderItem(
          productId: product.id,
          productName: product.name,
          sku: product.sku,
          uomId: line.uomId,
          uomCode: line.uomCode,
          quantity: line.quantity,
        ),
      );
    }

    if (items.isEmpty) {
      return null;
    }

    return _createReturnOrder(
      returnType: ReturnOrderType.returnOrder,
      reason: reason,
      notes: notes,
      photoCaptured: photoCaptured,
      items: List.unmodifiable(items),
    );
  }

  ReturnOrder? submitReturnSwapOrder({
    required String returnedProductId,
    required String returnedUomId,
    required String returnedUomCode,
    required int returnedQuantity,
    required String replacementProductId,
    required String replacementUomId,
    required String replacementUomCode,
    required int replacementQuantity,
    required String reason,
    required bool photoCaptured,
    String notes = '',
  }) {
    final returnedProduct = getProductById(returnedProductId);
    final replacementProduct = getProductById(replacementProductId);
    if (returnedProduct == null ||
        replacementProduct == null ||
        returnedProduct.productType != ProductType.ownProduct ||
        replacementProduct.productType != ProductType.ownProduct ||
        !returnedProduct.isSellable ||
        !replacementProduct.isSellable ||
        returnedQuantity <= 0 ||
        replacementQuantity <= 0 ||
        reason.isEmpty ||
        !photoCaptured) {
      return null;
    }

    return _createReturnOrder(
      returnType: ReturnOrderType.returnSwap,
      reason: reason,
      notes: notes,
      photoCaptured: photoCaptured,
      returnedItem: ReturnOrderItem(
        productId: returnedProduct.id,
        productName: returnedProduct.name,
        sku: returnedProduct.sku,
        uomId: returnedUomId,
        uomCode: returnedUomCode,
        quantity: returnedQuantity,
      ),
      replacementItem: ReturnOrderItem(
        productId: replacementProduct.id,
        productName: replacementProduct.name,
        sku: replacementProduct.sku,
        uomId: replacementUomId,
        uomCode: replacementUomCode,
        quantity: replacementQuantity,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Promo Checks
  // ---------------------------------------------------------------------------

  List<PromoCheck> getPromoChecks() {
    final user = _activeUser;
    if (user == null) {
      return const [];
    }

    final checks =
        _promoChecks
            .where((promoCheck) => promoCheck.employeeId == user.employeeId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(checks);
  }

  PromoCheck? getPromoCheckById(String promoCheckId) {
    for (final promoCheck in _promoChecks) {
      if (promoCheck.id == promoCheckId) {
        return promoCheck;
      }
    }
    return null;
  }

  PromoCheck? submitPromoCheck({
    required String promoId,
    required PromoComplianceStatus complianceStatus,
    required bool photoCaptured,
    String notes = '',
  }) {
    final visit = activeVisit;
    final user = _activeUser;
    final promo = getPromoProgramById(promoId);
    if (visit == null || user == null || promo == null || !photoCaptured) {
      return null;
    }

    final now = DateTime.now();
    final promoCheck = PromoCheck(
      id: 'promo_check_${now.microsecondsSinceEpoch}',
      promoId: promo.id,
      promoName: promo.name,
      visitId: visit.id,
      customerId: visit.customerId,
      employeeId: user.employeeId,
      branchId: user.branchId,
      complianceStatus: complianceStatus,
      photoCaptured: photoCaptured,
      notes: notes,
      syncStatus: SyncStatus.queued,
      createdAt: now,
    );

    _promoChecks.add(promoCheck);
    final customer = getCustomerById(promoCheck.customerId);
    _createSyncItem(
      id: 'sync_${now.microsecondsSinceEpoch}',
      type: SyncItemType.promoCheck,
      referenceId: promoCheck.id,
      title: 'Promo Check',
      description: '${customer?.name ?? 'Customer'} ${promo.name}',
      now: now,
    );

    notifyListeners();
    return promoCheck;
  }

  // ---------------------------------------------------------------------------
  // Competitor Activities
  // ---------------------------------------------------------------------------

  List<CompetitorActivity> getCompetitorActivities() {
    final user = _activeUser;
    if (user == null) {
      return const [];
    }

    final activities =
        _competitorActivities
            .where((activity) => activity.employeeId == user.employeeId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(activities);
  }

  CompetitorActivity? getCompetitorActivityById(String activityId) {
    for (final activity in _competitorActivities) {
      if (activity.id == activityId) {
        return activity;
      }
    }
    return null;
  }

  CompetitorActivity? submitCompetitorActivity({
    required String competitorBrandId,
    required String competitorProductId,
    required CompetitorActivityType activityType,
    required bool photoCaptured,
    int? price,
    String promoDescription = '',
    String notes = '',
  }) {
    final visit = activeVisit;
    final user = _activeUser;
    final brand = getBrandById(competitorBrandId);
    final product = getProductById(competitorProductId);
    if (visit == null ||
        user == null ||
        brand == null ||
        product == null ||
        brand.brandType != BrandType.competitorBrand ||
        product.productType != ProductType.competitorProduct ||
        product.isSellable ||
        product.brandId != brand.id ||
        !photoCaptured ||
        (price != null && price < 0)) {
      return null;
    }

    final now = DateTime.now();
    final activity = CompetitorActivity(
      id: 'comp_${now.microsecondsSinceEpoch}',
      visitId: visit.id,
      customerId: visit.customerId,
      employeeId: user.employeeId,
      branchId: user.branchId,
      competitorBrandId: brand.id,
      competitorBrand: brand.name,
      competitorProductId: product.id,
      competitorProduct: product.name,
      activityType: activityType,
      price: price,
      promoDescription: promoDescription.trim(),
      photoCaptured: photoCaptured,
      notes: notes.trim(),
      syncStatus: SyncStatus.queued,
      createdAt: now,
    );

    _competitorActivities.add(activity);
    final customer = getCustomerById(activity.customerId);
    _createSyncItem(
      id: 'sync_${now.microsecondsSinceEpoch}',
      type: SyncItemType.competitorActivity,
      referenceId: activity.id,
      title: 'Competitor Activity',
      description:
          '${customer?.name ?? 'Customer'} ${activity.competitorBrand} ${activity.activityType.label}',
      now: now,
    );

    notifyListeners();
    return activity;
  }

  // ---------------------------------------------------------------------------
  // Planogram Checks
  // ---------------------------------------------------------------------------

  List<PlanogramCheck> getPlanogramChecks() {
    final user = _activeUser;
    if (user == null) {
      return const [];
    }

    final checks =
        _planogramChecks
            .where((check) => check.employeeId == user.employeeId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(checks);
  }

  PlanogramCheck? getPlanogramCheckById(String checkId) {
    for (final check in _planogramChecks) {
      if (check.id == checkId) {
        return check;
      }
    }
    return null;
  }

  PlanogramCheck? submitPlanogramCheck({
    required bool beforePhotoCaptured,
    required ShelfArea shelfArea,
    required List<PlanogramOwnProductRow> ownProductRows,
    required List<PlanogramCompetitorProductRow> competitorProductRows,
    required PlanogramMainIssue mainIssue,
    required MerchandiserActionTaken actionTaken,
    required bool afterPhotoCaptured,
    required PlanogramComplianceStatus complianceStatus,
    required List<String> missingSkus,
    String notes = '',
  }) {
    final visit = activeVisit;
    final user = _activeUser;
    if (visit == null ||
        user == null ||
        !beforePhotoCaptured ||
        ownProductRows.isEmpty ||
        (actionTaken != MerchandiserActionTaken.noActionTaken &&
            !afterPhotoCaptured)) {
      return null;
    }

    for (final row in ownProductRows) {
      final product = getProductById(row.productId);
      if (product == null ||
          product.productType != ProductType.ownProduct ||
          !product.isSellable ||
          row.facingCount < 0) {
        return null;
      }
    }

    for (final row in competitorProductRows) {
      final brand = getBrandById(row.brandId);
      final product = getProductById(row.productId);
      if (brand == null ||
          product == null ||
          brand.brandType != BrandType.competitorBrand ||
          product.productType != ProductType.competitorProduct ||
          product.isSellable ||
          product.brandId != brand.id ||
          row.facingCount < 0) {
        return null;
      }
    }

    final now = DateTime.now();
    final check = PlanogramCheck(
      id: 'plano_${now.microsecondsSinceEpoch}',
      visitId: visit.id,
      customerId: visit.customerId,
      employeeId: user.employeeId,
      branchId: user.branchId,
      beforePhotoCaptured: beforePhotoCaptured,
      shelfArea: shelfArea,
      ownProductRows: List.unmodifiable(ownProductRows),
      missingSkus: List.unmodifiable(missingSkus),
      competitorProductRows: List.unmodifiable(competitorProductRows),
      mainIssue: mainIssue,
      actionTaken: actionTaken,
      afterPhotoCaptured: afterPhotoCaptured,
      complianceStatus: complianceStatus,
      notes: notes.trim(),
      syncStatus: SyncStatus.queued,
      createdAt: now,
    );

    _planogramChecks.add(check);
    final customer = getCustomerById(check.customerId);
    _createSyncItem(
      id: 'sync_${now.microsecondsSinceEpoch}',
      type: SyncItemType.planogramCheck,
      referenceId: check.id,
      title: 'Planogram Check',
      description:
          '${customer?.name ?? 'Customer'} ${check.complianceStatus.label}',
      now: now,
    );

    notifyListeners();
    return check;
  }

  // ---------------------------------------------------------------------------
  // Stock Checks
  // ---------------------------------------------------------------------------

  List<StockCheck> getStockChecks() {
    final user = _activeUser;
    if (user == null) {
      return const [];
    }

    final checks =
        _stockChecks
            .where((check) => check.employeeId == user.employeeId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(checks);
  }

  StockCheck? getStockCheckById(String checkId) {
    for (final check in _stockChecks) {
      if (check.id == checkId) {
        return check;
      }
    }
    return null;
  }

  StockCheck? submitStockCheck({
    required List<StockCheckItem> items,
    String notes = '',
  }) {
    final visit = activeVisit;
    final user = _activeUser;
    if (visit == null || user == null || items.isEmpty) {
      return null;
    }

    for (final item in items) {
      if (item.productId.isEmpty || item.quantity < 0) {
        return null;
      }
    }

    final now = DateTime.now();
    final check = StockCheck(
      id: 'stock_${now.microsecondsSinceEpoch}',
      visitId: visit.id,
      customerId: visit.customerId,
      employeeId: user.employeeId,
      branchId: user.branchId,
      items: List.unmodifiable(items),
      notes: notes.trim(),
      syncStatus: SyncStatus.queued,
      createdAt: now,
    );

    _stockChecks.add(check);
    final customer = getCustomerById(check.customerId);
    _createSyncItem(
      id: 'sync_${now.microsecondsSinceEpoch}',
      type: SyncItemType.stockCheck,
      referenceId: check.id,
      title: 'Stock Check',
      description: '${customer?.name ?? 'Customer'} ${items.length} products',
      now: now,
    );

    notifyListeners();
    return check;
  }

  // ---------------------------------------------------------------------------
  // Visit Notes & Store Photos
  // ---------------------------------------------------------------------------

  List<VisitNote> getVisitNotesForVisit(String visitId) {
    final notes = _visitNotes.where((note) => note.visitId == visitId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(notes);
  }

  List<StorePhoto> getStorePhotosForVisit(String visitId) {
    final photos =
        _storePhotos.where((photo) => photo.visitId == visitId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(photos);
  }

  VisitNote? saveVisitNote({
    required VisitResult result,
    String notes = '',
    DateTime? followUpDate,
  }) {
    final visit = activeVisit;
    final user = _activeUser;
    if (visit == null ||
        user == null ||
        (result == VisitResult.other && notes.trim().isEmpty)) {
      return null;
    }

    final now = DateTime.now();
    final note = VisitNote(
      id: 'note_${now.microsecondsSinceEpoch}',
      visitId: visit.id,
      customerId: visit.customerId,
      employeeId: user.employeeId,
      branchId: user.branchId,
      result: result,
      notes: notes.trim(),
      followUpDate: followUpDate,
      syncStatus: SyncStatus.queued,
      createdAt: now,
    );

    _visitNotes.add(note);
    final customer = getCustomerById(note.customerId);
    _createSyncItem(
      id: 'sync_${now.microsecondsSinceEpoch}',
      type: SyncItemType.visitNote,
      referenceId: note.id,
      title: 'Visit Note',
      description: '${customer?.name ?? 'Customer'} ${result.label}',
      now: now,
    );

    notifyListeners();
    return note;
  }

  StorePhoto? saveStorePhoto({
    required StorePhotoType photoType,
    required bool photoCaptured,
    String notes = '',
  }) {
    final visit = activeVisit;
    final user = _activeUser;
    if (visit == null || user == null || !photoCaptured) {
      return null;
    }

    final now = DateTime.now();
    final photo = StorePhoto(
      id: 'photo_${now.microsecondsSinceEpoch}',
      visitId: visit.id,
      customerId: visit.customerId,
      employeeId: user.employeeId,
      branchId: user.branchId,
      photoType: photoType,
      photoCaptured: photoCaptured,
      notes: notes.trim(),
      syncStatus: SyncStatus.queued,
      createdAt: now,
    );

    _storePhotos.add(photo);
    final customer = getCustomerById(photo.customerId);
    _createSyncItem(
      id: 'sync_${now.microsecondsSinceEpoch}',
      type: SyncItemType.storePhoto,
      referenceId: photo.id,
      title: 'Store Photo',
      description: '${customer?.name ?? 'Customer'} ${photoType.label}',
      now: now,
    );

    notifyListeners();
    return photo;
  }

  // ---------------------------------------------------------------------------
  // End Visit
  // ---------------------------------------------------------------------------

  Visit? endActiveVisit() {
    final visit = activeVisit;
    if (visit == null) {
      return null;
    }

    final now = DateTime.now();
    final completedVisit = visit.copyWith(
      status: VisitStatus.completed,
      checkOutAt: now,
    );
    final visitIndex = _visits.indexWhere((item) => item.id == visit.id);
    if (visitIndex < 0) {
      return null;
    }

    _visits[visitIndex] = completedVisit;
    _lastCompletedVisit = completedVisit;
    final callPlan = getCallPlanById(visit.callPlanId);
    if (callPlan != null) {
      _replaceCallPlan(callPlan.copyWith(status: CallPlanStatus.completed));
    }

    final customer = getCustomerById(visit.customerId);
    _createSyncItem(
      id: 'sync_${now.microsecondsSinceEpoch}',
      type: SyncItemType.visitCheckOut,
      referenceId: visit.id,
      title: 'Visit Check-out',
      description: customer?.name ?? 'Customer visit',
      now: now,
    );

    notifyListeners();
    return completedVisit;
  }

  // ---------------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------------

  List<SyncItem> getSyncItems() {
    final items = [..._syncItems]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(items);
  }

  SyncItem? getSyncItemById(String syncItemId) {
    for (final item in _syncItems) {
      if (item.id == syncItemId) {
        return item;
      }
    }
    return null;
  }

  List<SyncEvent> getSyncEventsForItem(String syncItemId) {
    return List.unmodifiable(_syncEvents[syncItemId] ?? const []);
  }

  SyncCenterSnapshot getSyncCenterSnapshot() {
    return SyncCenterSnapshot(
      pendingSync: _syncItems
          .where(
            (item) =>
                item.status == SyncStatus.queued ||
                item.status == SyncStatus.syncing,
          )
          .length,
      syncedToday: _syncItems
          .where(
            (item) =>
                item.status == SyncStatus.synced &&
                item.syncedAt != null &&
                _isSameDay(item.syncedAt!, DateTime.now()),
          )
          .length,
      failedSync: _syncItems
          .where((item) => item.status == SyncStatus.failed)
          .length,
      lastSyncAt: _lastSyncAt,
    );
  }

  Future<int> syncQueuedItems() async {
    final indexes = <int>[];
    for (var index = 0; index < _syncItems.length; index += 1) {
      if (_syncItems[index].status == SyncStatus.queued) {
        indexes.add(index);
        final now = DateTime.now();
        _syncItems[index] = _syncItems[index].copyWith(
          status: SyncStatus.syncing,
          syncingAt: now,
          lastAttemptAt: now,
          clearErrorMessage: true,
        );
        _addSyncEvent(
          _syncItems[index].id,
          SyncEventType.syncStarted,
          'Sync started',
          now,
        );
      }
    }

    if (indexes.isEmpty) {
      return 0;
    }

    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final now = DateTime.now();
    for (final index in indexes) {
      if (_syncItems[index].status == SyncStatus.syncing) {
        _syncItems[index] = _syncItems[index].copyWith(
          status: SyncStatus.synced,
          syncedAt: now,
          attemptCount: _syncItems[index].attemptCount + 1,
          clearErrorMessage: true,
        );
        _addSyncEvent(
          _syncItems[index].id,
          SyncEventType.sentToServer,
          'Sent to server',
          now,
        );
        _addSyncEvent(
          _syncItems[index].id,
          SyncEventType.syncSuccess,
          'Sync successful',
          now,
        );
      }
    }
    _lastSyncAt = now;
    notifyListeners();
    return indexes.length;
  }

  Future<int> retryFailedSyncItems() async {
    final indexes = <int>[];
    for (var index = 0; index < _syncItems.length; index += 1) {
      if (_syncItems[index].status == SyncStatus.failed) {
        indexes.add(index);
        final now = DateTime.now();
        _syncItems[index] = _syncItems[index].copyWith(
          status: SyncStatus.syncing,
          syncingAt: now,
          lastAttemptAt: now,
          clearErrorMessage: true,
        );
        _addSyncEvent(
          _syncItems[index].id,
          SyncEventType.retryStarted,
          'Retry started',
          now,
        );
      }
    }

    if (indexes.isEmpty) {
      return 0;
    }

    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final now = DateTime.now();
    for (final index in indexes) {
      if (_syncItems[index].status == SyncStatus.syncing) {
        _syncItems[index] = _syncItems[index].copyWith(
          status: SyncStatus.synced,
          syncedAt: now,
          attemptCount: _syncItems[index].attemptCount + 1,
          clearErrorMessage: true,
        );
        _addSyncEvent(
          _syncItems[index].id,
          SyncEventType.sentToServer,
          'Sent to server',
          now,
        );
        _addSyncEvent(
          _syncItems[index].id,
          SyncEventType.syncSuccess,
          'Sync successful',
          now,
        );
      }
    }
    _lastSyncAt = now;
    notifyListeners();
    return indexes.length;
  }

  Future<bool> retrySyncItem(String syncItemId) async {
    final index = _syncItems.indexWhere((item) => item.id == syncItemId);
    if (index < 0 || _syncItems[index].status != SyncStatus.failed) {
      return false;
    }

    final now = DateTime.now();
    _syncItems[index] = _syncItems[index].copyWith(
      status: SyncStatus.syncing,
      syncingAt: now,
      lastAttemptAt: now,
      clearErrorMessage: true,
    );
    _addSyncEvent(syncItemId, SyncEventType.retryStarted, 'Retry started', now);
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final synced = DateTime.now();
    if (_syncItems[index].status == SyncStatus.syncing) {
      _syncItems[index] = _syncItems[index].copyWith(
        status: SyncStatus.synced,
        syncedAt: synced,
        attemptCount: _syncItems[index].attemptCount + 1,
        clearErrorMessage: true,
      );
      _addSyncEvent(
        syncItemId,
        SyncEventType.sentToServer,
        'Sent to server',
        synced,
      );
      _addSyncEvent(
        syncItemId,
        SyncEventType.syncSuccess,
        'Sync successful',
        synced,
      );
    }
    _lastSyncAt = synced;
    notifyListeners();
    return true;
  }

  bool cancelQueuedSyncItem(String syncItemId) {
    final index = _syncItems.indexWhere((item) => item.id == syncItemId);
    if (index < 0 || _syncItems[index].status != SyncStatus.queued) {
      return false;
    }
    final now = DateTime.now();
    _syncItems[index] = _syncItems[index].copyWith(
      status: SyncStatus.cancelled,
      errorMessage: 'Cancelled locally. Transaction data was kept.',
    );
    _addSyncEvent(
      syncItemId,
      SyncEventType.cancelled,
      'Cancelled by user',
      now,
    );
    notifyListeners();
    return true;
  }

  bool simulateFailedSync() {
    final index = _syncItems.indexWhere(
      (item) => item.status == SyncStatus.queued,
    );
    if (index < 0) {
      return false;
    }
    final now = DateTime.now();
    _syncItems[index] = _syncItems[index].copyWith(
      status: SyncStatus.failed,
      lastAttemptAt: now,
      attemptCount: _syncItems[index].attemptCount + 1,
      errorMessage: 'Network timeout. Please retry.',
    );
    _addSyncEvent(
      _syncItems[index].id,
      SyncEventType.syncFailed,
      'Network timeout',
      now,
    );
    notifyListeners();
    return true;
  }

  bool clearSyncedSyncItems() {
    final before = _syncItems.length;
    final removedIds = _syncItems
        .where((item) => item.status == SyncStatus.synced)
        .map((item) => item.id)
        .toList();
    _syncItems.removeWhere((item) => item.status == SyncStatus.synced);
    for (final id in removedIds) {
      _syncEvents.remove(id);
    }
    if (_syncItems.length == before) {
      return false;
    }
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Visit Summary
  // ---------------------------------------------------------------------------

  VisitSummarySnapshot getVisitSummary(String visitId) {
    final notes = getVisitNotesForVisit(visitId);
    final regularOrders = _salesOrders
        .where(
          (order) =>
              order.visitId == visitId &&
              order.orderType == SalesOrderType.regular,
        )
        .length;
    final canvasOrders = _salesOrders
        .where(
          (order) =>
              order.visitId == visitId &&
              order.orderType == SalesOrderType.canvas,
        )
        .length;

    return VisitSummarySnapshot(
      regularOrderCount: regularOrders,
      canvasOrderCount: canvasOrders,
      salesOrderCount: regularOrders + canvasOrders,
      returnOrderCount: _returnOrders
          .where((returnOrder) => returnOrder.visitId == visitId)
          .length,
      promoCheckCount: _promoChecks
          .where((promoCheck) => promoCheck.visitId == visitId)
          .length,
      competitorActivityCount: _competitorActivities
          .where((activity) => activity.visitId == visitId)
          .length,
      planogramCheckCount: _planogramChecks
          .where((check) => check.visitId == visitId)
          .length,
      stockCheckCount: _stockChecks
          .where((check) => check.visitId == visitId)
          .length,
      storePhotoCount: _storePhotos
          .where((photo) => photo.visitId == visitId)
          .length,
      visitNoteCount: notes.length,
      pendingSyncCount: getPendingSyncCountForVisit(visitId),
      latestVisitNote: notes.isEmpty ? null : notes.first,
    );
  }

  // ---------------------------------------------------------------------------
  // Discount
  // ---------------------------------------------------------------------------

  int calculateDiscount({required int subtotal, required int totalQuantity}) {
    final fixedDiscount = subtotal >= 500000 ? 25000 : 0;
    final quantityDiscount = totalQuantity >= 10
        ? (subtotal * 0.05).round()
        : 0;
    return fixedDiscount > quantityDiscount ? fixedDiscount : quantityDiscount;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  ReturnOrder? _createReturnOrder({
    required ReturnOrderType returnType,
    required String reason,
    required bool photoCaptured,
    String notes = '',
    List<ReturnOrderItem> items = const [],
    ReturnOrderItem? returnedItem,
    ReturnOrderItem? replacementItem,
  }) {
    final visit = activeVisit;
    final user = _activeUser;
    if (visit == null || user == null) {
      return null;
    }

    final now = DateTime.now();
    final returnOrder = ReturnOrder(
      id: 'ret_${now.microsecondsSinceEpoch}',
      returnNumber: 'RT-${now.millisecondsSinceEpoch.toString().substring(5)}',
      returnType: returnType,
      visitId: visit.id,
      customerId: visit.customerId,
      employeeId: user.employeeId,
      branchId: user.branchId,
      items: items,
      returnedItem: returnedItem,
      replacementItem: replacementItem,
      reason: reason,
      notes: notes,
      photoCaptured: photoCaptured,
      syncStatus: SyncStatus.queued,
      createdAt: now,
    );

    _returnOrders.add(returnOrder);
    final customer = getCustomerById(returnOrder.customerId);
    _createSyncItem(
      id: 'sync_${now.microsecondsSinceEpoch}',
      type: returnType == ReturnOrderType.returnOrder
          ? SyncItemType.returnOrder
          : SyncItemType.returnSwapOrder,
      referenceId: returnOrder.id,
      title: returnType.label,
      description: '${customer?.name ?? 'Customer'} $reason',
      now: now,
    );

    notifyListeners();
    return returnOrder;
  }

  void _createSyncItem({
    required String id,
    required SyncItemType type,
    required String referenceId,
    required String title,
    required String description,
    required DateTime now,
  }) {
    final item = SyncItem(
      id: id,
      type: type,
      referenceId: referenceId,
      title: title,
      description: description,
      status: SyncStatus.queued,
      createdAt: now,
      queuedAt: now,
    );
    _syncItems.add(item);
    _syncEvents[id] = [
      SyncEvent(
        eventType: SyncEventType.createdOnDevice,
        timestamp: now,
        message: 'Created on device',
      ),
      SyncEvent(
        eventType: SyncEventType.queued,
        timestamp: now,
        message: 'Queued for sync',
      ),
    ];
  }

  void _addSyncEvent(
    String syncItemId,
    SyncEventType eventType,
    String message,
    DateTime timestamp,
  ) {
    _syncEvents
        .putIfAbsent(syncItemId, () => [])
        .add(
          SyncEvent(
            eventType: eventType,
            timestamp: timestamp,
            message: message,
          ),
        );
  }

  void _ensureCanvasStock() {
    if (_canvasStockByProductId.isNotEmpty) {
      return;
    }
    for (final product in DummyData.products) {
      if (product.productType == ProductType.ownProduct && product.isSellable) {
        _canvasStockByProductId[product.id] = product.canvasStock;
      }
    }
  }

  static String _normalizeName(String value) {
    return value.trim().toLowerCase();
  }

  static bool _isValidCompanyCode(String companyCode) {
    const validCodes = {'demo-distributor', 'demo', 'shela-demo'};
    return validCodes.contains(companyCode.trim().toLowerCase());
  }

  void _replaceCallPlan(CallPlan updatedCallPlan) {
    final index = _callPlans.indexWhere(
      (callPlan) => callPlan.id == updatedCallPlan.id,
    );
    if (index >= 0) {
      _callPlans[index] = updatedCallPlan;
    }
  }

  Set<String> _referenceIdsForVisit(String visitId) {
    return {
      visitId,
      ..._salesOrders
          .where((order) => order.visitId == visitId)
          .map((order) => order.id),
      ..._returnOrders
          .where((returnOrder) => returnOrder.visitId == visitId)
          .map((returnOrder) => returnOrder.id),
      ..._promoChecks
          .where((promoCheck) => promoCheck.visitId == visitId)
          .map((promoCheck) => promoCheck.id),
      ..._competitorActivities
          .where((activity) => activity.visitId == visitId)
          .map((activity) => activity.id),
      ..._planogramChecks
          .where((check) => check.visitId == visitId)
          .map((check) => check.id),
      ..._stockChecks
          .where((check) => check.visitId == visitId)
          .map((check) => check.id),
      ..._visitNotes
          .where((note) => note.visitId == visitId)
          .map((note) => note.id),
      ..._storePhotos
          .where((photo) => photo.visitId == visitId)
          .map((photo) => photo.id),
    };
  }

  static bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
