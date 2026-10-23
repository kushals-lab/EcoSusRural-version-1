import pathlib

t = pathlib.Path('eco_sus_rural/lib/features/seller/screens/seller_registration_screen.dart').read_text()
print('Lines:', len(t.splitlines()))
print('Classes:')
for l in t.splitlines():
    s = l.strip()
    if s.startswith('class '):
        print('  ', s)
print()
print('Required methods check:')
reqs = {
    'buildProfileStep': 'Widget _buildProfileStep()',
    'buildTypeStep': 'Widget _buildTypeStep()',
    'buildVerificationStep': 'Widget _buildVerificationStep()',
    'buildConfirmationStep': 'Widget _buildConfirmationStep()',
    'planDetailCard': 'Widget _planDetailCard()',
    'planRow': 'Widget _planRow(',
    'personalizedBuilder': 'Widget _personalizedBuilder()',
    'counterTile': 'Widget _counterTile(',
    'addonToggle': 'Widget _addonToggle(',
    'optionCard': 'Widget _optionCard(',
    'field': 'Widget _field(',
    'infoBox': 'Widget _infoBox(',
    'handleNext': 'Future<void> _handleNext()',
    'completeRegistration': 'Future<void> _completeRegistration()',
    'buildQuotaSummary': 'List<SubscriptionQuotaSummary> _buildQuotaSummary()',
}
for k, v in reqs.items():
    status = 'OK' if v in t else 'MISSING!'
    print('  ' + status + ': ' + k)
print()
print('Critical content checks:')
checks2 = {
    'Google Gemini': 'Google Gemini',
    'Privacy Policy URL': 'policies.google.com/privacy',
    'Terms URL': 'policies.google.com/terms',
    'AgreedTerms field': '_agreedTerms',
    'AgreedGemini field': '_agreedGemini',
    'PersonalizedTotal': '_personalizedTotal',
    'CheckoutAmount': '_checkoutAmount',
    'CheckoutPlanName': '_checkoutPlanName',
    'Employee count': 'employee_count',
    'Member count': 'member_count',
}
for k, v in checks2.items():
    status = 'OK' if v in t else 'MISSING!'
    print('  ' + status + ': ' + k)
