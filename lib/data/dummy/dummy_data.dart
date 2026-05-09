import '../models/brand.dart';
import '../models/customer.dart';
import '../models/order_history.dart';
import '../models/product.dart';
import '../models/promo_check.dart';
import '../models/sales_order.dart';
import '../models/sync_item.dart';
import '../models/user_context.dart';

class DummyData {
  const DummyData._();

  static const activeUser = UserContext(
    userId: 'user_001',
    username: 'budi.sales',
    employeeId: 'emp_001',
    employeeName: 'Budi Santoso',
    tenantId: 'tenant_001',
    tenantName: 'PT Demo Group',
    companyId: 'company_001',
    companyName: 'PT Demo Distributor',
    branchId: 'branch_001',
    branchName: 'Daan Mogot',
    role: 'salesman',
    appCode: 'SHELA_SFA_MOBILE',
    companyCode: 'demo-distributor',
  );

  static final customers = [
    Customer(
      id: 'cust_001',
      branchId: 'branch_001',
      name: 'Toko Sumber Jaya',
      address: 'Jl. Daan Mogot No. 12',
      phone: '081234567001',
      lastVisit: DateTime(2026, 5, 6),
      lastOrderAmount: 750000,
      latitude: -6.1611,
      longitude: 106.7689,
      customerType: 'Retail Store',
    ),
    Customer(
      id: 'cust_002',
      branchId: 'branch_001',
      name: 'Toko Makmur Abadi',
      address: 'Jl. Pesing Raya No. 8',
      phone: '081234567002',
      lastVisit: DateTime(2026, 5, 5),
      lastOrderAmount: 1200000,
      latitude: -6.1662,
      longitude: 106.7781,
      customerType: 'Wholesale',
      notes: 'High-volume store with strong weekly repeat purchases.',
    ),
    Customer(
      id: 'cust_003',
      branchId: 'branch_001',
      name: 'Toko Berkah Jaya',
      address: 'Jl. Jelambar Baru No. 21',
      phone: '081234567003',
      lastVisit: DateTime(2026, 5, 4),
      lastOrderAmount: 500000,
      latitude: -6.1523,
      longitude: 106.7891,
      customerType: 'General Trade',
      notes: 'Small outlet with steady snack category movement.',
    ),
  ];

  static const brands = [
    Brand(
      id: 'brand_own_nabati',
      name: 'Nabati',
      brandType: BrandType.ownBrand,
      status: BrandStatus.active,
    ),
    Brand(
      id: 'brand_comp_tango',
      name: 'Tango',
      brandType: BrandType.competitorBrand,
      status: BrandStatus.active,
    ),
    Brand(
      id: 'brand_comp_roma',
      name: 'Roma',
      brandType: BrandType.competitorBrand,
      status: BrandStatus.active,
    ),
    Brand(
      id: 'brand_comp_khong_guan',
      name: 'Khong Guan',
      brandType: BrandType.competitorBrand,
      status: BrandStatus.active,
    ),
  ];

  static const products = [
    Product(
      id: 'prod_001',
      name: 'Nabati Wafer 50g',
      sku: 'NAB-WFR-50',
      brandId: 'brand_own_nabati',
      brandName: 'Nabati',
      productType: ProductType.ownProduct,
      category: 'Wafer',
      price: 10000,
      canvasStock: 50,
      isSellable: true,
    ),
    Product(
      id: 'prod_002',
      name: 'Nabati Nextar',
      sku: 'NAB-NXT-01',
      brandId: 'brand_own_nabati',
      brandName: 'Nabati',
      productType: ProductType.ownProduct,
      category: 'Biscuit',
      price: 12000,
      canvasStock: 40,
      isSellable: true,
    ),
    Product(
      id: 'prod_003',
      name: 'Richeese Wafer',
      sku: 'RCH-WFR-01',
      brandId: 'brand_own_nabati',
      brandName: 'Nabati',
      productType: ProductType.ownProduct,
      category: 'Wafer',
      price: 15000,
      canvasStock: 25,
      isSellable: true,
    ),
    Product(
      id: 'prod_004',
      name: 'Nabati Richoco',
      sku: 'NAB-RCO-01',
      brandId: 'brand_own_nabati',
      brandName: 'Nabati',
      productType: ProductType.ownProduct,
      category: 'Chocolate',
      price: 11000,
      canvasStock: 30,
      isSellable: true,
    ),
    Product(
      id: 'prod_005',
      name: 'Nabati Ahh',
      sku: 'NAB-AHH-01',
      brandId: 'brand_own_nabati',
      brandName: 'Nabati',
      productType: ProductType.ownProduct,
      category: 'Snack',
      price: 9000,
      canvasStock: 60,
      isSellable: true,
    ),
    Product(
      id: 'comp_prod_001',
      name: 'Tango Wafer 50g',
      sku: 'TGO-WFR-50',
      brandId: 'brand_comp_tango',
      brandName: 'Tango',
      productType: ProductType.competitorProduct,
      category: 'Wafer',
      price: 9500,
      canvasStock: 0,
      isSellable: false,
    ),
    Product(
      id: 'comp_prod_002',
      name: 'Roma Kelapa',
      sku: 'ROM-KLP-01',
      brandId: 'brand_comp_roma',
      brandName: 'Roma',
      productType: ProductType.competitorProduct,
      category: 'Biscuit',
      price: 10000,
      canvasStock: 0,
      isSellable: false,
    ),
    Product(
      id: 'comp_prod_003',
      name: 'Khong Guan Assorted Biscuit',
      sku: 'KHG-AST-01',
      brandId: 'brand_comp_khong_guan',
      brandName: 'Khong Guan',
      productType: ProductType.competitorProduct,
      category: 'Biscuit',
      price: 18000,
      canvasStock: 0,
      isSellable: false,
    ),
  ];

  static final promoPrograms = [
    PromoProgram(
      id: 'promo_001',
      name: 'Nabati Wafer Display Program',
      description:
          'Check whether Nabati Wafer display is installed at front shelf.',
      validUntil: DateTime(2026, 5, 31),
    ),
    PromoProgram(
      id: 'promo_002',
      name: 'Buy 10 Get 5% Program',
      description:
          'Eligible for selected Nabati products with total quantity >= 10.',
      validUntil: DateTime(2026, 5, 31),
    ),
    PromoProgram(
      id: 'promo_003',
      name: 'Minimum Order Discount',
      description: 'Minimum subtotal Rp500.000 gets Rp25.000 discount.',
      validUntil: DateTime(2026, 5, 31),
    ),
  ];

  static final historicalOrders = [
    OrderHistory(
      id: 'hist_001',
      orderNumber: 'SO-HIST-001',
      orderType: SalesOrderType.regular,
      customerId: 'cust_001',
      items: const [
        SalesOrderItem(
          productId: 'prod_001',
          productName: 'Nabati Wafer 50g',
          sku: 'NAB-WFR-50',
          quantity: 30,
          price: 10000,
        ),
        SalesOrderItem(
          productId: 'prod_002',
          productName: 'Nabati Nextar',
          sku: 'NAB-NXT-01',
          quantity: 40,
          price: 12000,
        ),
      ],
      subtotal: 780000,
      discount: 30000,
      grandTotal: 750000,
      syncStatus: SyncStatus.synced,
      createdAt: DateTime(2026, 5, 6, 10, 30),
    ),
    OrderHistory(
      id: 'hist_002',
      orderNumber: 'SO-HIST-002',
      orderType: SalesOrderType.canvas,
      customerId: 'cust_001',
      items: const [
        SalesOrderItem(
          productId: 'prod_004',
          productName: 'Nabati Richoco',
          sku: 'NAB-RCO-01',
          quantity: 50,
          price: 11000,
        ),
      ],
      subtotal: 550000,
      discount: 30000,
      grandTotal: 520000,
      syncStatus: SyncStatus.synced,
      createdAt: DateTime(2026, 5, 1, 11, 15),
    ),
    OrderHistory(
      id: 'hist_003',
      orderNumber: 'SO-HIST-003',
      orderType: SalesOrderType.regular,
      customerId: 'cust_002',
      items: const [
        SalesOrderItem(
          productId: 'prod_003',
          productName: 'Richeese Wafer',
          sku: 'RCH-WFR-01',
          quantity: 80,
          price: 15000,
        ),
      ],
      subtotal: 1200000,
      discount: 0,
      grandTotal: 1200000,
      syncStatus: SyncStatus.synced,
      createdAt: DateTime(2026, 5, 5, 9, 45),
    ),
    OrderHistory(
      id: 'hist_004',
      orderNumber: 'SO-HIST-004',
      orderType: SalesOrderType.regular,
      customerId: 'cust_003',
      items: const [
        SalesOrderItem(
          productId: 'prod_005',
          productName: 'Nabati Ahh',
          sku: 'NAB-AHH-01',
          quantity: 60,
          price: 9000,
        ),
      ],
      subtotal: 540000,
      discount: 40000,
      grandTotal: 500000,
      syncStatus: SyncStatus.synced,
      createdAt: DateTime(2026, 5, 4, 14, 10),
    ),
  ];
}
