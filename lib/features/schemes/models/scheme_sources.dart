/// Links checked against official sources on 2026-10-24. Link verification is
/// not evidence that a particular applicant's application window is open.
class SchemeSource {
  final String information;
  final String? application;
  final String provider;
  const SchemeSource(this.provider, this.information, [this.application]);
}
const schemeSources = <String, SchemeSource>{
  'sfurti': SchemeSource('Ministry of MSME', 'https://sfurti.msme.gov.in/'),
  'pm-mudra': SchemeSource('Department of Financial Services', 'https://financialservices.gov.in/pradhan-mantri-mudra-yojana-pmmy'),
  'pm-jandhan': SchemeSource('Department of Financial Services', 'https://www.pmjdy.gov.in/files/sliderpdf/ENGLISH/Account-Opening-English.pdf'),

  'ayushman': SchemeSource('National Health Authority', 'https://nha.gov.in/PM-JAY', 'https://beneficiary.nha.gov.in/'),
  'cgtmse': SchemeSource('Ministry of MSME / SIDBI', 'https://my.msme.gov.in/MyMsmeMob/MsmeScheme/Pages/0_2_0.html'),
  'tata-rural-scholarship': SchemeSource('Tata Trusts ? exact named programme unverified', 'https://www.tatatrusts.org/our-work/individual-grants-programme/educational-grants'),
  'itc-echoupal-grant': SchemeSource('ITC ? grant availability unverified', 'https://itcportal.com/itc-businesses/agri-business/itc-e-choupal.html'),

  'pm-kisan': SchemeSource('Ministry of Agriculture & Farmers Welfare', 'https://pmkisan.gov.in/', 'https://www.pmkisan.gov.in/RegistrationFormupdated.aspx'),
  'pm-fasal': SchemeSource('Ministry of Agriculture & Farmers Welfare', 'https://pmfby.gov.in/', 'https://www.pmfby.gov.in/farmerLogin'),
  'pm-vishwakarma': SchemeSource('Ministry of MSME', 'https://www.myscheme.gov.in/schemes/pmv'),
  'nsp-scholarship': SchemeSource('National Scholarship Portal', 'https://scholarships.gov.in/Students', 'https://scholarships.gov.in/Students'),
  'reliance-foundation-scholarship': SchemeSource('Reliance Foundation', 'https://scholarships.reliancefoundation.org/'),
};
