/// Verified in-app scheme dataset for the AI retrieval layer.
/// Copied field-for-field from lib/features/schemes/models/scheme_model.dart
/// (kSchemes) — the only addition is `portal`, restricted to well-known
/// official government/private portals. Eligibility/department/processingDays
/// come from the app catalog itself; rules and deadlines must always be
/// re-verified on the portal before acting (the engine warns on every answer).
'use strict';

const SCHEMES = [
  { id: 'pm-kisan', name: 'PM-KISAN', category: 'Farmer', kind: 'Schemes',
    description: 'Income support of Rs.6,000 per year in three instalments to eligible farmer families.',
    eligibility: 'All landholding farmer families with cultivable land',
    documents: ['Aadhaar', 'Land Records', 'Bank Account'], status: 'Available',
    department: 'Dept. of Agriculture & Farmers Welfare', processingDays: 15,
    portal: 'https://pmkisan.gov.in' },
  { id: 'pm-fasal', name: 'PM Fasal Bima Yojana', category: 'Farmer', kind: 'Insurance',
    description: 'Crop insurance against natural calamities, pests and diseases at affordable premium.',
    eligibility: 'All farmers including sharecroppers and tenant farmers',
    documents: ['Aadhaar', 'Land Records', 'Bank Account', 'Sowing Certificate'], status: 'Available',
    department: 'PMFBY Cell, Dept. of Agriculture', processingDays: 20,
    portal: 'https://pmfby.gov.in' },
  { id: 'pm-vishwakarma', name: 'PM Vishwakarma Yojana', category: 'Artisan', kind: 'Schemes',
    description: 'Support for artisans and craftspeople with training, tools, and credit up to Rs.3 lakh.',
    eligibility: 'Artisans in 18 traditional trades, age 18+',
    documents: ['Aadhaar', 'Bank Account', 'Ration Card', 'Skill Certificate'], status: 'Available',
    department: 'Ministry of MSME (Vishwakarma Cell)', processingDays: 25,
    portal: 'https://pmvishwakarma.gov.in' },
  { id: 'sfurti', name: 'SFURTI', category: 'Artisan', kind: 'Schemes',
    description: 'Scheme of Fund for Regeneration of Traditional Industries to set up clusters.',
    eligibility: 'Traditional industry clusters / artisans',
    documents: ['Cluster Registration', 'Aadhaar', 'Bank Details'], status: 'Apply Now',
    department: 'SFURTI Cell, Ministry of MSME', processingDays: 30,
    portal: 'https://www.msme.gov.in' },
  { id: 'pm-mudra', name: 'PM MUDRA Yojana', category: 'MSME', kind: 'Schemes',
    description: 'Collateral-free micro-loans up to Rs.20 lakh for small businesses and MSMEs.',
    eligibility: 'Micro/small enterprises, non-farm income businesses',
    documents: ['Aadhaar', 'Business Plan', 'Bank Statement', 'GSTIN (optional)'], status: 'Available',
    department: 'MUDRA / Member Lending Institution', processingDays: 10,
    portal: 'https://www.mudra.org.in' },
  { id: 'cgtmse', name: 'CGTMSE', category: 'MSME', kind: 'Schemes',
    description: 'Credit guarantee for loans up to Rs.2 crore without collateral for MSMEs.',
    eligibility: 'MSMEs with loans approved by member lending institutions',
    documents: ['Loan Sanction Letter', 'MSME Registration', 'GSTIN'], status: 'Apply Now',
    department: 'CGTMSE Trust (Ministry of MSME)', processingDays: 21,
    portal: 'https://www.cgtmse.in' },
  { id: 'ayushman', name: 'Ayushman Bharat', category: 'General', kind: 'Insurance',
    description: 'Health insurance cover of Rs.5 lakh per family per year for secondary and tertiary care.',
    eligibility: 'Families from economically weaker sections (SECC 2011)',
    documents: ['Aadhaar', 'SECC Family ID', 'Ration Card'], status: 'Available',
    department: 'National Health Authority (SHA)', processingDays: 12,
    portal: 'https://pmjay.gov.in' },
  { id: 'pm-jandhan', name: 'PM Jan Dhan Yojana', category: 'General', kind: 'Schemes',
    description: 'Zero-balance bank account with RuPay debit card and accident insurance cover.',
    eligibility: 'Any citizen without existing bank account',
    documents: ['Aadhaar', 'Mobile Number'], status: 'Available',
    department: 'Department of Financial Services', processingDays: 7,
    portal: 'https://www.pmjdy.gov.in' },
  { id: 'nsp-scholarship', name: 'National Scholarship Portal', category: 'General', kind: 'Scholarships',
    description: 'Central and state scholarships for students of classes 1-12, technical and higher education.',
    eligibility: 'Students enrolled in recognised institutions meeting income criteria',
    documents: ['Aadhaar', 'Income Certificate', 'Previous Marksheet', 'Bank Account'], status: 'Available',
    department: 'Ministry of Education (NSP Cell)', processingDays: 30,
    portal: 'https://scholarships.gov.in' },
  { id: 'tata-rural-scholarship', name: 'Tata Trusts Rural Talent Scholarship', category: 'General', kind: 'Scholarships',
    description: 'Private scholarship supporting rural students pursuing diploma and degree courses.',
    eligibility: 'Rural students with 60%+ marks in the last qualifying exam',
    documents: ['Aadhaar', 'Last Marksheet', 'Bonafide Certificate', 'Income Proof'], status: 'Apply Now',
    department: 'Tata Trusts Education Cell', processingDays: 40,
    portal: 'https://www.tatatrusts.org' },
  { id: 'reliance-foundation-scholarship', name: 'Reliance Foundation Scholarship', category: 'General', kind: 'Scholarships',
    description: 'Private merit-cum-means scholarship for undergraduate and postgraduate students.',
    eligibility: 'Students with family income up to Rs.15 lakh per year',
    documents: ['Aadhaar', 'Marksheets', 'Admission Proof', 'Income Proof'], status: 'Available',
    department: 'Reliance Foundation', processingDays: 35,
    portal: 'https://reliancefoundation.org' },
];

/** Token-scored keyword search. Returns matches sorted by score, or []. */
function searchSchemes(query, maxResults) {
  const tokens = String(query || '').toLowerCase().split(/[^a-z0-9ऀ-ॿ]+/).filter((t) => t.length > 1);
  if (tokens.length === 0) return [];
  const scored = SCHEMES.map((s) => {
    const hay = [s.name, s.description, s.category, s.kind, s.eligibility, s.department, s.id]
      .join(' ').toLowerCase();
    let score = 0;
    for (const t of tokens) {
      if (s.name.toLowerCase().includes(t)) score += 3;
      else if (s.id.toLowerCase().replace(/-/g, ' ').includes(t)) score += 3;
      else if (hay.includes(t)) score += 1;
    }
    return { scheme: s, score };
  }).filter((r) => r.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, Number.isFinite(maxResults) && maxResults > 0 ? maxResults : 5);
  return scored;
}

module.exports = { SCHEMES, searchSchemes };