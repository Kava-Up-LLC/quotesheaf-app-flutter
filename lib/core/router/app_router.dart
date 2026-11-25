import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/business/views/business_view.dart';
import '../../features/customers/views/customer_detail_view.dart';
import '../../features/customers/views/customer_form_view.dart';
import '../../features/customers/views/customer_picker_view.dart';
import '../../features/customers/views/customers_list_view.dart';
import '../../features/quotes/views/quote_detail_view.dart';
import '../../features/quotes/views/quote_editor_view.dart';
import '../../features/quotes/views/quote_preview_view.dart';
import '../../features/quotes/views/quotes_list_view.dart';
import '../../features/services/views/service_picker_view.dart';
import 'routes.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.quotes,
        builder: (_, _) => const QuotesListView(),
      ),
      GoRoute(
        path: '/quotes/new',
        name: AppRoutes.quoteNew,
        builder: (_, s) => QuoteEditorView(
          quoteKey: AppRoutes.newQuoteKey,
          customerId: s.uri.queryParameters['customerId'],
        ),
      ),
      GoRoute(
        path: '/quotes/:id',
        name: AppRoutes.quoteDetail,
        builder: (_, s) => QuoteDetailView(quoteId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/quotes/:id/edit',
        name: AppRoutes.quoteEdit,
        builder: (_, s) => QuoteEditorView(quoteKey: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/quotes/:id/preview',
        name: AppRoutes.quotePreview,
        builder: (_, s) => QuotePreviewView(quoteId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/quotes/:id/customer',
        name: AppRoutes.quotePickCustomer,
        builder: (_, _) => const CustomerPickerView(),
      ),
      GoRoute(
        path: '/quotes/:id/customer/new',
        name: AppRoutes.quoteNewCustomer,
        builder: (_, _) => const CustomerFormView(returnToQuote: true),
      ),
      GoRoute(
        path: '/quotes/:id/services',
        name: AppRoutes.quoteAddService,
        builder: (_, _) => const ServicePickerView(),
      ),
      GoRoute(
        path: '/customers',
        name: AppRoutes.customers,
        builder: (_, _) => const CustomersListView(),
      ),
      GoRoute(
        path: '/customers/new',
        name: AppRoutes.customerNew,
        builder: (_, _) => const CustomerFormView(),
      ),
      GoRoute(
        path: '/customers/:id',
        name: AppRoutes.customerDetail,
        builder: (_, s) => CustomerDetailView(customerId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customers/:id/edit',
        name: AppRoutes.customerEdit,
        builder: (_, s) => CustomerFormView(customerId: s.pathParameters['id']),
      ),
      GoRoute(
        path: '/business',
        name: AppRoutes.business,
        builder: (_, _) => const BusinessView(),
      ),
    ],
  );
}
