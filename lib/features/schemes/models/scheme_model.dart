class SchemeModel {
  final String id;
  final String name;
  final String description;
  final String category; // Farmer, Artisan, MSME, General
  final String icon;
  final String eligibility;
  final List<String> documents;
  final String status; // Available, Apply Now, Closed
  final bool isQuickApply;

  /// "Government" or "Private" — who runs the scheme.
  final String type;

  /// "Schemes", "Insurance" or "Scholarships" — what the entry is.
  final String kind;

  /// Department / office where the application file is processed.
  final String department;

  /// Approximate number of working days until a result is declared.
  final int processingDays;

  /// Nominal in-app application service fee charged via EcoBharatPay.
  final double applicationFeeInr;

  /// Per-scheme documents the applicant must provide (numbers, IDs or file
  /// uploads). Every non-optional field must be filled before the captcha and
  /// email verification steps unlock.
  final List<SchemeDocumentField> documentFields;

  const SchemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.eligibility,
    required this.documents,
    required this.status,
    this.isQuickApply = false,
    this.type = 'Government',
    this.kind = 'Schemes',
    this.department = 'Department of Rural Development',
    this.processingDays = 15,
    this.applicationFeeInr = 49,
    this.documentFields = const [],
  });
}

/// One document requirement of a scheme: either a value the applicant types in
/// (registration numbers, IDs) or a file they attach.
class SchemeDocumentField {
  final String label;

  /// "text" (typed value) or "upload" (attached file/photo).
  final String kind;

  /// Free-text helper, e.g. the expected format of the number.
  final String hint;

  final bool optional;

  const SchemeDocumentField({
    required this.label,
    this.kind = 'text',
    this.hint = '',
    this.optional = false,
  });
}


const List<SchemeModel> kSchemes = [
  SchemeModel(
    id: 'pm-kisan',
    name: 'PM-KISAN',
    description: 'Income support of ₹6,000 per year in three instalments to eligible farmer families.',
    category: 'Farmer',
    icon: '🌾',
    eligibility: 'All landholding farmer families with cultivable land',
    documents: ['Aadhaar', 'Land Records', 'Bank Account'],
    status: 'Available',
    isQuickApply: true,
    type: 'Government',
    kind: 'Schemes',
    department: 'Dept. of Agriculture & Farmers Welfare',
    processingDays: 15,
    applicationFeeInr: 49,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number', hint: '12-digit Aadhaar'),
      SchemeDocumentField(label: 'Land Record (7/12 or Khatauni)', kind: 'upload'),
      SchemeDocumentField(label: 'Bank Account Number / IFSC'),
    ],
  ),
  SchemeModel(
    id: 'pm-fasal',
    name: 'PM Fasal Bima Yojana',
    description: 'Crop insurance against natural calamities, pests and diseases at affordable premium.',
    category: 'Farmer',
    icon: '🛡️',
    eligibility: 'All farmers including sharecroppers & tenant farmers',
    documents: ['Aadhaar', 'Land Records', 'Bank Account', 'Sowing Certificate'],
    status: 'Available',
    type: 'Government',
    kind: 'Insurance',
    department: 'PMFBY Cell, Dept. of Agriculture',
    processingDays: 20,
    applicationFeeInr: 49,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number', hint: '12-digit Aadhaar'),
      SchemeDocumentField(label: 'Land Record / Tenancy Proof', kind: 'upload'),
      SchemeDocumentField(label: 'Bank Account Number / IFSC'),
      SchemeDocumentField(label: 'Sowing Certificate', kind: 'upload'),
    ],
  ),
  SchemeModel(
    id: 'pm-vishwakarma',
    name: 'PM Vishwakarma Yojana',
    description: 'Support for artisans and craftspeople with training, tools, and credit up to ₹3 lakh.',
    category: 'Artisan',
    icon: '🛠️',
    eligibility: 'Artisans in 18 traditional trades, age 18+',
    documents: ['Aadhaar', 'Bank Account', 'Ration Card', 'Skill Certificate'],
    status: 'Available',
    isQuickApply: true,
    type: 'Government',
    kind: 'Schemes',
    department: 'Ministry of MSME (Vishwakarma Cell)',
    processingDays: 25,
    applicationFeeInr: 49,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number', hint: '12-digit Aadhaar'),
      SchemeDocumentField(label: 'Bank Account Number / IFSC'),
      SchemeDocumentField(label: 'Ration Card', kind: 'upload'),
      SchemeDocumentField(label: 'Trade / Skill Certificate', kind: 'upload', optional: true),
    ],
  ),
  SchemeModel(
    id: 'sfurti',
    name: 'SFURTI',
    description: 'Scheme of Fund for Regeneration of Traditional Industries to set up clusters.',
    category: 'Artisan',
    icon: '🏭',
    eligibility: 'Traditional industry clusters / artisans',
    documents: ['Cluster Registration', 'Aadhaar', 'Bank Details'],
    status: 'Apply Now',
    type: 'Government',
    kind: 'Schemes',
    department: 'SFURTI Cell, Ministry of MSME',
    processingDays: 30,
    applicationFeeInr: 99,
    documentFields: [
      SchemeDocumentField(label: 'Cluster Registration Number', kind: 'upload'),
      SchemeDocumentField(label: 'Aadhaar Number'),
      SchemeDocumentField(label: 'Bank Account Number / IFSC'),
    ],
  ),
  SchemeModel(
    id: 'pm-mudra',
    name: 'PM MUDRA Yojana',
    description: 'Collateral-free micro-loans up to ₹20 lakh for small businesses and MSMEs.',
    category: 'MSME',
    icon: '💼',
    eligibility: 'Micro/small enterprises, non-farm income businesses',
    documents: ['Aadhaar', 'Business Plan', 'Bank Statement', 'GSTIN (optional)'],
    status: 'Available',
    isQuickApply: true,
    type: 'Government',
    kind: 'Schemes',
    department: 'MUDRA / Member Lending Institution',
    processingDays: 10,
    applicationFeeInr: 49,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number'),
      SchemeDocumentField(label: 'Business Plan', kind: 'upload'),
      SchemeDocumentField(label: 'Bank Statement (6 months)', kind: 'upload'),
      SchemeDocumentField(label: 'GSTIN', hint: '15-character GSTIN', optional: true),
    ],
  ),
  SchemeModel(
    id: 'cgtmse',
    name: 'CGTMSE',
    description: 'Credit guarantee for loans up to ₹2 crore without collateral for MSMEs.',
    category: 'MSME',
    icon: '🤝',
    eligibility: 'MSMEs with loans approved by member lending institutions',
    documents: ['Loan Sanction Letter', 'MSME Registration', 'GSTIN'],
    status: 'Apply Now',
    type: 'Government',
    kind: 'Schemes',
    department: 'CGTMSE Trust (Ministry of MSME)',
    processingDays: 21,
    applicationFeeInr: 99,
    documentFields: [
      SchemeDocumentField(
        label: 'Loan Sanction Letter',
        kind: 'upload',
        hint: 'Sanction letter issued by the member lending institution',
      ),
      SchemeDocumentField(
        label: 'MSME Registration Number (Udyam)',
        hint: 'Udyam Registration Number (e.g. UDYAM-XX-00-0000000)',
      ),
      SchemeDocumentField(label: 'GSTIN', hint: '15-character GSTIN'),
    ],
  ),
  SchemeModel(
    id: 'ayushman',
    name: 'Ayushman Bharat',
    description: 'Health insurance cover of ₹5 lakh per family per year for secondary & tertiary care.',
    category: 'General',
    icon: '🏥',
    eligibility: 'Families from economically weaker sections (SECC 2011)',
    documents: ['Aadhaar', 'SECC Family ID', 'Ration Card'],
    status: 'Available',
    type: 'Government',
    kind: 'Insurance',
    department: 'National Health Authority (SHA)',
    processingDays: 12,
    applicationFeeInr: 49,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number'),
      SchemeDocumentField(label: 'SECC / Ayushman Family ID'),
      SchemeDocumentField(label: 'Ration Card', kind: 'upload'),
    ],
  ),
  SchemeModel(
    id: 'pm-jandhan',
    name: 'PM Jan Dhan Yojana',
    description: 'Zero-balance bank account with RuPay debit card and accident insurance cover.',
    category: 'General',
    icon: '🏦',
    eligibility: 'Any citizen without existing bank account',
    documents: ['Aadhaar', 'Mobile Number'],
    status: 'Available',
    type: 'Government',
    kind: 'Schemes',
    department: 'Department of Financial Services',
    processingDays: 7,
    applicationFeeInr: 49,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number'),
      SchemeDocumentField(label: 'Mobile Number', hint: '10-digit mobile number'),
    ],
  ),
  SchemeModel(
    id: 'nsp-scholarship',
    name: 'National Scholarship Portal',
    description: 'Central and state scholarships for students of classes 1-12, technical and higher education.',
    category: 'General',
    icon: '🎓',
    eligibility: 'Students enrolled in recognised institutions meeting income criteria',
    documents: ['Aadhaar', 'Income Certificate', 'Previous Marksheet', 'Bank Account'],
    status: 'Available',
    type: 'Government',
    kind: 'Scholarships',
    department: 'Ministry of Education (NSP Cell)',
    processingDays: 30,
    applicationFeeInr: 49,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number'),
      SchemeDocumentField(label: 'Income Certificate', kind: 'upload'),
      SchemeDocumentField(label: 'Previous Marksheet', kind: 'upload'),
      SchemeDocumentField(label: 'Bank Account Number / IFSC'),
    ],
  ),
  SchemeModel(
    id: 'tata-rural-scholarship',
    name: 'Tata Trusts Rural Talent Scholarship',
    description: 'Private scholarship supporting rural students pursuing diploma and degree courses.',
    category: 'General',
    icon: '📚',
    eligibility: 'Rural students with 60%+ marks in the last qualifying exam',
    documents: ['Aadhaar', 'Last Marksheet', 'Bonafide Certificate', 'Income Proof'],
    status: 'Apply Now',
    type: 'Private',
    kind: 'Scholarships',
    department: 'Tata Trusts Education Cell',
    processingDays: 40,
    applicationFeeInr: 49,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number'),
      SchemeDocumentField(label: 'Last Qualifying Marksheet', kind: 'upload'),
      SchemeDocumentField(label: 'Bonafide / Admission Letter', kind: 'upload'),
      SchemeDocumentField(label: 'Family Income Proof', kind: 'upload'),
    ],
  ),
  SchemeModel(
    id: 'reliance-foundation-scholarship',
    name: 'Reliance Foundation Scholarship',
    description: 'Private merit-cum-means scholarship for undergraduate and postgraduate students.',
    category: 'General',
    icon: '✏️',
    eligibility: 'Students with family income up to ₹15 lakh per year',
    documents: ['Aadhaar', 'Marksheets', 'Admission Proof', 'Income Proof'],
    status: 'Available',
    type: 'Private',
    kind: 'Scholarships',
    department: 'Reliance Foundation',
    processingDays: 35,
    applicationFeeInr: 49,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number'),
      SchemeDocumentField(label: 'Latest Marksheet', kind: 'upload'),
      SchemeDocumentField(label: 'Admission Proof', kind: 'upload'),
      SchemeDocumentField(label: 'Family Income Proof', kind: 'upload'),
    ],
  ),
  SchemeModel(
    id: 'icici-crop-shield',
    name: 'ICICI Lombard Crop Shield',
    description: 'Private crop insurance add-on covering hailstorm, fire and post-harvest losses.',
    category: 'Farmer',
    icon: '🌦️',
    eligibility: 'Farmers with a bank account and recorded landholding',
    documents: ['Aadhaar', 'Land Record', 'Bank Account', 'Crop Declaration'],
    status: 'Apply Now',
    type: 'Private',
    kind: 'Insurance',
    department: 'ICICI Lombard General Insurance',
    processingDays: 5,
    applicationFeeInr: 99,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number'),
      SchemeDocumentField(label: 'Land Record', kind: 'upload'),
      SchemeDocumentField(label: 'Bank Account Number / IFSC'),
      SchemeDocumentField(label: 'Crop & Area Declaration', kind: 'upload'),
    ],
  ),
  SchemeModel(
    id: 'hdfc-kisan-suraksha',
    name: 'HDFC ERGO Kisan Suraksha Bima',
    description: 'Private personal-accident and livestock cover designed for rural households.',
    category: 'General',
    icon: '🧾',
    eligibility: 'Any rural household member aged 18-65',
    documents: ['Aadhaar', 'Bank Account', 'Nominee Details'],
    status: 'Available',
    type: 'Private',
    kind: 'Insurance',
    department: 'HDFC ERGO General Insurance',
    processingDays: 4,
    applicationFeeInr: 99,
    documentFields: [
      SchemeDocumentField(label: 'Aadhaar Number'),
      SchemeDocumentField(label: 'Bank Account Number / IFSC'),
      SchemeDocumentField(label: 'Nominee Name & Relation'),
    ],
  ),
  SchemeModel(
    id: 'itc-echoupal-grant',
    name: 'ITC e-Choupal Agri Grant',
    description: 'Private grant supporting value-addition equipment for farmer producer groups.',
    category: 'Farmer',
    icon: '🚜',
    eligibility: 'Farmer producer organisations and self-help groups',
    documents: ['FPO/SHG Registration', 'Aadhaar', 'Bank Account', 'Project Note'],
    status: 'Apply Now',
    type: 'Private',
    kind: 'Schemes',
    department: 'ITC e-Choupal Foundation',
    processingDays: 25,
    applicationFeeInr: 49,
    documentFields: [
      SchemeDocumentField(label: 'FPO / SHG Registration Number', kind: 'upload'),
      SchemeDocumentField(label: 'Aadhaar Number'),
      SchemeDocumentField(label: 'Bank Account Number / IFSC'),
      SchemeDocumentField(label: 'Project Note (1 page)', kind: 'upload', optional: true),
    ],
  ),
];
