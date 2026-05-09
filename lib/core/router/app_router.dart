import 'package:go_router/go_router.dart';

import '../../data/repositories/mock_sfa_repository.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/check_in/presentation/check_in_page.dart';
import '../../features/competitor_activity/presentation/competitor_activity_detail_page.dart';
import '../../features/competitor_activity/presentation/competitor_activity_list_page.dart';
import '../../features/competitor_activity/presentation/competitor_activity_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/promo_check/presentation/promo_check_detail_page.dart';
import '../../features/promo_check/presentation/promo_check_list_page.dart';
import '../../features/promo_check/presentation/promo_check_page.dart';
import '../../features/planogram/presentation/planogram_check_detail_page.dart';
import '../../features/planogram/presentation/planogram_check_list_page.dart';
import '../../features/planogram/presentation/planogram_check_page.dart';
import '../../features/return_order/presentation/return_detail_page.dart';
import '../../features/return_order/presentation/return_list_page.dart';
import '../../features/return_order/presentation/return_menu_page.dart';
import '../../features/return_order/presentation/return_order_page.dart';
import '../../features/return_order/presentation/return_success_page.dart';
import '../../features/return_order/presentation/return_swap_order_page.dart';
import '../../features/sales_order/presentation/order_entry_page.dart';
import '../../features/sales_order/presentation/order_success_page.dart';
import '../../features/sales_order/presentation/sales_order_detail_page.dart';
import '../../features/sales_order/presentation/sales_order_list_page.dart';
import '../../features/sales_order/presentation/sales_order_menu_page.dart';
import '../../features/stock_check/presentation/stock_check_detail_page.dart';
import '../../features/stock_check/presentation/stock_check_list_page.dart';
import '../../features/stock_check/presentation/stock_check_page.dart';
import '../../features/store_info/presentation/customer_info_page.dart';
import '../../features/store_info/presentation/order_history_detail_page.dart';
import '../../features/store_info/presentation/order_history_page.dart';
import '../../features/store_info/presentation/product_detail_page.dart';
import '../../features/store_info/presentation/product_price_list_page.dart';
import '../../features/store/presentation/store_page.dart';
import '../../features/sync/presentation/sync_center_page.dart';
import '../../features/sync/presentation/sync_detail_page.dart';
import '../../features/visit_completion/presentation/end_visit_page.dart';
import '../../features/visit_completion/presentation/store_photo_page.dart';
import '../../features/visit_completion/presentation/visit_notes_page.dart';
import '../../features/visit/presentation/customer_selection_page.dart';
import '../../features/visit/presentation/visit_page.dart';
import '../../data/models/sales_order.dart';

class AppRoutes {
  const AppRoutes._();

  static const root = '/';
  static const home = '/home';
  static const login = '/login';
  static const visit = '/visit';
  static const addCallPlan = '/visit/add-call-plan';
  static const checkIn = '/check-in/:callPlanId';
  static const store = '/store';
  static const salesOrderMenu = '/store/sales-order';
  static const regularOrder = '/store/sales-order/regular';
  static const canvasOrder = '/store/sales-order/canvas';
  static const salesOrders = '/sales-orders';
  static const salesOrderDetail = '/sales-orders/:orderId';
  static const orderSuccess = '/sales-orders/:orderId/success';
  static const returnMenu = '/store/return';
  static const returnOrder = '/store/return/order';
  static const returnSwapOrder = '/store/return/swap';
  static const returns = '/returns';
  static const returnDetail = '/returns/:returnOrderId';
  static const returnSuccess = '/returns/:returnOrderId/success';
  static const promoCheck = '/store/promo-check';
  static const promoChecks = '/promo-checks';
  static const promoCheckDetail = '/promo-checks/:promoCheckId';
  static const competitorActivity = '/store/competitor-activity';
  static const competitorActivities = '/competitor-activities';
  static const competitorActivityDetail = '/competitor-activities/:activityId';
  static const planogramCheck = '/store/planogram-check';
  static const planogramChecks = '/planogram-checks';
  static const planogramCheckDetail = '/planogram-checks/:checkId';
  static const stockCheck = '/store/stock-check';
  static const stockChecks = '/stock-checks';
  static const stockCheckDetail = '/stock-checks/:checkId';
  static const productPriceList = '/store/product-price-list';
  static const productDetail = '/store/product-price-list/:productId';
  static const orderHistory = '/store/order-history';
  static const orderHistoryDetail = '/store/order-history/:orderId';
  static const customerInfo = '/store/customer-info';
  static const visitNotes = '/store/visit-notes';
  static const storePhoto = '/store/store-photo';
  static const endVisit = '/store/end-visit';
  static const syncCenter = '/sync-center';
  static const syncDetail = '/sync-center/:syncItemId';

  static String checkInPath(String callPlanId) => '/check-in/$callPlanId';
  static String salesOrderDetailPath(String orderId) =>
      '/sales-orders/$orderId';
  static String orderSuccessPath(String orderId) =>
      '/sales-orders/$orderId/success';
  static String returnDetailPath(String returnOrderId) =>
      '/returns/$returnOrderId';
  static String returnSuccessPath(String returnOrderId) =>
      '/returns/$returnOrderId/success';
  static String promoCheckDetailPath(String promoCheckId) =>
      '/promo-checks/$promoCheckId';
  static String competitorActivityDetailPath(String activityId) =>
      '/competitor-activities/$activityId';
  static String planogramCheckDetailPath(String checkId) =>
      '/planogram-checks/$checkId';
  static String stockCheckDetailPath(String checkId) =>
      '/stock-checks/$checkId';
  static String productDetailPath(String productId) =>
      '/store/product-price-list/$productId';
  static String orderHistoryDetailPath(String orderId) =>
      '/store/order-history/$orderId';
  static String syncDetailPath(String syncItemId) => '/sync-center/$syncItemId';
}

class AppRouter {
  AppRouter(this._repository);

  final MockSfaRepository _repository;

  late final GoRouter config = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: _repository,
    redirect: (context, state) {
      final isLoggedIn = _repository.isAuthenticated;
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isOnLogin) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isOnLogin) {
        return AppRoutes.home;
      }

      if (state.matchedLocation == AppRoutes.root) {
        return isLoggedIn ? AppRoutes.home : AppRoutes.login;
      }

      if (state.matchedLocation == AppRoutes.store &&
          _repository.activeVisit == null) {
        return AppRoutes.visit;
      }

      if (state.matchedLocation.startsWith('/store/sales-order') &&
          _repository.activeVisit == null) {
        return AppRoutes.visit;
      }

      if (state.matchedLocation.startsWith('/store/return') &&
          _repository.activeVisit == null) {
        return AppRoutes.visit;
      }

      if ((state.matchedLocation == AppRoutes.promoCheck ||
              state.matchedLocation == AppRoutes.competitorActivity ||
              state.matchedLocation == AppRoutes.planogramCheck ||
              state.matchedLocation == AppRoutes.stockCheck ||
              state.matchedLocation.startsWith('/store/product-price-list') ||
              state.matchedLocation.startsWith('/store/order-history') ||
              state.matchedLocation == AppRoutes.customerInfo ||
              state.matchedLocation == AppRoutes.visitNotes ||
              state.matchedLocation == AppRoutes.storePhoto ||
              state.matchedLocation == AppRoutes.endVisit) &&
          _repository.activeVisit == null) {
        return AppRoutes.visit;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.login,
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.syncCenter,
        builder: (context, state) => const SyncCenterPage(),
      ),
      GoRoute(
        path: AppRoutes.syncDetail,
        builder: (context, state) => SyncDetailPage(
          syncItemId: state.pathParameters['syncItemId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.visit,
        builder: (context, state) => const VisitPage(),
      ),
      GoRoute(
        path: AppRoutes.addCallPlan,
        builder: (context, state) => const CustomerSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.checkIn,
        builder: (context, state) =>
            CheckInPage(callPlanId: state.pathParameters['callPlanId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.store,
        builder: (context, state) => const StorePage(),
      ),
      GoRoute(
        path: AppRoutes.salesOrderMenu,
        builder: (context, state) => const SalesOrderMenuPage(),
      ),
      GoRoute(
        path: AppRoutes.regularOrder,
        builder: (context, state) =>
            const OrderEntryPage(orderType: SalesOrderType.regular),
      ),
      GoRoute(
        path: AppRoutes.canvasOrder,
        builder: (context, state) =>
            const OrderEntryPage(orderType: SalesOrderType.canvas),
      ),
      GoRoute(
        path: AppRoutes.salesOrders,
        builder: (context, state) => const SalesOrderListPage(),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        builder: (context, state) =>
            OrderSuccessPage(orderId: state.pathParameters['orderId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.salesOrderDetail,
        builder: (context, state) => SalesOrderDetailPage(
          orderId: state.pathParameters['orderId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.returnMenu,
        builder: (context, state) => const ReturnMenuPage(),
      ),
      GoRoute(
        path: AppRoutes.returnOrder,
        builder: (context, state) => const ReturnOrderPage(),
      ),
      GoRoute(
        path: AppRoutes.returnSwapOrder,
        builder: (context, state) => const ReturnSwapOrderPage(),
      ),
      GoRoute(
        path: AppRoutes.returns,
        builder: (context, state) => const ReturnListPage(),
      ),
      GoRoute(
        path: AppRoutes.returnSuccess,
        builder: (context, state) => ReturnSuccessPage(
          returnOrderId: state.pathParameters['returnOrderId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.returnDetail,
        builder: (context, state) => ReturnDetailPage(
          returnOrderId: state.pathParameters['returnOrderId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.promoCheck,
        builder: (context, state) => const PromoCheckPage(),
      ),
      GoRoute(
        path: AppRoutes.promoChecks,
        builder: (context, state) => const PromoCheckListPage(),
      ),
      GoRoute(
        path: AppRoutes.promoCheckDetail,
        builder: (context, state) => PromoCheckDetailPage(
          promoCheckId: state.pathParameters['promoCheckId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.competitorActivity,
        builder: (context, state) => const CompetitorActivityPage(),
      ),
      GoRoute(
        path: AppRoutes.competitorActivities,
        builder: (context, state) => const CompetitorActivityListPage(),
      ),
      GoRoute(
        path: AppRoutes.competitorActivityDetail,
        builder: (context, state) => CompetitorActivityDetailPage(
          activityId: state.pathParameters['activityId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.planogramCheck,
        builder: (context, state) => const PlanogramCheckPage(),
      ),
      GoRoute(
        path: AppRoutes.planogramChecks,
        builder: (context, state) => const PlanogramCheckListPage(),
      ),
      GoRoute(
        path: AppRoutes.planogramCheckDetail,
        builder: (context, state) => PlanogramCheckDetailPage(
          checkId: state.pathParameters['checkId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.stockCheck,
        builder: (context, state) => const StockCheckPage(),
      ),
      GoRoute(
        path: AppRoutes.stockChecks,
        builder: (context, state) => const StockCheckListPage(),
      ),
      GoRoute(
        path: AppRoutes.stockCheckDetail,
        builder: (context, state) => StockCheckDetailPage(
          checkId: state.pathParameters['checkId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.productPriceList,
        builder: (context, state) => const ProductPriceListPage(),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (context, state) => ProductDetailPage(
          productId: state.pathParameters['productId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        builder: (context, state) => const OrderHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.orderHistoryDetail,
        builder: (context, state) => OrderHistoryDetailPage(
          orderId: state.pathParameters['orderId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.customerInfo,
        builder: (context, state) => const CustomerInfoPage(),
      ),
      GoRoute(
        path: AppRoutes.visitNotes,
        builder: (context, state) => const VisitNotesPage(),
      ),
      GoRoute(
        path: AppRoutes.storePhoto,
        builder: (context, state) => const StorePhotoPage(),
      ),
      GoRoute(
        path: AppRoutes.endVisit,
        builder: (context, state) => const EndVisitPage(),
      ),
    ],
  );
}
