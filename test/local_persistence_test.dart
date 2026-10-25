import 'package:eco_sus_rural/features/marketplace/models/product_model.dart';
import 'package:eco_sus_rural/features/marketplace/providers/cart_provider.dart';
import 'package:eco_sus_rural/features/schemes/models/scheme_application_model.dart';
import 'package:eco_sus_rural/core/localization/language_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('cart survives notifier recreation and is isolated by account', () async {
    final product = kSampleProducts.first;
    final first = CartNotifier('alice');
    await first.ready;
    first.addToCart(product, quantity: 2);
    await first.flush();
    first.dispose();

    final reopened = CartNotifier('alice');
    await reopened.ready;
    expect(reopened.state.itemCount, 2);
    expect(reopened.state.items.single.product.id, product.id);

    final other = CartNotifier('bob');
    await other.ready;
    expect(other.state.items, isEmpty);
    reopened.dispose();
    other.dispose();
  });

  test('local scheme record cannot become officially approved by elapsed time', () {
    final application = SchemeApplication(
      id: 'local-1', schemeId: 'scheme-1', schemeName: 'Example',
      schemeIcon: '', kind: 'Schemes', type: 'Government',
      applicantName: 'User', applicantEmail: 'user@example.com',
      department: 'Example', currentDepartment: 'Example',
      documentValues: const {}, feeInr: 0, feePaid: false,
      submittedAt: DateTime(2020), processingDays: 1,
      reviewAt: DateTime(2020, 1, 2),
      outcome: ApplicationStatus.approved,
    );
    expect(application.status, ApplicationStatus.localDraft);
  });

  test('Hindi preference survives notifier recreation and switches back to English', () async {
    final first = LanguageNotifier();
    await first.changeLanguage('hi');
    first.dispose();
    final reopened = LanguageNotifier();
    await reopened.loadSavedLanguage();
    expect(reopened.state.code, 'hi');
    await reopened.changeLanguage('en');
    reopened.dispose();
    final again = LanguageNotifier();
    await again.loadSavedLanguage();
    expect(again.state.code, 'en');
    again.dispose();
  });
}
