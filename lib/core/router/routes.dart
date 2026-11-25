/// Route names (go_router). Pass ids in the path, never objects.
abstract final class AppRoutes {
  static const quotes = 'quotes';
  static const quoteNew = 'quoteNew';
  static const quoteDetail = 'quoteDetail';
  static const quoteEdit = 'quoteEdit';
  static const quotePreview = 'quotePreview';
  static const quotePickCustomer = 'quotePickCustomer';
  static const quoteNewCustomer = 'quoteNewCustomer';
  static const quoteAddService = 'quoteAddService';
  static const customers = 'customers';
  static const customerNew = 'customerNew';
  static const customerDetail = 'customerDetail';
  static const customerEdit = 'customerEdit';
  static const business = 'business';

  /// Editor key for a quote that is not saved yet (`/quotes/new/...`).
  static const newQuoteKey = 'new';
}
