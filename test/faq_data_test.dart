import 'package:eco_sus_rural/features/faq/data/faq_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Public FAQ contains exactly Q1-Q90 in order', () {
    expect(kAllFaqItems.map((item) => item.number),
        orderedEquals(List.generate(90, (index) => index + 1)));
    expect(kAllFaqItems.map((item) => item.question).toSet(), hasLength(90));
    for (final item in kAllFaqItems) {
      expect(item.question, endsWith('?'));
      expect(item.answer.trim(), isNotEmpty);
      for (final marker in [
        'Investor & Partner',
        'Table of Contents',
        '###',
        '=====',
        '*',
      ]) {
        expect('${item.question} ${item.answer}', isNot(contains(marker)),
            reason: 'Q${item.number} must not contain source artifacts');
      }
    }
  });

  test('Categories partition the public questions at source boundaries', () {
    const ranges = [
      [1, 10],
      [11, 20],
      [21, 27],
      [28, 34],
      [35, 40],
      [41, 45],
      [46, 50],
      [51, 70],
      [71, 80],
      [81, 90],
    ];
    expect(kFaqCategories, hasLength(ranges.length));
    for (var index = 0; index < ranges.length; index++) {
      final category = kFaqCategories[index];
      final first = ranges[index][0];
      final last = ranges[index][1];
      expect(category.items.map((item) => item.number),
          orderedEquals(List.generate(last - first + 1, (i) => first + i)));
      for (final item in category.items) {
        expect(item.category, category.title);
        expect(identical(item, kAllFaqItems[item.number - 1]), isTrue);
      }
    }
    expect(kFaqCategories.expand((category) => category.items),
        orderedEquals(kAllFaqItems));
  });

  test('Public questions are not overwritten by investor-number suffixes', () {
    expect(kAllFaqItems[0].question, 'How do I register as a seller?');
    expect(kAllFaqItems[1].question, 'Do I need Aadhaar or any national ID?');
    expect(kAllFaqItems[10].question, 'How do I list my product?');
    expect(kAllFaqItems[39].question, 'Can I track my application status?');
    expect(kAllFaqItems[49].question, 'Can someone misuse my Aadhaar?');
  });

  test('Q41 loan answer is distinct from Q42 bank safety answer', () {
    expect(kAllFaqItems[40].question, 'Can I get a loan through EcoSusRural?');
    expect(
        kAllFaqItems[40].answer,
        'Yes, you can access loans, scholarships, and financial advice with '
        'faster processing if all required documents are submitted.');
    expect(kAllFaqItems[41].question, 'Is my bank account safe?');
    expect(kAllFaqItems[41].answer, contains('limited, read-only access'));
  });

  test('Q81 survives OCR spacing and Q90 stops before investor FAQ', () {
    expect(kAllFaqItems[80].question, 'What tech stack will you use?');
    expect(kAllFaqItems[80].answer, contains('Flutter'));
    expect(kAllFaqItems[89].question, 'How do you detect fraudulent sellers?');
    expect(kAllFaqItems[89].answer,
        'Through proper authentication bank verification, and consumer reports');
  });

  test('Generated category collections cannot be mutated', () {
    expect(() => kFaqCategories.clear(), throwsUnsupportedError);
    expect(() => kFaqCategories.first.items.clear(), throwsUnsupportedError);
    expect(() => kAllFaqItems.clear(), throwsUnsupportedError);
  });
}
