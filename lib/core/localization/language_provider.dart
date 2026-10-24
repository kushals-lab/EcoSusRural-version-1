import 'package:flutter/material.dart';



import 'package:flutter_riverpod/flutter_riverpod.dart';



import 'package:shared_preferences/shared_preferences.dart';







import '../glossary/glossary.dart';



import '../translation/translation_engine.dart';



import '../translation/translation_repository.dart';



import 'lang_codes.dart';







/// Supported language codes used by the runtime localization engine.



const List<String> kRuntimeLanguageCodes = [



  'en', 'hi', 'bn', 'te', 'mr', 'ta', 'ur', 'gu', 'kn', 'or', 'ml', 'pa', 'as',



  'bho', 'raj', 'chg', 'kha', 'tlu', 'mizo', 'es', 'fr', 'de',



];







/// Fallback dialect-to-primary mapping for all 60+ regional dialects and foreign languages



const Map<String, String> kDialectToParent = {
  // English regional dialect variants fallback chain
  'en-us': 'en',
  'en-gb': 'en',
  'en-in': 'en-gb',
  'en-au': 'en-gb',

  'awa': 'hi',



  'bns': 'hi',



  'gbm': 'hi',



  'kfy': 'hi',



  'bgc': 'hi',



  'mag': 'bho',



  'mai': 'hi',



  'anp': 'hi',



  'sjp': 'hi',



  'mwr': 'raj',



  'mtr': 'raj',



  'wbk': 'raj',



  'mup': 'hi',



  'noe': 'hi',



  'hlb': 'chg',



  'gon': 'te',



  'tcy': 'kn',



  'kfa': 'kn',



  'azp': 'ta',



  'bfy': 'ta',



  'doi': 'pa',



  'ks': 'ur',



  'ne': 'hi',



  'sa': 'hi',



  'kok': 'mr',



  'sd': 'ur',



  'sat': 'bn',



  'hoc': 'hi',



  'unr': 'bn',



  'kru': 'hi',



  'svr': 'te',



  'nag': 'as',



  'njo': 'en',



  'njm': 'en',



  'trp': 'bn',



  'lep': 'en',



  'lif': 'hi',



  'sip': 'hi',



  'lbj': 'ur',



  'mon': 'hi',



  'kha': 'en',



  'grt': 'en',



  'lus': 'en',



  'brx': 'as',



  'mni': 'bn',



  'zh': 'en',



  'ja': 'en',



  'ar': 'ur',



  'ru': 'en',



  'pt': 'es',



  'it': 'es',



  'ko': 'en',



  'id': 'en',



  'th': 'en',



  'vi': 'en',



  'tr': 'en',



  'nl': 'de',



  'pl': 'en',



};







/// Master dictionary of localized strings covering all platform modules



const Map<String, Map<String, String>> _localizedStrings = {



  'en': {



    // General / Navigation



    'appName': 'EcoSusRural',



    'tagline': 'Ecology · Sustainability · Rural Empowerment',



    'welcome': 'Welcome to EcoSusRural!',



    'selectLanguage': 'Select Language',



    'searchLanguage': 'Search language...',



    'confirmContinue': 'Confirm & Continue',



    'changeLanguage': 'Change Language',



    'acceptContinue': 'Accept & Continue',



    'phoneLogin': 'Login with Mobile',



    'enterOtp': 'Enter OTP',



    'verifyContinue': 'Verify & Continue',



    'setupProfile': 'Setup Farm Profile',



    'completeProfile': 'Complete Setup',



    'home': 'Home',



    'market': 'Market',



    'learn': 'Learn',



    'services': 'Services',




    'smartDryer': 'Smart Dryer',



    'smartDryerBatchTitle': 'Drying batches',



    'smartDryerNewBatch': 'New batch',



    'searchServices': 'Search services...',



    'ecoPay': 'EcoPay',



    'messages': 'Messages',



    'pinned': 'Pinned',



    'noMessages': 'No messages',



    'startChat': 'Start a new conversation',



    'typeMessage': 'Type a message...',



    'transfer': 'Send Money',



    'balance': 'Balance',



    'totalBalance': 'Total Balance',



    'available': 'Available',



    'pending': 'Pending',



    'pendingAmount': 'pending',



    'availableAmount': 'Available: ',



    'balanceAmount': 'Rs 1,250.00',



    'quickActions': 'Quick Actions',



    'scan': 'Scan',



    'request': 'Request',



    'addMoney': 'Add Money',



    'scanPay': 'Scan & Pay',



    'transactions': 'Transactions',



    'paymentLinks': 'Payment Links',



    'createLink': 'Create Payment Link',



    'note': 'Note',



    'addNote': 'Add a note',



    'generateLink': 'Generate Link',



    'yourLinks': 'Your Payment Links',



    'enterPhone': 'Enter phone number',



    'amount': 'Amount',



    'sendMoney': 'Send Money',



    'ride': 'Ride',



    'enterPickup': 'Enter pickup location',



    'enterDrop': 'Enter drop location',



    'bike': 'Bike',



    'auto': 'Auto',



    'cab': 'Cab',



    'rideOptions': 'Ride Options',



    'bookRide': 'Book Ride',



    'flights': 'Flights',



    'tripType': 'Trip Type',



    'oneWay': 'One Way',



    'roundTrip': 'Round Trip',



    'multiCity': 'Multi City',



    'from': 'From',



    'to': 'To',



    'departure': 'Departure',



    'return': 'Return',



    'returnDate': 'Return Date',



    'searchFlights': 'Search Flights',



    'topDestinations': 'Top Destinations',



    'trains': 'Trains',



    'fromStation': 'From Station',



    'toStation': 'To Station',



    'enterStation': 'Enter station',



    'journeyDate': 'Journey Date',



    'travelClass': 'Travel Class',



    'sleeper': 'Sleeper',



    'ac3Tier': 'AC 3 Tier',



    'ac2Tier': 'AC 2 Tier',



    'ac1Tier': 'AC 1 Tier',



    'firstClass': 'First Class',



    'searchTrains': 'Search Trains',



    'popularRoutes': 'Popular Routes',



    'health': 'Health',



    'specialty': 'Specialty',



    'enterSpecialty': 'Enter specialty',



    'location': 'Location',



    'enterLocation': 'Enter location',



    'searchDoctors': 'Search Doctors',



    'topDoctors': 'Top Doctors',



    'online': 'Online',



    'food': 'Food',



    'searchRestaurants': 'Search restaurants...',



    'all': 'All',



    'veg': 'Veg',



    'nonVeg': 'Non-Veg',



    'desserts': 'Desserts',



    'drinks': 'Drinks',



    'nearbyRestaurants': 'Nearby Restaurants',



    'searchCourses': 'Search courses',



    'categories': 'Categories',



    'farming': 'Farming',



    'business': 'Business',



    'healthLearn': 'Health',



    'literacy': 'Literacy',



    'crafts': 'Crafts',



    'recommendedCourses': 'Recommended Courses',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'Profile',



    'seller': 'Seller Hub',



    'next': 'Next',



    'back': 'Back',



    'cancel': 'Cancel',



    'submit': 'Submit',



    'save': 'Save',



    'apply': 'Apply Now',



    'viewAll': 'View All',



    'search': 'Search...',



    'getStarted': 'Get Started',



    'skip': 'Skip',



    'buyerRole': 'Buyer',



    'sellerRole': 'Seller',



    'welcomeBack': 'Welcome back!',



    'loginSubtitle': 'Login with your registered mobile number to continue. Your account stays signed in on this device until you log out.',



    'mobileNumber': 'Mobile Number',



    'mobileRequired': 'Please enter your mobile number',



    'mobileInvalid': 'Enter a valid 10-digit Indian mobile number',



    'sendOtp': 'Send OTP',



    'createAccountLink': 'New here? Create Account',



    'personalDetailsStep': 'Step 1: Personal Details',



    'fullLegalName': 'Full Legal Name (as per National ID)',



    'nameRequired': 'Name is required',



    'phoneInvalid': 'Enter valid 10-digit number',



    'emailAddress': 'Email Address',



    'emailInvalid': 'Enter valid email',



    'nationalIdStep': 'Step 2: National ID Verification',



    'nationalId': 'National ID (Aadhaar)',



    'nationalIdInvalid': 'Enter valid 12-digit National ID',



    'verifyWithDigiLocker': 'Verify with DigiLocker / Aadhaar e-KYC',



    'governmentVerified': 'Government Verified ✓',



    'governmentVerifyBadgeText': 'Identity verified against government database. Government Verified ✓ badge attached.',



    'deliveryAddressStep': 'Step 3: Delivery Address',



    'deliveryAddress': 'House/Flat, Street/Village, Landmark',



    'addressRequired': 'Address is required',



    'pinCode': 'PIN Code',



    'validPin': 'Valid PIN',



    'state': 'State',



    'businessDetailsStep': 'Step 4: Business Details (Seller)',



    'businessName': 'Business / Enterprise Name',



    'businessCategory': 'Business Category',



    'gstinOptional': 'GSTIN (optional)',



    'bankAccountNumber': 'Bank Account Number',



    'ifscCode': 'IFSC Code',



    'pennyDropVerifyBank': 'Penny-Drop Verify Bank Account',



    'bankVerified': 'Bank Verified ✓',



    'createMyAccount': 'Create My Account',



    'alreadyHaveAccountLogin': 'Already have an account? Login',



    'nationalIdVerificationTitle': 'National ID Verification',



    'nationalIdVerificationContent': 'Connecting to DigiLocker / UIDAI e-KYC gateway...\n\nThis will fetch your verified name, DOB, address, and photo from the government database.',



    'dialogCancel': 'Cancel',



    'authorizeVerify': 'Authorize & Verify',



    'nationalIdVerified': 'National ID verified successfully!',



    'bankVerificationTitle': 'Bank Account Verification',



    'bankVerificationContent': 'Sending ₹1 penny-drop to your bank account via NPCI...\n\nThis verifies that the account exists and the holder name matches your National ID.',



    'bankDialogVerify': 'Verify',



    'bankVerifiedSnackMessage': 'Bank account verified!',



    'verifyNationalFirst': 'Please verify your National ID first.',



    'verifyBankFirst': 'Please verify your bank account first.',



    'accountCreated': 'Account created successfully! Welcome to EcoSusRural.',







    // Legal agreement



    'legalAgreementTitle': 'Terms, Privacy & Integrity Agreement',



    'legalAgreementListen': 'Listen / सुनें',



    'legalAgreementAudioNarration': 'Playing audio narration in your selected language...',



    'legalAgreementTerms': 'I agree to the Terms of Service and understand that AI questions may be processed by Google Gemini.',



    'legalAgreementPrivacy': 'I acknowledge the privacy and data processing notice, including the use of configured service providers.',



    'legalAgreementIntegrity': 'I agree to respect the rights and licenses attached to educational content.',



    'legalAgreementDocument': '''ECOSUSRURAL PLATFORM TERMS AND DATA NOTICE\n\n1. COMMERCE AND CONTENT\nUse truthful descriptions and provenance for listings. Do not offer counterfeit or unsafe goods. Educational content may be subject to creator licenses.\n\n2. AI PROCESSING\nGeneral AI questions may be sent from the EcoSusRural backend to Google Gemini. AI answers can be wrong and should be checked before important decisions. Do not enter passwords, OTPs, banking details, or unnecessary identity information in AI prompts.\n\n3. DATA AND PRIVACY\nAccount, location, marketplace, and support data may be processed by the services configured for this app. Storage location, retention, deletion processes, and provider terms require a published privacy policy before public launch.\n\n4. CONTENT PROTECTION\nThe app may restrict screenshots on supported devices. This does not guarantee prevention of every recording method. Respect the rights attached to videos, images, and lessons.\n\n5. LISTINGS AND PAYMENTS\nCertification and origin claims require verification. A listing or payment is complete only when the relevant backend or payment provider confirms it; escrow is not promised by this app.\n\nPlease review the published policies before using production services.''',







    // Dashboard



    'greetingPrefix': 'Namaste',



    'farmLookingGood': 'Your farm is thriving today!',



    'exploreModules': 'Explore Modules',



    'weatherAdvisory': 'Weather & Crop Advisory',



    'pestId': 'Pest ID',



    'marketRate': 'Market Rate',



    'irrigation': 'Irrigation',



    'community': 'Community',



    'recommendedMasterclasses': 'Recommended Masterclasses',







    // Core Modules



    'marketplace': 'Marketplace',



    'govtSchemes': 'Schemes, Insurance & Scholarships',



    'mspSupport': 'MSP Support',



    'weather': 'Weather Intelligence',



    'learningAcademy': 'Learning Academy',



    'aiAssistant': 'AI Crop Assistant',



    'competitions': 'Competitions & Rewards',



    'expertAdvice': 'Expert Advice',



    'villageOutreach': 'Village Outreach',



    'circularEconomy': 'Circular Economy',



    'reviewsHelpdesk': 'Reviews & Helpdesk',



    'settings': 'Settings',



    'farmerHub': 'Farmer Value-Addition Hub',



    'artisanHub': 'Artisan Global Market',



    'ethicsPledge': 'Platform Ethics & Integrity',







    // Marketplace



    'searchMarketplace': 'Search GI-tagged, organic, handicrafts...',



    'allCategories': 'All',



    'giCertified': 'GI Certified',



    'sustainabilityVerified': 'Sustainability Verified',



    'handicraftVerified': 'Handicraft Verified',



    'organicCertified': 'Organic Certified',



    'labTested': 'Lab Tested',



    'addToCart': 'Add to Cart',



    'buyNow': 'Buy Now',



    'makerStory': 'Maker & Impact Story',



    'verifiedPurchase': 'Verified Purchase',



    'successStories': 'Success Stories & Interviews',



    'myCart': 'Shopping Cart',



    'checkout': 'Proceed to Checkout',







    // Transparent Pricing



    'priceBreakdown': 'Transparent Price Breakdown',



    'basePrice': 'Product Base Price',



    'platformFee': 'EcoSusRural Service Fee',



    'deliveryCharge': 'Delivery Charge',



    'ruralLogisticsFee': 'Rural Last-Mile Surcharge',



    'gst': 'GST (Tax)',



    'cartTotal': 'Total Payable',







    // Schemes & MSP



    'schemesTitle': 'Government & Private Schemes Portal',



    'searchSchemes': 'Search 200+ Central & State Schemes...',



    'mspLiveDashboard': 'Live MSP Mandi Tracker',



    'mandiComparison': 'Mandi Price Comparison',



    'fileMspGrievance': 'File MSP Grievance',



    'directProcurement': 'Direct FCI / NAFED Connection',



    'inAppApplication': 'Direct In-App Application',



    'nominalServiceFee': 'Transparent nominal service fee applies',







    // Schemes, insurance & scholarships (in-app application flow)



    'schemesPortal': 'Schemes, Insurance and Scholarships',



    'applyFor': 'Apply for',



    'aboutScheme': 'About this Scheme',



    'eligibilityCriteria': 'Eligibility Criteria',



    'applicationProcess': 'Application Process',



    'profileAutoFill': 'Your profile data is pre-filled automatically.',



    'uploadDocuments': 'Upload photos of the required documents.',



    'submitFeeDisclosed': 'Submit. A nominal service fee is disclosed before payment.',



    'trackInMyApplications': 'Track your application status in "My Applications".',



    'applicationSubmitted': 'Application Submitted!',



    'applicationSubmittedMsg': 'Your application has been submitted successfully. You can track its status in the "My Applications" section.',



    'ok': 'OK',



    'backToDetails': 'Back to details',



    'termsAccepted': 'Terms & Conditions Accepted',



    'describeVideo': 'Describe your video',



    'uploadVideoBtn': 'Upload Video',



    'termsAndConditions': 'Terms and Conditions',



    'acceptTerms': 'I accept all the terms and conditions',



    'submitVideo': 'Submit Video',



    'videoSubmitted': 'Video Submitted',



    'videoUnderReview': 'Video Under Review',



    'videoPublished': 'Video Published',



    'videoRejected': 'Video Rejected',



    'teamReviewing': 'Team EcoSusRural is reviewing your video...',



    'videoRejectReason': 'Video Reject Reason',



    'videoPublishNotice': 'Your video will be published after team review.',



    'videoDescriptionHint': 'Tell us what this video is about',



    'documentsRequired': 'Documents Required',



    'uploadDocument': 'Upload',



    'documentAttached': 'Attached',



    'attachDocument': 'Attach',



    'captchaTitle': 'Captcha Verification',



    'emailOtpStep': 'Email Verification',



    'appliedSuccessfully': 'Applied successfully',



    'applicationFee': 'Application service fee',



    'payWithEcoBharatPay': 'Pay with EcoBharatPay',



    'payNow': 'Pay Now',



    'myApplications': 'My Applications',



    'department': 'Department',



    'fileCurrentlyAt': 'File currently at',



    'expectedResult': 'Expected result time',



    'approxWorkingDays': 'approx. working days',



    'rejectionReason': 'Why was it rejected?',



    'documentIssues': 'Document issues',



    'reapply': 'Reapply',



    'statusSubmitted': 'Submitted',



    'statusUnderReview': 'Under review',



    'statusApproved': 'Approved',



    'statusRejected': 'Rejected',



    'statusActionRequired': 'Action required',



    'kindSchemes': 'Schemes',



    'kindInsurance': 'Insurance',



    'kindScholarships': 'Scholarships',



    'typeGovernment': 'Government',



    'typePrivate': 'Private',







    // Farmer Processing & Value Addition (Part V)



    'farmerProcessingTitle': 'Farmer Value-Addition & Processing Hub',



    'driedFruit': 'Dried Fruit Solar Dehydration',



    'driedVegetable': 'Dried Vegetable & Storage',



    'spiceQuality': 'Spice Lab Testing & Spice Board',



    'organicInputs': 'Bio-Fertilizer & Bio-Pesticide Plants',



    'ayurvedicCosmetics': 'Ayurvedic Natural Cosmetics (B2B/B2C)',



    'masterFarmer': 'Master Farmer Teaching Portal',







    // Artisan Global Market (Part VI)



    'artisanExportTitle': 'Artisan Global Market & Export Hub',



    'globalExport': 'Export Facilitation (IEC & Customs)',



    'fairPricing': 'Fair Price Guarantee (No Middlemen)',



    'packagingTraining': 'Fragile Packaging & Logistics Training',



    'masterArtisan': 'Master Artisan Teaching Portal',







    // Circular Economy (Part VII)



    'circularTitle': 'Circular Economy & Waste Recycling Hub',



    'plasticRecycling': 'Plastic & Polymer Recycling Unit Setup',



    'metalRecycling': 'Metal & E-Waste Critical Metal Recovery',



    'bioManure': 'Bio-Manure & Vermicompost Facilities',



    'bioGas': 'Biogas Plant Setup & Energy',



    'licensingHelp': 'EcoSusRural Regulatory & Licensing Support',







    // Platform Integrity & Security (DRM & Ethics)



    'ethicsTitle': 'Platform Integrity & Ethics Pledge',



    'antiCounterfeiting': 'Listing provenance review',



    'militaryDrm': 'Content protection controls',



    'escrowProtection': 'Payment status confirmation',



    'dpdpaCompliance': 'Privacy and data controls',







    // Seller Dashboard & Finance



    'sellerDashboard': 'Seller Dashboard & Analytics',



    'upgradeToSeller': 'Upgrade to Seller Account',



    'freemiumTiers': 'Subscription Tiers',



    'freeTrial30': '30-Day Free Trial (All Features)',



    'demandSupply': 'Demand-Supply Intelligence',



    'aiTranslationTool': 'AI Multilingual Translation Assistant',



    'financialAnalytics': 'Deep Financial Analytics',



    'ytd': 'Year-to-Date (YTD)',



    'payoutsLedger': 'Payouts Ledger',



    'payInsLedger': 'Buyer Pay-Ins',



    'loanTracker': 'Loan & Credit Tracker',



    'gstInvoices': 'GST Bills & Invoices',







    // Onboarding Tutorial



    'onboardingTitle': 'Welcome to EcoSusRural',



    'howItWorks': 'How EcoSusRural Works',



    'missionImpact': 'Our Mission & Real Impact',



    'dashboardTour': 'Your Dashboard Tour',



    'revisitTutorial': 'Watch Tutorial Again',







    // Registration (Buyer / Seller / Organisation)



    'registrationTitle': 'Create Account',



    'chooseAccountType': 'Choose your account type',



    'accountTypeOrganisation': 'Organisation',



    'organisation': 'Organisation',



    'orgRole': 'Organisation type',



    'orgTypeNgo': 'NGO',



    'orgTypeShg': 'SHG',



    'orgTypePanchayat': 'Gram Panchayat',



    'orgTypeFpo': 'FPO',



    'sellerRolePicker': 'Select your role',



    'roleFarmer': 'Farmer',



    'roleSarpanch': 'Sarpanch / Panchayat Rep',



    'roleArtisan': 'Artisan',



    'roleCraftsman': 'Craftsman',



    'roleMsme': 'MSME Owner',



    'roleNgoHead': 'NGO Head',



    'roleShgFpo': 'SHG / FPO Representative',



    'idType': 'ID Document',



    'idAadhaar': 'Aadhaar',



    'idPan': 'PAN Card',



    'emailOtpVerify': 'Verify Email OTP',



    'emailOtpSent': 'OTP sent to your email',



    'captcha': 'Captcha',



    'enterCaptcha': 'Enter the characters shown',



    'wrongCaptcha': 'Incorrect captcha. Try again.',



    'orgName': 'Organisation name',



    'headName': 'Head of organisation',



    'bankIfsc': 'IFSC code',



    'sellerDocsNote': 'Aadhaar or PAN and bank details are mandatory for sellers.',



    'buyerDocsNote': 'Only Aadhaar with OTP and penny-drop captcha verification is required.',



    'subscriptionPlan': 'Subscription Plan',



    'planFreeTrial': '1-Month Free Trial',



    'plan3Month': '3-Month Plan',



    'plan1Year': '1-Year Plan (More Economical)',



    'planPayPerUse': 'Pay-per-use',



    'pennyDropFee': 'Refundable verification fee',



    'pennyDropRefundNote': 'Refunded after successful verification',



    'freeTrialNote': 'After your 1-month free trial, a subscription is needed for premium services. Anyone can still purchase products without a subscription.',



    'reVerify': 'Re-verify details',



    'reVerifyNote': 'Made a mistake? You can re-verify with proper proof that your details are true.',



    'oneDeviceNote': 'One account can be active on only one device at a time.',



    'docsOrgTitle': 'Organisation documents',



    'orgHeadAadhaar': "Head's Aadhaar card",



    'orgHeadPhoto': "Passport-size photo of head",



    'orgSignedLetter': 'Signed letter by head of organisation',



    'orgGovCert': 'Government-issued certificate',



    'uploadDoc': 'Upload document',



    'farmProfileFarmersOnly': 'Farm profile setup is for farmers only.',







    // FAQ



    'faq': 'FAQs',



    'faqTitle': 'Frequently Asked Questions',



    'faqSearch': 'Search questions...',



    'faqContact': 'Still need help? Contact support.',







    // EcoBharatPe



    'ecoBharatPe': 'EcoBharatPe',



    'bharatpeTagline': 'One integrated payment system',



    'paymentMethods': 'Payment methods',



    'upi': 'UPI',



    'cards': 'Cards',



    'netBanking': 'Net Banking',



    'cod': 'Cash on Delivery',



    'autopay': 'Autopay',



    'payPerUse': 'Pay-per-use',



    'payouts': 'Payouts',



    'voiceFeeNote': 'Voice services are free for the first month; a small fee may apply after that.',



    'helpSupport': 'Help & Support',



    'logout': 'Logout',



  },







  'hi': {



    // General / Navigation



    'appName': 'इकोससरूरल',







    'tagline': 'पर्यावरण · स्थिरता · ग्रामीण सशक्तिकरण',







    'welcome': 'इकोससरूरल में आपका स्वागत है!',







    'selectLanguage': 'भाषा चुनें',







    'searchLanguage': 'भाषा खोजें...',







    'confirmContinue': 'पुष्टि करें और जारी रखें',





    'changeLanguage': 'भाषा बदलें',







    'acceptContinue': 'स्वीकार करें और जारी रखें',







    'phoneLogin': 'मोबाइल से लॉगिन करें',







    'enterOtp': 'OTP दर्ज करें',







    'verifyContinue': 'सत्यापित करें और जारी रखें',







    'setupProfile': 'फार्म प्रोफाइल सेट करें',





    'completeProfile': 'सेटअप पूरा करें',





    'home': 'होम',







    'market': 'बाजार',







    'learn': 'सीखें',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'प्रोफ़ाइल',







    'seller': 'विक्रेता केंद्र',







    'next': 'आगे',







    'back': 'पीछे',







    'cancel': 'रद्द करें',







    'submit': 'जमा करें',







    'save': 'सहेजें',







    'apply': 'अभी आवेदन करें',







    'viewAll': 'सभी देखें',







    'search': 'खोजें...',







    'getStarted': 'शुरू करें',







    'skip': 'छोड़ें',







    'buyerRole': 'खरीदार',







    'sellerRole': 'विक्रेता',







    'welcomeBack': 'वापसी पर स्वागत है!',







    'loginSubtitle': 'अपने पंजीकृत मोबाइल नंबर से लॉगिन करें और आगे बढ़ें। आपका खाता इस डिवाइस पर लॉग आउट तक साइन इन रहेगा।',





    'mobileNumber': 'मोबाइल नंबर',







    'mobileRequired': 'कृपया अपना मोबाइल नंबर दर्ज करें',







    'mobileInvalid': 'वैध 10-अंक का भारतीय मोबाइल नंबर दर्ज करें',







    'sendOtp': 'OTP भेजें',







    'createAccountLink': 'नया उपयोगकर्ता? खाता बनाएं',







    'personalDetailsStep': 'स्टेप 1: व्यक्तिगत विवरण',





    'fullLegalName': 'पूर्ण कानूनी नाम (राष्ट्रीय आईडी के अनुसार)',





    'nameRequired': 'नाम आवश्यक है',







    'phoneInvalid': 'वैध 10-अंक नंबर दर्ज करें',







    'emailAddress': 'ईमेल पता',







    'emailInvalid': 'वैध ईमेल दर्ज करें',







    'nationalIdStep': 'स्टेप 2: राष्ट्रीय आईडी सत्यापन',





    'nationalId': 'राष्ट्रीय आईडी (आधार)',





    'nationalIdInvalid': 'वैध 12-अंक राष्ट्रीय आईडी दर्ज करें',





    'verifyWithDigiLocker': 'DigiLocker / Aadhaar e-KYC से सत्यापित करें',







    'governmentVerified': 'सरकारी सत्यापित ✓',







    'governmentVerifyBadgeText': 'सरकारी डेटाबेस के खिलाफ पहचान सत्यापित। सरकारी सत्यापित ✓ बैज संलग्न है।',





    'deliveryAddressStep': 'स्टेप 3: डिलीवरी पता',





    'deliveryAddress': 'घर/फ्लैट, सड़क/गाँव, लेण्डमार्क',





    'addressRequired': 'पता आवश्यक है',







    'pinCode': 'पिन कोड',







    'validPin': 'वैध पिन',







    'state': 'राज्य',







    'businessDetailsStep': 'स्टेप 4: व्यवसाय विवरण (विक्रेता)',





    'businessName': 'व्यवसाय / उद्यम नाम',







    'businessCategory': 'व्यवसाय वर्ग',







    'gstinOptional': 'GSTIN (वैकल्पिक)',







    'bankAccountNumber': 'बैंक खाता नंबर',







    'ifscCode': 'IFSC कोड',







    'pennyDropVerifyBank': 'पेनी-ड्रॉप बैंक खाता सत्यापित करें',







    'bankVerified': 'बैंक सत्यापित ✓',







    'createMyAccount': 'मेरा खाता बनाएं',







    'alreadyHaveAccountLogin': 'क्या आपका पहले से खाता है? लॉगिन करें',







    'nationalIdVerificationTitle': 'राष्ट्रीय आईडी सत्यापन',





    'nationalIdVerificationContent': 'DigiLocker / UIDAI e-KYC गेटवे से कनेक्ट हो रहा है...\n\nयह सरकार की डेटाबेस से आपका सत्यापित नाम, DOB, पता और फोटो लाएगा।',





    'dialogCancel': 'रद्द करें',







    'authorizeVerify': 'प्राधिकरण और सत्यापन',







    'nationalIdVerified': 'राष्ट्रीय आईडी सफलतापूर्वक सत्यापित हो गई!',





    'bankVerificationTitle': 'बैंक खाता सत्यापन',







    'bankVerificationContent': 'NPCI के माध्यम से आपके बैंक खाते में ₹1 पेनी-ड्रॉप भेजा जा रहा है...\n\nयह सत्यापित करता है कि खाता मौजूद है और होल्डर नाम आपकी राष्ट्रीय आईडी से मेल खाता है।',





    'bankDialogVerify': 'सत्यापित करें',







    'bankVerifiedSnackMessage': 'बैंक खाता सत्यापित हो गया!',







    'verifyNationalFirst': 'कृपया पहले अपनी राष्ट्रीय आईडी सत्यापित करें।',





    'verifyBankFirst': 'कृपया पहले अपना बैंक खाता सत्यापित करें।',







    'accountCreated': 'खाता सफलतापूर्वक बनाया गया! EcoSusRural में आपका स्वागत है।',











    // Legal agreement



    'legalAgreementTitle': 'नियम, गोपनीयता और अखंडता समझौता',










    'legalAgreementListen': 'Listen / सुनें',







    'legalAgreementAudioNarration': 'आपके चुने हुए भाषा में ऑडियो कथन चल रहा है...',







    'legalAgreementTerms': 'मैं सेवा नियमों और निष्पक्ष मार्केटप्लेस नियमों से सहमत हूँ।',





    'legalAgreementPrivacy': 'मैं गोपनीयता और डेटा प्रसंस्करण सूचना को स्वीकार करता हूँ।',





    'legalAgreementIntegrity': 'मैं शैक्षिक सामग्री से जुड़े अधिकारों और लाइसेंस का सम्मान करूँगा।',





    'legalAgreementDocument': '''ECOSUSRURAL मंच शर्तें और डेटा सूचना\n\n1. व्यापार और सामग्री\nलिस्टिंग में उत्पाद और उसके स्रोत की सही जानकारी दें। नकली या असुरक्षित सामान न बेचें। शैक्षिक सामग्री पर रचनाकार के लाइसेंस लागू हो सकते हैं।\n\n2. AI प्रसंस्करण\nसामान्य AI प्रश्न EcoSusRural सर्वर से Google Gemini को भेजे जा सकते हैं। AI उत्तर गलत हो सकते हैं; महत्वपूर्ण निर्णय से पहले जाँच करें। AI प्रश्न में पासवर्ड, OTP या बैंक विवरण न दें।\n\n3. डेटा और गोपनीयता\nखाता, स्थान और बाजार संबंधी डेटा इस ऐप की सेवाओं में संसाधित हो सकता है। सार्वजनिक लॉन्च से पहले डेटा संग्रह, स्थान, अवधि और हटाने की प्रक्रिया बताने वाली गोपनीयता नीति प्रकाशित की जानी चाहिए।\n\n4. सामग्री सुरक्षा\nकुछ उपकरणों पर ऐप स्क्रीनशॉट सीमित कर सकता है, लेकिन हर रिकॉर्डिंग को रोकने की गारंटी नहीं है। सामग्री के अधिकारों का सम्मान करें।\n\n5. लिस्टिंग और भुगतान\nप्रमाणन और मूल स्थान के दावों की जाँच आवश्यक है। लिस्टिंग या भुगतान तभी पूरा माना जाएगा जब संबंधित सर्वर या भुगतान सेवा पुष्टि करे। ऐप एस्क्रो का वादा नहीं करता।\n\nउत्पादन सेवाओं के उपयोग से पहले प्रकाशित नीतियाँ पढ़ें।''',


    // Dashboard
    'greetingPrefix': 'नमस्ते',
    'farmLookingGood': 'आपका खेत आज बहुत अच्छा दिख रहा है!',
    'exploreModules': 'सभी मॉड्यूल देखें',
    'weatherAdvisory': 'मौसम और फसल सलाह',
    'quickActions': 'त्वरित कार्य',
    'pestId': 'कीट पहचान',
    'marketRate': 'मंडी भाव',
    'irrigation': 'सिंचाई',
    'community': 'समुदाय',
    'recommendedMasterclasses': 'अनुशंसित मास्टरक्लास',

    // Core Modules
    'marketplace': 'मार्केटप्लेस',
    'govtSchemes': 'योजनाएँ, बीमा और छात्रवृत्तियाँ',
    'mspSupport': 'MSP समर्थन केंद्र',
    'weather': 'मौसम सूचना (ISRO/IMD)',
    'learningAcademy': 'प्रशिक्षण अकादमी',
    'aiAssistant': 'AI फसल सहायक',
    'competitions': 'प्रतियोगिताएं व पुरस्कार',
    'expertAdvice': 'विशेषज्ञ सलाह',
    'villageOutreach': 'ग्राम पंचायत शिविर',
    'circularEconomy': 'चक्रीय अर्थव्यवस्था',
    'reviewsHelpdesk': 'समीक्षा व सहायता केंद्र',
    'settings': 'सेटिंग्स',
    'farmerHub': 'किसान मूल्य-संवर्धन केंद्र',
    'artisanHub': 'कारीगर वैश्विक बाजार',
    'ethicsPledge': 'मंच सत्यनिष्ठा व नैतिकता',

    // Marketplace
    'searchMarketplace': 'GI-टैग, जैविक, हस्तशिल्प खोजें...',
    'categories': 'श्रेणियाँ',
    'allCategories': 'सभी',
    'giCertified': 'GI प्रमाणित',
    'sustainabilityVerified': 'स्थिरता सत्यापित',
    'handicraftVerified': 'हस्तशिल्प सत्यापित',
    'organicCertified': 'जैविक प्रमाणित',
    'labTested': 'प्रयोगशाला परीक्षित',
    'addToCart': 'कार्ट में जोड़ें',
    'buyNow': 'अभी खरीदें',
    'makerStory': 'कारीगर व प्रभाव गाथा',
    'verifiedPurchase': 'सत्यापित खरीद',
    'successStories': 'सफलता की कहानियाँ व साक्षात्कार',
    'myCart': 'शॉपिंग कार्ट',
    'checkout': 'भुगतान के लिए आगे बढ़ें',

    // Transparent Pricing
    'priceBreakdown': 'पारदर्शी मूल्य विवरण',
    'basePrice': 'उत्पाद मूल मूल्य',
    'platformFee': 'इकोससरूरल सेवा शुल्क',
    'deliveryCharge': 'डिलीवरी शुल्क',
    'ruralLogisticsFee': 'ग्रामीण अंतिम-मील अधिभार',
    'gst': 'जीएसटी (कर)',
    'cartTotal': 'कुल देय राशि',

    // Schemes & MSP
    'schemesTitle': 'सरकारी व निजी योजना पोर्टल',
    'searchSchemes': '200+ केंद्रीय व राज्य योजनाएं खोजें...',
    'mspLiveDashboard': 'लाइव MSP मंडी ट्रैकर',
    'mandiComparison': 'मंडी मूल्य तुलना',
    'fileMspGrievance': 'MSP शिकायत दर्ज करें',
    'directProcurement': 'FCI / NAFED सीधी खरीद',
    'inAppApplication': 'ऐप से सीधा आवेदन',
    'nominalServiceFee': 'पारदर्शी मामूली सेवा शुल्क लागू',

    // योजनाएँ, बीमा व छात्रवृत्तियाँ (ऐप से आवेदन)
    'schemesPortal': 'योजनाएँ, बीमा और छात्रवृत्तियाँ',
    'applyFor': 'आवेदन करें',
    'documentsRequired': 'आवश्यक दस्तावेज़',
    'uploadDocument': 'अपलोड करें',
    'documentAttached': 'संलग्न',
    'attachDocument': 'संलग्न करें',
    'captchaTitle': 'कैप्चा सत्यापन',
    'emailOtpStep': 'ईमेल सत्यापन',
    'appliedSuccessfully': 'सफलतापूर्वक आवेदन हुआ',
    'applicationFee': 'आवेदन सेवा शुल्क',
    'payWithEcoBharatPay': 'इकोभारतपे से भुगतान करें',
    'payNow': 'भुगतान करें',
    'myApplications': 'मेरे आवेदन',
    'department': 'विभाग',
    'fileCurrentlyAt': 'फ़ाइल अभी इस विभाग में है',
    'expectedResult': 'अनुमानित परिणाम समय',
    'approxWorkingDays': 'लगभग कार्य दिवस',
    'rejectionReason': 'अस्वीकृति का कारण',
    'documentIssues': 'दस्तावेज़ संबंधी समस्याएँ',
    'reapply': 'दोबारा आवेदन करें',
    'statusSubmitted': 'जमा किया गया',
    'statusUnderReview': 'समीक्षा में',
    'statusApproved': 'स्वीकृत',
    'statusRejected': 'अस्वीकृत',
    'statusActionRequired': 'कार्रवाई आवश्यक',
    'kindSchemes': 'योजनाएँ',
    'kindInsurance': 'बीमा',
    'kindScholarships': 'छात्रवृत्तियाँ',
    'typeGovernment': 'सरकारी',
    'typePrivate': 'निजी',
    'applicationProcess': 'आवेदन प्रक्रिया',
    'aboutScheme': 'इस योजना के बारे में',
    'eligibilityCriteria': 'पात्रता मानदंड',
    'profileAutoFill': 'आपका प्रोफ़ाइल डेटा स्वचालित रूप से पूर्व-भर दिया जाता है।',
    'uploadDocuments': 'आवश्यक दस्तावेज़ों की फ़ोटो अपलोड करें।',
    'submitFeeDisclosed': 'जमा करें। भुगतान से पहले एक नाममात्र सेवा शुल्क बताया जाता है।',
    'trackInMyApplications': 'अपने आवेदन की स्थिति "मेरे आवेदन" में ट्रैक करें।',
    'applicationSubmitted': 'आवेदन जमा हुआ!',
    'applicationSubmittedMsg': 'आपका आवेदन सफलतापूर्वक जमा हो गया है। आप इसकी स्थिति "मेरे आवेदन" अनुभाग में ट्रैक कर सकते हैं।',
    'ok': 'ठीक है',
    'backToDetails': 'विवरण पर वापस जाएँ',
    'termsAccepted': 'नियम व शर्तें स्वीकार की गईं',
    'describeVideo': 'अपने वीडियो का वर्णन करें',
    'uploadVideoBtn': 'वीडियो अपलोड करें',
    'termsAndConditions': 'नियम और शर्तें',
    'acceptTerms': 'मैं सभी नियमों और शर्तों को स्वीकार करता/करती हूँ',
    'submitVideo': 'वीडियो जमा करें',
    'videoSubmitted': 'वीडियो जमा हुआ',
    'videoUnderReview': 'वीडियो समीक्षा में',
    'videoPublished': 'वीडियो प्रकाशित हुआ',
    'videoRejected': 'वीडियो अस्वीकृत',
    'teamReviewing': 'टीम EcoSusRural आपके वीडियो की समीक्षा कर रही है...',
    'videoRejectReason': 'वीडियो अस्वीकृति का कारण',
    'videoPublishNotice': 'आपका वीडियो टीम समीक्षा के बाद प्रकाशित होगा।',
    'videoDescriptionHint': 'इस वीडियो के बारे में बताएँ',
    'processVideoUpload': 'वीडियो अपलोड प्रक्रिया',
    'uploadVideoError': 'वीडियो अपलोड त्रुटि',
    'selectVideo': 'वीडियो चुनें',
    'requiredDocuments': 'आवश्यक दस्तावेज़',

    // Farmer Processing (Part V)
    'farmerProcessingTitle': 'किसान मूल्य-संवर्धन व प्रसंस्करण केंद्र',
    'driedFruit': 'सूखे मेवे सौर निर्जलीकरण',
    'driedVegetable': 'सूखी सब्जियां व भंडारण',
    'spiceQuality': 'मसाला लैब रिपोर्ट व स्पाइस बोर्ड',
    'organicInputs': 'जैविक खाद व बायो-कीटनाशक संयंत्र',
    'ayurvedicCosmetics': 'आयुर्वेदिक प्राकृतिक प्रसाधन',
    'masterFarmer': 'मास्टर किसान शिक्षण पोर्टल',

    // Artisan Global Market (Part VI)
    'artisanExportTitle': 'कारीगर वैश्विक निर्यात केंद्र',
    'globalExport': 'निर्यात सुविधा (IEC व कस्टम्स)',
    'fairPricing': 'उचित मूल्य गारंटी (बिना बिचौलियों के)',
    'packagingTraining': 'नाजुक हस्तशिल्प पैकेजिंग प्रशिक्षण',
    'masterArtisan': 'मास्टर कारीगर शिक्षण पोर्टल',

    // Circular Economy (Part VII)
    'circularTitle': 'चक्रीय अर्थव्यवस्था व अपशिष्ट पुनर्चक्रण',
    'plasticRecycling': 'प्लास्टिक व पॉलीमर रीसाइक्लिंग यूनिट',
    'metalRecycling': 'धातु व ई-कचरा महत्वपूर्ण धातु निष्कर्षण',
    'bioManure': 'बायो-खाद व वर्मीकम्पोस्ट इकाइयाँ',
    'bioGas': 'बायोगैस संयंत्र व ऊर्जा उत्पादन',
    'licensingHelp': 'लाइसेंसिंग व नियामक सहायता',

    // Platform Integrity & Security
    'ethicsTitle': 'मंच सत्यनिष्ठा व नैतिकता संकल्प',
    'antiCounterfeiting': 'लिस्टिंग स्रोत की समीक्षा',
    'militaryDrm': 'सामग्री सुरक्षा नियंत्रण',
    'escrowProtection': 'भुगतान स्थिति की पुष्टि',
    'dpdpaCompliance': 'गोपनीयता और डेटा नियंत्रण',

    // Seller Dashboard
    'sellerDashboard': 'विक्रेता डैशबोर्ड व एनालिटिक्स',
    'upgradeToSeller': 'विक्रेता खाते में अपग्रेड करें',
    'freemiumTiers': 'सदस्यता योजनाएं',
    'freeTrial30': '30 दिन का निःशुल्क परीक्षण',
    'demandSupply': 'मांग-आपूर्ति विश्लेषण',
    'aiTranslationTool': 'AI बहुभाषी अनुवाद सहायक',
    'financialAnalytics': 'गहन वित्तीय रिपोर्ट',
    'ytd': 'वर्ष-दर-तारीख (YTD)',
    'payoutsLedger': 'भुगतान खाता बही',
    'payInsLedger': 'ग्राहक आवक बही',
    'loanTracker': 'ऋण व क्रेडिट ट्रैकर',
    'gstInvoices': 'जीएसटी बिल व चालान',

    // Onboarding Tutorial
    'onboardingTitle': 'इकोससरूरल में आपका स्वागत है',
    'howItWorks': 'इकोससरूरल कैसे काम करता है',
    'missionImpact': 'हमारा मिशन व वास्तविक प्रभाव',
    'dashboardTour': 'डैशबोर्ड का संक्षिप्त दौरा',
    'revisitTutorial': 'ट्यूटोरियल फिर से देखें',

    // Registration (Buyer / Seller / Organisation)
    'registrationTitle': 'खाता बनाएँ',
    'chooseAccountType': 'अपना खाता प्रकार चुनें',
    'accountTypeOrganisation': 'संस्था',
    'organisation': 'संस्था',
    'orgRole': 'संस्था का प्रकार',
    'orgTypeNgo': 'एनजीओ',
    'orgTypeShg': 'स्वयं सहायता समूह (SHG)',
    'orgTypePanchayat': 'ग्राम पंचायत',
    'orgTypeFpo': 'एफपीओ',
    'sellerRolePicker': 'अपनी भूमिका चुनें',
    'roleFarmer': 'किसान',
    'roleSarpanch': 'सरपंच / पंचायत प्रतिनिधि',
    'roleArtisan': 'कारीगर',
    'roleCraftsman': 'शिल्पकार',
    'roleMsme': 'एमएसएमई मालिक',
    'roleNgoHead': 'एनजीओ प्रमुख',
    'roleShgFpo': 'एसएचजी / एफपीओ प्रतिनिधि',
    'idType': 'पहचान दस्तावेज़',
    'idAadhaar': 'आधार',
    'idPan': 'पैन कार्ड',
    'emailOtpVerify': 'ईमेल ओटीपी सत्यापित करें',
    'emailOtpSent': 'आपके ईमेल पर ओटीपी भेजा गया',
    'captcha': 'कैप्चा',
    'enterCaptcha': 'दिखाए गए अक्षर दर्ज करें',
    'wrongCaptcha': 'गलत कैप्चा। फिर से कोशिश करें।',
    'orgName': 'संस्था का नाम',
    'headName': 'संस्था का प्रमुख',
    'bankIfsc': 'आईएफएससी कोड',
    'sellerDocsNote': 'विक्रेताओं के लिए आधार या पैन और बैंक विवरण अनिवार्य हैं।',
    'buyerDocsNote': 'क्रेताओं के लिए केवल आधार, ओटीपी और पैनी-ड्रॉप कैप्चा सत्यापन आवश्यक है।',
    'subscriptionPlan': 'सदस्यता योजना',
    'planFreeTrial': '1 महीने का मुफ़्त ट्रायल',
    'plan3Month': '3 महीने की योजना',
    'plan1Year': '1 साल की योजना (अधिक किफ़ायती)',
    'planPayPerUse': 'उपयोग अनुसार भुगतान',
    'pennyDropFee': 'धनवापसी योग्य सत्यापन शुल्क',
    'pennyDropRefundNote': 'सफल सत्यापन के बाद वापस किया जाएगा',
    'freeTrialNote': '1 महीने के मुफ़्त ट्रायल के बाद प्रीमियम सेवाओं के लिए सदस्यता आवश्यक है। कोई भी बिना सदस्यता उत्पाद खरीद सकता है।',
    'reVerify': 'विवरण फिर सत्यापित करें',
    'reVerifyNote': 'गलती हुई? उचित प्रमाण के साथ अपना विवरण फिर सत्यापित करें।',
    'oneDeviceNote': 'एक खाता एक समय पर केवल एक ही डिवाइस पर सक्रिय रह सकता है।',
    'docsOrgTitle': 'संस्था के दस्तावेज़',
    'orgHeadAadhaar': 'प्रमुख का आधार कार्ड',
    'orgHeadPhoto': 'प्रमुख का पासपोर्ट साइज़ फोटो',
    'orgSignedLetter': 'संस्था प्रमुख द्वारा हस्ताक्षरित पत्र',
    'orgGovCert': 'सरकारी प्रमाणपत्र',
    'uploadDoc': 'दस्तावेज़ अपलोड करें',
    'farmProfileFarmersOnly': 'फ़ार्म प्रोफ़ाइल केवल किसानों के लिए है।',

    // FAQ
    'faq': 'सामान्य प्रश्न',
    'faqTitle': 'अक्सर पूछे जाने वाले प्रश्न',
    'faqSearch': 'प्रश्न खोजें...',
    'faqContact': 'अभी भी मदद चाहिए? सहायता से संपर्क करें।',

    // EcoBharatPe
    'ecoBharatPe': 'इकोभारतपे',
    'bharatpeTagline': 'एकीकृत भुगतान प्रणाली',
    'paymentMethods': 'भुगतान विधियाँ',
    'upi': 'यूपीआई',
    'cards': 'कार्ड',
    'netBanking': 'नेट बैंकिंग',
    'cod': 'कैश ऑन डिलीवरी',
    'autopay': 'ऑटोपे',
    'payPerUse': 'उपयोग अनुसार भुगतान',
    'payouts': 'भुगतान',
    'voiceFeeNote': 'वॉइस सेवाएँ पहले महीने मुफ़्त हैं; बाद में छोटा शुल्क लग सकता है।',
    'helpSupport': 'सहायता व समर्थन',
    'logout': 'लॉग आउट',
  },







  'bn': {



    'appName': 'ইকোসাসরুরাল',







    'tagline': 'পরিবেশ · স্থায়িত্ব · গ্রামীণ ক্ষমতায়ন',







    'welcome': 'ইকোসাসরুরালে স্বাগতম!',







    'selectLanguage': 'ভাষা নির্বাচন করুন',







    'searchLanguage': 'ভাষা খুঁজুন...',







    'confirmContinue': 'নিশ্চিত করুন ও এগিয়ে যান',







    'changeLanguage': 'ভাষা পরিবর্তন করুন',







    'acceptContinue': 'স্বীকার করুন ও এগিয়ে যান',







    'home': 'হোম',







    'market': 'বাজার',







    'learn': 'শিখুন',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'প্রোফাইল',







    'seller': 'বিক্রেতা কেন্দ্র',







    'next': 'পরবর্তী',







    'back': 'পেছনে',







    'submit': 'জমা দিন',







    'save': 'সংরক্ষণ করুন',







    'apply': 'আবেদন করুন',







    'viewAll': 'সব দেখুন',







    'getStarted': 'শুরু করুন',







    'skip': 'এড়িয়ে যান',







    'greetingPrefix': 'নমস্কার',







    'farmLookingGood': 'আপনার খামার আজ খুব ভালো অবস্থায় আছে!',







    'exploreModules': 'মডিউলগুলি অন্বেষণ করুন',







    'weatherAdvisory': 'আবহাওয়া ও ফসলের পরামর্শ',







    'quickActions': 'দ্রুত পদক্ষেপ',







    'marketplace': 'মার্কেটপ্লেস',





    'govtSchemes': 'সরকারি প্রকল্প',







    'mspSupport': 'MSP সহায়তা',



    'weather': 'আবহাওয়া গোয়েন্দা',







    'learningAcademy': 'লার্নিং একাডেমি',







    'farmerHub': 'কৃষক প্রক্রিয়াকরণ কেন্দ্র',







    'artisanHub': 'কারিগর বৈশ্বিক বাজার',







    'circularEconomy': 'সার্কুলার ইকোনমি',







    'ethicsPledge': 'প্ল্যাটফর্ম সততা ও নীতি',





    'searchMarketplace': 'জিআই-ট্যাগড, জৈব, হস্তশিল্প খুঁজুন...',





    'addToCart': 'কার্টে যোগ করুন',





    'buyNow': 'এখনই কিনুন',







    'priceBreakdown': 'স্বচ্ছ মূল্যের বিবরণ',







    'cartTotal': 'মোট প্রদেয়',





    'schemesTitle': 'সরকারি ও বেসরকারি প্রকল্প পোর্টাল',





    'mspLiveDashboard': 'লাইভ এমএসপি মান্ডি ট্র্যাকার',





    'sellerDashboard': 'বিক্রেতা ড্যাশবোর্ড',







    'onboardingTitle': 'ইকোসাসরুরালে আপনাকে স্বাগতম',







    'howItWorks': 'ইকোসাসরুরাল কীভাবে কাজ করে',







    'missionImpact': 'আমাদের লক্ষ্য ও প্রভাব',







    'dashboardTour': 'ড্যাশবোর্ড ভ্রমণ',







    'revisitTutorial': 'টিউটোরিয়াল আবার দেখুন',





    'settings': 'সেটিংস',





  },







  'te': {



    'appName': 'ఈకోసస్రూరల్',







    'tagline': 'పర్యావరణం · స్థిరత్వం · గ్రామీణ సాధికారత',







    'welcome': 'ఈకోసస్రూరల్‌కు స్వాగతం!',







    'selectLanguage': 'భాషను ఎంచుకోండి',







    'searchLanguage': 'భాషను వెతకండి...',







    'confirmContinue': 'నిర్ధారించి కొనసాగించండి',







    'changeLanguage': 'భాష మార్చండి',







    'acceptContinue': 'అంగీకరించి కొనసాగించండి',







    'home': 'హోమ్',







    'market': 'మార్కెట్',





    'learn': 'నేర్చుకోండి',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'ప్రొఫైల్',







    'seller': 'విక్రేత కేంద్రం',







    'next': 'తదుపరి',



    'back': 'వెనుకకు',







    'submit': 'సమర్పించండి',







    'save': 'భద్రపరచండి',







    'apply': 'దరఖాస్తు చేయండి',







    'viewAll': 'అన్నీ చూడండి',







    'getStarted': 'ప్రారంభించండి',







    'skip': 'దాటవేయి',





    'greetingPrefix': 'నమస్కారం',







    'farmLookingGood': 'మీ పొలం ఈరోజు చాలా బాగుంది!',







    'exploreModules': 'మాడ్యూల్స్‌ను అన్వేషించండి',







    'weatherAdvisory': 'వాతావరణం & పంట సలహా',





    'quickActions': 'త్వరిత చర్యలు',







    'marketplace': 'మార్కెట్‌ప్లేస్',





    'govtSchemes': 'ప్రభుత్వ పథకాలు',







    'mspSupport': 'MSP మద్దతు',



    'weather': 'వాతావరణ నిఘా',







    'learningAcademy': 'శిక్షణ అకాడమీ',







    'farmerHub': 'రైతు విలువ జోడింపు కేంద్రం',







    'artisanHub': 'చేతివృత్తుల గ్లోబల్ మార్కెట్',





    'circularEconomy': 'వృత్తాకార ఆర్థిక వ్యవస్థ',







    'ethicsPledge': 'వేదిక సమగ్రత & నైతికత',







    'searchMarketplace': 'GI ట్యాగ్, సేంద్రీయ, హస్తకళల కోసం వెతకండి...',





    'addToCart': 'కార్ట్‌కు జోడించండి',





    'buyNow': 'ఇప్పుడే కొనండి',







    'priceBreakdown': 'పారదర్శక ధర వివరాలు',







    'cartTotal': 'మొత్తం చెల్లించవలసినది',







    'schemesTitle': 'ప్రభుత్వ & ప్రైవేట్ పథకాల పోర్టల్',





    'mspLiveDashboard': 'లైవ్ MSP మార్కెట్ ట్రాకర్',





    'sellerDashboard': 'విక్రేత డాష్‌బోర్డ్',







    'onboardingTitle': 'ఈకోసస్రూరల్‌కు స్వాగతం',







    'howItWorks': 'ఈకోసస్రూరల్ ఎలా పనిచేస్తుంది',







    'missionImpact': 'మా లక్ష్యం & ప్రభావం',







    'dashboardTour': 'డాష్‌బోర్డ్ టూర్',





    'revisitTutorial': 'ట్యుటోరియల్ మళ్ళీ చూడండి',





    'settings': 'సెట్టింగ్‌లు',





  },







  'mr': {



    'appName': 'इकोससरूरल',







    'tagline': 'पर्यावरण · शाश्वतता · ग्रामीण सक्षमीकरण',







    'welcome': 'इकोससरूरल मध्ये आपले स्वागत आहे!',







    'selectLanguage': 'भाषा निवडा',



    'searchLanguage': 'भाषा शोधा...',







    'confirmContinue': 'पुष्टी करा आणि पुढे जा',





    'changeLanguage': 'भाषा बदला',



    'acceptContinue': 'स्वीकारा आणि पुढे जा',







    'home': 'मुख्यपृष्ठ',







    'market': 'बाजार',







    'learn': 'शिका',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'प्रोफाइल',







    'seller': 'विक्रेता केंद्र',







    'next': 'पुढे',







    'back': 'मागे',







    'submit': 'सादर करा',







    'save': 'जतन करा',







    'apply': 'आता अर्ज करा',







    'viewAll': 'सर्व पहा',



    'getStarted': 'सुरू करा',







    'skip': 'वगळा',







    'greetingPrefix': 'नमस्ते',







    'farmLookingGood': 'आपले शेत आज खूप छान दिसत आहे!',







    'exploreModules': 'मॉड्यूल एक्सप्लोर करा',







    'weatherAdvisory': 'हवामान आणि पीक सल्ला',







    'quickActions': 'द्रुत कृती',







    'marketplace': 'मार्केटप्लेस',





    'govtSchemes': 'सरकारी योजना',







    'mspSupport': 'MSP आधार केंद्र',







    'weather': 'हवामान माहिती (ISRO/IMD)',







    'learningAcademy': 'प्रशिक्षण अकादमी',







    'farmerHub': 'शेतकरी प्रक्रिया केंद्र',







    'artisanHub': 'कारागीर जागतिक बाजार',







    'circularEconomy': 'चक्रीय अर्थव्यवस्था',







    'ethicsPledge': 'प्लॅटफॉर्म सचोटी व नैतिकता',





    'searchMarketplace': 'GI टॅग, सेंद्रिय, हस्तकला शोधा...',





    'addToCart': 'कार्टमध्ये जोडा',





    'buyNow': 'आता खरेदी करा',







    'priceBreakdown': 'पारदर्शक किंमत तपशील',







    'cartTotal': 'एकूण देय रक्कम',







    'schemesTitle': 'सरकारी आणि खाजगी योजना पोर्टल',





    'mspLiveDashboard': 'थेट MSP बाजार ट्रॅकर',





    'sellerDashboard': 'विक्रेता डॅशबोर्ड',







    'onboardingTitle': 'इकोससरूरल मध्ये स्वागत आहे',







    'howItWorks': 'इकोससरूरल कसे कार्य करते',







    'missionImpact': 'आमचे ध्येय आणि प्रभाव',







    'dashboardTour': 'डॅशबोर्ड सहल',







    'revisitTutorial': 'ट्यूटोरियल पुन्हा पहा',





    'settings': 'सेटिंग्ज',





  },







  'ta': {



    'appName': 'ஈகோசஸ்ரூரல்',







    'tagline': 'சுற்றுச்சூழல் · நிலைத்தன்மை · கிராமப்புற மேம்பாடு',





    'welcome': 'ஈகோசஸ்ரூரலுக்கு நல்வரவு!',







    'selectLanguage': 'மொழியைத் தேர்ந்தெடுக்கவும்',





    'searchLanguage': 'மொழியைத் தேடுங்கள்...',





    'confirmContinue': 'உறுதிசெய்து தொடரவும்',





    'changeLanguage': 'மொழியை மாற்றவும்',







    'acceptContinue': 'ஏற்றுக்கொண்டு தொடரவும்',





    'home': 'முகப்பு',







    'market': 'சந்தை',







    'learn': 'கற்றுக்கொள்ளுங்கள்',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'சுயவிவரம்',







    'seller': 'விற்பனையாளர் மையம்',







    'next': 'அடுத்து',





    'back': 'பின்னால்',



    'submit': 'சமர்ப்பிக்கவும்',







    'save': 'சேமிக்கவும்',







    'apply': 'விண்ணப்பிக்கவும்',







    'viewAll': 'அனைத்தையும் பார்க்கவும்',







    'getStarted': 'தொடங்குங்கள்',





    'skip': 'தவிர்க்கவும்',







    'greetingPrefix': 'வணக்கம்',







    'farmLookingGood': 'உங்கள் பண்ணை இன்று செழிப்பாக உள்ளது!',







    'exploreModules': 'தொகுதிகளை ஆராயுங்கள்',







    'weatherAdvisory': 'வானிலை மற்றும் பயிர் ஆலோசனை',







    'quickActions': 'விரைவு நடவடிக்கைகள்',





    'marketplace': 'சந்தைப்பகுதி',







    'govtSchemes': 'அரசு திட்டங்கள்',





    'mspSupport': 'MSP ஆதரவு மையம்',







    'weather': 'வானிலை தகவல்',







    'learningAcademy': 'பயிற்சி அகாடமி',





    'farmerHub': 'விவசாயிகள் மதிப்புக்கூட்டல் மையம்',





    'artisanHub': 'கைவினைஞர்கள் உலகளாவிய சந்தை',



    'circularEconomy': 'சுழற்சி பொருளாதாரம்',







    'ethicsPledge': 'தளத்தின் நேர்மை மற்றும் அறநெறி',







    'searchMarketplace': 'ஜிஐ குறியீடு, இயற்கை, கைவினைப்பொருட்களைத் தேடுங்கள்...',





    'addToCart': 'கார்ட்டில் சேர்க்கவும்',





    'buyNow': 'இப்போதே வாங்கவும்',







    'priceBreakdown': 'வெளிப்படையான விலை விவரம்',





    'cartTotal': 'செலுத்த வேண்டிய மொத்தத் தொகை',





    'schemesTitle': 'அரசு மற்றும் தனியார் திட்ட போர்டல்',





    'mspLiveDashboard': 'நேரலை MSP மண்டி கண்காணிப்பாளர்',





    'sellerDashboard': 'விற்பனையாளர் டாஷ்போர்டு',





    'onboardingTitle': 'ஈகோசஸ்ரூரலுக்கு நல்வரவு',







    'howItWorks': 'ஈகோசஸ்ரூரல் எவ்வாறு செயல்படுகிறது',





    'missionImpact': 'எங்கள் நோக்கம் மற்றும் தாக்கம்',







    'dashboardTour': 'டாஷ்போர்டு உலா',





    'revisitTutorial': 'பயிற்சியை மீண்டும் பார்க்கவும்',





    'settings': 'அமைப்புகள்',







  },







  'gu': {



    'appName': 'ઇકોસસરૂરલ',







    'tagline': 'પર્યાવરણ · સ્થિરતા · ગ્રામીણ સશક્તિકરણ',







    'welcome': 'ઇકોસસરૂરલમાં આપનું સ્વાગત છે!',







    'selectLanguage': 'ભાષા પસંદ કરો',







    'searchLanguage': 'ભાષા શોધો...',







    'confirmContinue': 'પુષ્ટિ કરો અને આગળ વધો',





    'changeLanguage': 'ભાષા બદલો',







    'acceptContinue': 'સ્વીકારો અને આગળ વધો',







    'home': 'હોમ',







    'market': 'બજાર',







    'learn': 'શીખો',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'પ્રોફાઇલ',







    'seller': 'વિક્રેતા કેન્દ્ર',







    'next': 'આગળ',







    'back': 'પાછળ',







    'submit': 'સબમિટ કરો',





    'save': 'સાચવો',







    'apply': 'અરજી કરો',







    'viewAll': 'બધું જુઓ',







    'getStarted': 'શરૂ કરો',







    'skip': 'છોડો',







    'greetingPrefix': 'નમસ્તે',







    'farmLookingGood': 'તમારું ખેતર આજે સરસ દેખાઈ રહ્યું છે!',







    'exploreModules': 'બધા મોડ્યુલ્સ જુઓ',







    'weatherAdvisory': 'હવામાન અને પાક સલાહ',







    'quickActions': 'ઝડપી કાર્યો',







    'marketplace': 'માર્કેટપ્લેસ',





    'govtSchemes': 'સરકારી યોજનાઓ',







    'mspSupport': 'MSP સહાયતા',



    'weather': 'હવામાન માહિતી',







    'learningAcademy': 'તાલીમ એકેડેમી',







    'farmerHub': 'ખેડૂત પ્રોસેસિંગ હબ',







    'artisanHub': 'કારીગર વૈશ્વિક બજાર',







    'circularEconomy': 'સર્ક્યુલર ઇકોનોમી',







    'ethicsPledge': 'મંચ પ્રામાણિકતા અને નૈતિકતા',







    'searchMarketplace': 'GI ટેગ, ઓર્ગેનિક, હસ્તકલા શોધો...',





    'addToCart': 'કાર્ટમાં ઉમેરો',





    'buyNow': 'હમણાં ખરીદો',







    'priceBreakdown': 'પારદર્શક ભાવ વિગતો',







    'cartTotal': 'કુલ ચૂકવવાપાત્ર',







    'schemesTitle': 'સરકારી અને ખાનગી યોજના પોર્ટલ',





    'mspLiveDashboard': 'લાઈવ MSP મંડી ટ્રેકર',





    'sellerDashboard': 'વિક્રેતા ડેશબોર્ડ',







    'onboardingTitle': 'ઇકોસસરૂરલમાં આપનું સ્વાગત છે',







    'howItWorks': 'ઇકોસસરૂરલ કેવી રીતે કાર્ય કરે છે',







    'missionImpact': 'અમારું લક્ષ્ય અને પ્રભાવ',







    'dashboardTour': 'ડેશબોર્ડ ટૂર',





    'revisitTutorial': 'ટ્યુટોરીયલ ફરીથી જુઓ',





    'settings': 'સેટિંગ્સ',





  },







  'kn': {



    'appName': 'ಈಕೋಸಸ್‌ರೂರಲ್',







    'tagline': 'ಪರಿಸರ · ಸುಸ್ಥಿರತೆ · ಗ್ರಾಮೀಣ ಸಬಲೀಕರಣ',







    'welcome': 'ಈಕೋಸಸ್‌ರೂರಲ್‌ಗೆ ಸ್ವಾಗತ!',







    'selectLanguage': 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',







    'searchLanguage': 'ಭಾಷೆಯನ್ನು ಹುಡುಕಿ...',







    'confirmContinue': 'ದೃಢೀಕರಿಸಿ ಮುಂದುವರಿಯಿರಿ',







    'changeLanguage': 'ಭಾಷೆ ಬದಲಿಸಿ',







    'acceptContinue': 'ಒಪ್ಪಿಕೊಂಡು ಮುಂದುವರಿಯಿರಿ',







    'home': 'ಮುಖಪುಟ',





    'market': 'ಮಾರುಕಟ್ಟೆ',





    'learn': 'ಕಲಿಯಿರಿ',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'ಪ್ರೊಫೈಲ್',







    'seller': 'ಮಾರಾಟಗಾರರ ಕೇಂದ್ರ',





    'next': 'ಮುಂದೆ',







    'back': 'ಹಿಂದೆ',







    'submit': 'ಸಲ್ಲಿಸಿ',



    'save': 'ಉಳಿಸಿ',







    'apply': 'ಅರ್ಜಿ ಸಲ್ಲಿಸಿ',







    'viewAll': 'ಎಲ್ಲವನ್ನೂ ವೀಕ್ಷಿಸಿ',







    'getStarted': 'ಪ್ರಾರಂಭಿಸಿ',







    'skip': 'ಬಿಟ್ಟುಬಿಡಿ',





    'greetingPrefix': 'ನಮಸ್ಕಾರ',







    'farmLookingGood': 'ನಿಮ್ಮ ತೋಟ ಇಂದು ಹಚ್ಚ ಹಸುರಾಗಿದೆ!',





    'exploreModules': 'ಮಾಡ್ಯೂಲ್‌ಗಳನ್ನು ಅನ್ವೇಷಿಸಿ',







    'weatherAdvisory': 'ಹವಾಮಾನ ಮತ್ತು ಬೆಳೆ ಸಲಹೆ',







    'quickActions': 'ತ್ವರಿತ ಕ್ರಮಗಳು',







    'marketplace': 'ಮಾರುಕಟ್ಟೆ ಸ್ಥಳ',





    'govtSchemes': 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು',







    'mspSupport': 'MSP ಬೆಂಬಲ',







    'weather': 'ಹವಾಮಾನ ಗುಪ್ತಚರ',







    'learningAcademy': 'ಕಲಿಕಾ ಅಕಾಡೆಮಿ',







    'farmerHub': 'ರೈತರ ಸಂಸ್ಕರಣಾ ಕೇಂದ್ರ',







    'artisanHub': 'ಕುಶಲಕರ್ಮಿಗಳ ಜಾಗತಿಕ ಮಾರುಕಟ್ಟೆ',





    'circularEconomy': 'ವೃತ್ತಾಕಾರದ ಆರ್ಥಿಕತೆ',







    'ethicsPledge': 'ವೇದಿಕೆ ಸಮಗ್ರತೆ ಮತ್ತು ನೀತಿಶಾಸ್ತ್ರ',







    'searchMarketplace': 'ಜಿಐ ಟ್ಯಾಗ್, ಸಾವಯವ, ಕರಕುಶಲ ವಸ್ತುಗಳನ್ನು ಹುಡುಕಿ...',





    'addToCart': 'ಕಾರ್ಟ್‌ಗೆ ಸೇರಿಸಿ',





    'buyNow': 'ಈಗಲೇ ಖರೀದಿಸಿ',







    'priceBreakdown': 'ಪಾರದರ್ಶಕ ಬೆಲೆ ವಿವರ',







    'cartTotal': 'ಒಟ್ಟು ಪಾವತಿಸಬೇಕಾದ ಮೊತ್ತ',





    'schemesTitle': 'ಸರ್ಕಾರಿ ಮತ್ತು ಖಾಸಗಿ ಯೋಜನೆಗಳ ಪೋರ್ಟಲ್',





    'mspLiveDashboard': 'ಲೈವ್ ಎಂಎಸ್‌ಪಿ ಮಾರುಕಟ್ಟೆ ಟ್ರ್ಯಾಕರ್',





    'sellerDashboard': 'ಮಾರಾಟಗಾರರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',





    'onboardingTitle': 'ಈಕೋಸಸ್‌ರೂರಲ್‌ಗೆ ಸ್ವಾಗತ',







    'howItWorks': 'ಈಕೋಸಸ್‌ರೂರಲ್ ಹೇಗೆ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ',







    'missionImpact': 'ನಮ್ಮ ಧ್ಯೇಯ ಮತ್ತು ಪ್ರಭಾವ',







    'dashboardTour': 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಪ್ರವಾಸ',







    'revisitTutorial': 'ಟ್ಯುಟೋರಿಯಲ್ ಮತ್ತೆ ವೀಕ್ಷಿಸಿ',





    'settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',





  },







  'pa': {



    'appName': 'ਇਕੋਸਸਰੂਰਲ',







    'tagline': 'ਵਾਤਾਵਰਣ · ਸਥਿਰਤਾ · ਪੇਂਡੂ ਸਸ਼ਕਤੀਕਰਨ',







    'welcome': 'ਇਕੋਸਸਰੂਰਲ ਵਿੱਚ ਸੁਆਗਤ ਹੈ!',







    'selectLanguage': 'ਭਾਸ਼ਾ ਚੁਣੋ',







    'searchLanguage': 'ਭਾਸ਼ਾ ਖੋਜੋ...',







    'confirmContinue': 'ਪੁਸ਼ਟੀ ਕਰਕੇ ਅੱਗੇ ਵਧੋ',





    'changeLanguage': 'ਭਾਸ਼ਾ ਬਦਲੋ',







    'acceptContinue': 'ਸਵੀਕਾਰ ਕਰਕੇ ਅੱਗੇ ਵਧੋ',







    'home': 'ਹੋਮ',







    'market': 'ਬਾਜ਼ਾਰ',







    'learn': 'ਸਿੱਖੋ',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'ਪ੍ਰੋਫਾਈਲ',







    'seller': 'ਵਿਕਰੇਤਾ ਕੇਂਦਰ',







    'next': 'ਅੱਗੇ',







    'back': 'ਪਿੱਛੇ',







    'submit': 'ਜਮ੍ਹਾਂ ਕਰੋ',







    'save': 'ਸੰਭਾਲੋ',







    'apply': 'ਅਰਜ਼ੀ ਦਿਓ',







    'viewAll': 'ਸਭ ਦੇਖੋ',







    'getStarted': 'ਸ਼ੁਰੂ ਕਰੋ',







    'skip': 'ਛੱਡੋ',







    'greetingPrefix': 'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ',







    'farmLookingGood': 'ਤੁਹਾਡਾ ਖੇਤ ਅੱਜ ਬਹੁਤ ਵਧੀਆ ਦਿਖ ਰਿਹਾ ਹੈ!',







    'exploreModules': 'ਸਾਰੇ ਮੋਡੀਊਲ ਦੇਖੋ',







    'weatherAdvisory': 'ਮੌਸਮ ਅਤੇ ਫਸਲ ਸਲਾਹ',







    'quickActions': 'ਤੁਰੰਤ ਕਾਰਵਾਈਆਂ',







    'marketplace': 'ਮਾਰਕੀਟਪਲੇਸ',





    'govtSchemes': 'ਸਰਕਾਰੀ ਸਕੀਮਾਂ',







    'mspSupport': 'MSP ਸਮਰਥਨ',



    'weather': 'ਮੌਸਮ ਜਾਣਕਾਰੀ',







    'learningAcademy': 'ਸਿਖਲਾਈ ਅਕੈਡਮੀ',







    'farmerHub': 'ਕਿਸਾਨ ਪ੍ਰੋਸੈਸਿੰਗ ਹੱਬ',







    'artisanHub': 'ਕਾਰੀਗਰ ਗਲੋਬਲ ਮਾਰਕੀਟ',





    'circularEconomy': 'ਸਰਕੂਲਰ ਆਰਥਿਕਤਾ',







    'ethicsPledge': 'ਪਲੇਟਫਾਰਮ ਇਮਾਨਦਾਰੀ ਅਤੇ ਨੈਤਿਕਤਾ',





    'searchMarketplace': 'GI ਟੈਗ, ਜੈਵਿਕ, ਦਸਤਕਾਰੀ ਖੋਜੋ...',





    'addToCart': 'ਕਾਰਟ ਵਿੱਚ ਸ਼ਾਮਲ ਕਰੋ',





    'buyNow': 'ਹੁਣੇ ਖਰੀਦੋ',







    'priceBreakdown': 'ਪਾਰਦਰਸ਼ੀ ਕੀਮਤ ਵੇਰਵਾ',







    'cartTotal': 'ਕੁੱਲ ਭੁਗਤਾਨਯੋਗ',







    'schemesTitle': 'ਸਰਕਾਰੀ ਅਤੇ ਨਿੱਜੀ ਸਕੀਮਾਂ ਪੋਰਟਲ',





    'mspLiveDashboard': 'ਲਾਈਵ MSP ਮੰਡੀ ਟਰੈਕਰ',





    'sellerDashboard': 'ਵਿਕਰੇਤਾ ਡੈਸ਼ਬੋਰਡ',







    'onboardingTitle': 'ਇਕੋਸਸਰੂਰਲ ਵਿੱਚ ਸੁਆਗਤ ਹੈ',







    'howItWorks': 'ਇਕੋਸਸਰੂਰਲ ਕਿਵੇਂ ਕੰਮ ਕਰਦਾ ਹੈ',







    'missionImpact': 'ਸਾਡਾ ਮਿਸ਼ਨ ਅਤੇ ਪ੍ਰਭਾਵ',







    'dashboardTour': 'ਡੈਸ਼ਬੋਰਡ ਟੂਰ',





    'revisitTutorial': 'ਟਿਊਟੋਰਿਅਲ ਦੁਬਾਰਾ ਦੇਖੋ',





    'settings': 'ਸੈਟਿੰਗਾਂ',





  },







  'ur': {



    'appName': 'ایکو سس رورل',



    'tagline': 'ماحولیات · پائیداری · دیہی خود مختاری',



    'welcome': 'ایکو سس رورل میں خوش آمدید!',



    'selectLanguage': 'زبان منتخب کریں',



    'searchLanguage': 'زبان تلاش کریں...',



    'confirmContinue': 'تصدیق کریں اور جاری رکھیں',



    'changeLanguage': 'زبان تبدیل کریں',



    'acceptContinue': 'قبول کریں اور جاری رکھیں',



    'home': 'ہوم',



    'market': 'مارکیٹ',



    'learn': 'سیکھیں',



    'aiGuide': 'EcoSusRural AI',



    'profile': 'پروفائل',



    'seller': 'سیلر حب',



    'next': 'اگلا',



    'back': 'پیچھے',



    'submit': 'جمع کرائیں',



    'save': 'محفوظ کریں',



    'apply': 'ابھی درخواست دیں',



    'viewAll': 'سب دیکھیں',



    'getStarted': 'شروع کریں',



    'skip': 'چھوڑیں',



    'greetingPrefix': 'خوش آمدید',



    'farmLookingGood': 'آپ کا کھیت آج بہت شاداب دکھائی دے رہا ہے!',



    'exploreModules': 'ماڈیولز دریافت کریں',



    'weatherAdvisory': 'موسم اور فصل کا مشورہ',



    'quickActions': 'فوری اقدامات',



    'marketplace': 'مارکیٹ پلیس',



    'govtSchemes': 'سرکاری اسکیمیں',



    'mspSupport': 'MSP امدادی مرکز',



    'weather': 'موسمیاتی معلومات',



    'learningAcademy': 'ٹریننگ اکیڈمی',



    'farmerHub': 'کسان پروسیسنگ حب',



    'artisanHub': 'کاریگر عالمی مارکیٹ',



    'circularEconomy': 'سرکلر اکانومی',



    'ethicsPledge': 'پلیٹ فارم اخلاقیات اور دیانت',



    'searchMarketplace': 'جی آئی ٹیگ، نامیاتی، دستکاری تلاش کریں...',



    'addToCart': 'کارٹ میں شامل کریں',



    'buyNow': 'ابھی خریدیں',



    'priceBreakdown': 'شفاف قیمت کی تفصیلات',



    'cartTotal': 'کل قابل ادائیگی',



    'schemesTitle': 'سرکاری و نجی اسکیم پورٹل',



    'mspLiveDashboard': 'لائیو ایم ایس پی منڈی ٹریکر',



    'sellerDashboard': 'سیلر ڈیش بورڈ',



    'onboardingTitle': 'ایکو سس رورل میں خوش آمدید',



    'howItWorks': 'ایکو سس رورل کیسے کام کرتا ہے',



    'missionImpact': 'ہمارا مشن اور حقیقی اثر',



    'dashboardTour': 'ڈیش بورڈ ٹور',



    'revisitTutorial': 'ٹیوٹوریل دوبارہ دیکھیں',



    'settings': 'ترتیبات',



  },







  'bho': {



    'appName': 'इकोससरूरल',







    'tagline': 'पर्यावरण · स्थिरता · गांव के सशक्तिकरण',







    'welcome': 'इकोससरूरल में राउर स्वागत बा!',







    'selectLanguage': 'भाषा चुनीं',







    'searchLanguage': 'भाषा खोजीं...',







    'confirmContinue': 'पुष्टि करीं आ आगे बढ़ीं',





    'changeLanguage': 'भाषा बदलीं',







    'acceptContinue': 'स्वीकार करीं आ आगे बढ़ीं',







    'home': 'होम',







    'market': 'बाजार',







    'learn': 'सीखीं',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'प्रोफाइल',







    'seller': 'दुकानदार हब',







    'next': 'आगे',







    'back': 'पाछे',







    'submit': 'जमा करीं',







    'save': 'सहेजीं',







    'apply': 'आवेदन करीं',







    'viewAll': 'सभ देखीं',







    'getStarted': 'शुरू करीं',







    'skip': 'छोड़ीं',







    'greetingPrefix': 'प्रणाम',



    'farmLookingGood': 'राउर खेत आज बहुत नीक लउकत बा!',







    'exploreModules': 'सभ मॉड्यूल देखीं',







    'weatherAdvisory': 'मौसम आ फसल सलाह',







    'quickActions': 'झटपट काम',





    'marketplace': 'मार्केटप्लेस',





    'govtSchemes': 'सरकारी योजना',







    'mspSupport': 'MSP सहारा',



    'weather': 'मौसम जानकारी',







    'learningAcademy': 'सीखे के अकादमी',







    'farmerHub': 'किसान प्रसंस्करण हब',







    'artisanHub': 'कारीगर दुनिया बाजार',







    'circularEconomy': 'कचरा पुनर्चक्रण',







    'ethicsPledge': 'सत्यनिष्ठा आ नीति संकल्प',







    'searchMarketplace': 'GI टैग, जैविक, हस्तशिल्प खोजीं...',





    'addToCart': 'कार्ट में डालीं',





    'buyNow': 'अबहीं खरीदीं',







    'priceBreakdown': 'साफ-सुथरा दाम विवरण',



    'cartTotal': 'कुल देवे वाला',







    'schemesTitle': 'सरकारी योजना पोर्टल',





    'mspLiveDashboard': 'लाइव MSP मंडी ट्रैकर',





    'sellerDashboard': 'विक्रेता डैशबोर्ड',







    'onboardingTitle': 'इकोससरूरल में स्वागत बा',







    'howItWorks': 'इकोससरूरल कईसे काम करेला',







    'missionImpact': 'हमार मिशन आ असर',







    'dashboardTour': 'डैशबोर्ड के सैर',







    'revisitTutorial': 'ट्यूटोरियल फेर देखीं',





    'settings': 'सेटिंग्स',





  },







  'raj': {



    'appName': 'इकोससरूरल',







    'tagline': 'पर्यावरण · शाश्वतता · ग्रामीण सशक्तिकरण',







    'welcome': 'इकोससरूरल में आपरो घणो स्वागत है!',







    'selectLanguage': 'भाषा चुणो',







    'searchLanguage': 'भाषा खोजो...',







    'confirmContinue': 'पुष्टि करो अर आगे बढ़ो',





    'changeLanguage': 'भाषा बदलो',







    'acceptContinue': 'स्वीकार करो अर आगे बढ़ो',







    'home': 'होम',







    'market': 'हाट',





    'learn': 'सीखो',







    'aiGuide': 'EcoSusRural AI',



    'profile': 'प्रोफाइल',







    'seller': 'विक्रेता केंद्र',







    'next': 'आगे',







    'back': 'पाछे',







    'submit': 'जमा करो',







    'save': 'सहेजो',







    'apply': 'अरजी लगाओ',







    'viewAll': 'सगळा देखो',







    'getStarted': 'शुरू करो',







    'skip': 'छोडो',







    'greetingPrefix': 'खम्मा घणी',







    'farmLookingGood': 'थांरो खेत आज घणो चोखो दिख रह्यो है!',







    'exploreModules': 'सगळा मॉड्यूल देखो',







    'weatherAdvisory': 'मौसम अर फसल सलाह',







    'quickActions': 'जल्दी काम',







    'marketplace': 'मार्केटप्लेस',





    'govtSchemes': 'सरकारी योजनावां',







    'mspSupport': 'MSP समर्थन',



    'weather': 'मौसम री जाणकारी',







    'learningAcademy': 'सीखण री अकादमी',







    'farmerHub': 'किसान प्रसंस्करण हब',







    'artisanHub': 'कारीगर दुनिया बाजार',







    'circularEconomy': 'कचरा निपटान व पुनर्चक्रण',





    'ethicsPledge': 'सत्यनिष्ठा व नैतिकता संकल्प',







    'searchMarketplace': 'GI टैग, जैविक, हस्तकला खोजो...',





    'addToCart': 'झोली में जोड़ो',







    'buyNow': 'इब ही खरीदो',







    'priceBreakdown': 'पारदर्शी मोल विवरण',







    'cartTotal': 'कुल देणी रकम',







    'schemesTitle': 'सरकारी योजना पोर्टल',





    'mspLiveDashboard': 'लाइव MSP मंडी ट्रैकर',





    'sellerDashboard': 'विक्रेता डैशबोर्ड',







    'onboardingTitle': 'इकोससरूरल में स्वागत है',







    'howItWorks': 'इकोससरूरल कीकर काम करे है',







    'missionImpact': 'म्हारो संकल्प अर प्रभाव',







    'dashboardTour': 'डैशबोर्ड रो फेरो',







    'revisitTutorial': 'ट्यूटोरियल पाछो देखो',





    'settings': 'सेटिंग्स',





  },







  'es': {



    'appName': 'EcoSusRural',



    'tagline': 'Ecología · Sostenibilidad · Empoderamiento Rural',



    'welcome': '¡Bienvenido a EcoSusRural!',



    'selectLanguage': 'Seleccionar idioma',



    'searchLanguage': 'Buscar idioma...',



    'confirmContinue': 'Confirmar y continuar',



    'changeLanguage': 'Cambiar idioma',



    'acceptContinue': 'Aceptar y continuar',



    'home': 'Inicio',



    'market': 'Mercado',



    'learn': 'Aprender',



    'aiGuide': 'EcoSusRural AI',



    'profile': 'Perfil',



    'seller': 'Centro de Vendedores',



    'next': 'Siguiente',



    'back': 'Atrás',



    'submit': 'Enviar',



    'save': 'Guardar',



    'apply': 'Aplicar ahora',



    'viewAll': 'Ver todo',



    'getStarted': 'Comenzar',



    'skip': 'Omitir',



    'greetingPrefix': 'Hola',



    'farmLookingGood': '¡Tu granja se ve excelente hoy!',



    'exploreModules': 'Explorar Módulos',



    'weatherAdvisory': 'Clima y Asesoramiento Agrícola',



    'quickActions': 'Acciones Rápidas',



    'marketplace': 'Mercado',



    'govtSchemes': 'Programas Gubernamentales',



    'mspSupport': 'Soporte MSP',



    'weather': 'Inteligencia Meteorológica',



    'learningAcademy': 'Academia de Aprendizaje',



    'farmerHub': 'Centro de Valor Agregado Agrícola',



    'artisanHub': 'Mercado Global de Artesanos',



    'circularEconomy': 'Economía Circular',



    'ethicsPledge': 'Integridad y Ética',



    'searchMarketplace': 'Buscar productos con IG, orgánicos, artesanías...',



    'addToCart': 'Añadir al carrito',



    'buyNow': 'Comprar ahora',



    'priceBreakdown': 'Desglose transparente de precios',



    'cartTotal': 'Total a pagar',



    'schemesTitle': 'Portal de Programas Públicos y Privados',



    'mspLiveDashboard': 'Seguimiento MSP en Vivo',



    'sellerDashboard': 'Panel del Vendedor',



    'onboardingTitle': 'Bienvenido a EcoSusRural',



    'howItWorks': 'Cómo funciona EcoSusRural',



    'missionImpact': 'Nuestra Misión e Impacto',



    'dashboardTour': 'Recorrido del Panel',



    'revisitTutorial': 'Ver Tutorial de Nuevo',



    'settings': 'Configuración',



  },







  'fr': {



    'appName': 'EcoSusRural',



    'tagline': 'Écologie · Durabilité · Autonomisation Rurale',



    'welcome': 'Bienvenue sur EcoSusRural !',



    'selectLanguage': 'Sélectionner la langue',



    'searchLanguage': 'Rechercher une langue...',



    'confirmContinue': 'Confirmer et continuer',



    'changeLanguage': 'Changer de langue',



    'acceptContinue': 'Accepter et continuer',



    'home': 'Accueil',



    'market': 'Marché',



    'learn': 'Apprendre',



    'aiGuide': 'EcoSusRural AI',



    'profile': 'Profil',



    'seller': 'Espace Vendeur',



    'next': 'Suivant',



    'back': 'Retour',



    'submit': 'Soumettre',



    'save': 'Enregistrer',



    'apply': 'Postuler',



    'viewAll': 'Voir tout',



    'getStarted': 'Commencer',



    'skip': 'Passer',



    'greetingPrefix': 'Bonjour',



    'farmLookingGood': 'Votre ferme se porte à merveille aujourd\'hui !',



    'exploreModules': 'Explorer les Modules',



    'weatherAdvisory': 'Météo et Conseils Agricoles',



    'quickActions': 'Actions Rapides',



    'marketplace': 'Place de marché',



    'govtSchemes': 'Programmes Gouvernementaux',



    'mspSupport': 'Soutien MSP',



    'weather': 'Renseignements Météorologiques',



    'learningAcademy': 'Académie d\'Apprentissage',



    'farmerHub': 'Pôle Valeur Ajoutée Agricole',



    'artisanHub': 'Marché Mondial des Artisans',



    'circularEconomy': 'Économie Circulaire',



    'ethicsPledge': 'Intégrité et Éthique',



    'searchMarketplace': 'Rechercher produits certifiés IG, bio, artisanat...',



    'addToCart': 'Ajouter au panier',



    'buyNow': 'Acheter maintenant',



    'priceBreakdown': 'Détail transparent des prix',



    'cartTotal': 'Total à payer',



    'schemesTitle': 'Portail des Programmes Publics et Privés',



    'mspLiveDashboard': 'Suivi des Prix MSP en Direct',



    'sellerDashboard': 'Tableau de bord Vendeur',



    'onboardingTitle': 'Bienvenue sur EcoSusRural',



    'howItWorks': 'Comment fonctionne EcoSusRural',



    'missionImpact': 'Notre Mission et Impact',



    'dashboardTour': 'Visite du Tableau de bord',



    'revisitTutorial': 'Revoir le tutoriel',



    'settings': 'Paramètres',



  },



};







class AppLanguageState {



  final String code;



  final bool isLoading;







  const AppLanguageState({this.code = 'en', this.isLoading = true});







  AppLanguageState copyWith({String? code, bool? isLoading}) {



    return AppLanguageState(



      code: code ?? this.code,



      isLoading: isLoading ?? this.isLoading,



    );



  }



}







class LanguageNotifier extends StateNotifier<AppLanguageState> {



  LanguageNotifier() : super(const AppLanguageState());







  /// Cached translation engines per language code. Constructing an engine on



  /// every tr() call is the hottest path in the app (every localized string in



  /// every build), so engines are reused until a new asset pack is loaded.



  final Map<String, TranslationEngine> _engineCache = {};







  TranslationEngine _engineFor(String targetCode) {



    return _engineCache.putIfAbsent(targetCode, () {



      return TranslationEngine(



        pack: TranslationRepository.instance.snapshot(targetCode),



        parentPack: TranslationRepository.instance.snapshot(



          TranslationRepository.instance.parentOf(targetCode) ?? '',



        ),



        enPack: _localizedStrings['en']!,



        glossary: kGlossary,



        code: targetCode,



        // Indian languages fall back to Hindi before English so dialect



        // users always see an Indic string instead of raw English.



        fallbackPacks:



            (targetCode != 'hi' && _isIndianLanguage(targetCode))



                ? [_localizedStrings['hi']!]



                : const [],



      );



    });



  }







  /// True when the code belongs to an Indian language or dialect.



  static bool _isIndianLanguage(String code) {



    final entry = AllLanguages.byCode(code);



    return entry != null && entry.tag != 'Foreign';



  }







  /// Called after an asset pack finishes loading so cached engines rebuild



  /// with the fresh pack (keeps translation results identical to before).



  void _invalidateEngineCache() => _engineCache.clear();







  /// Loads the persisted language code from device storage at startup.



  /// Any of the 100 registered codes is accepted (packs come from assets).



  Future<void> loadSavedLanguage() async {



    final prefs = await SharedPreferences.getInstance();



    final saved = prefs.getString('selected_language') ?? 'en';



    final normalized = saved.trim().toLowerCase();



    final safeCode = normalized.isEmpty ? 'en' : normalized;



    state = AppLanguageState(code: safeCode, isLoading: false);



    // Manifest and language pack load concurrently (independent assets).



    await Future.wait([



      TranslationRepository.instance.loadManifest(),



      TranslationRepository.instance.packFor(safeCode),



    ]);



    _invalidateEngineCache();



  }







  /// Persists the selected language and updates the global locale immediately.



  Future<void> changeLanguage(String code) async {



    final normalized = code.trim().toLowerCase();



    final safeCode = normalized.isEmpty ? 'en' : normalized;



    state = state.copyWith(code: safeCode, isLoading: false);



    final prefs = await SharedPreferences.getInstance();



    await prefs.setString('selected_language', safeCode);



    await TranslationRepository.instance.packFor(safeCode);



    _invalidateEngineCache();



  }







  /// Returns the localized string for a given key, resolving dialects and falling back to English.



  /// Resolution order: asset pack -> parent dialect pack -> bundled map -> English -> glossary -> key.



  String translate(String key, [String? languageCode]) {
    final rawCode = (languageCode ?? state.code).trim().toLowerCase();
    return translateSync(key, rawCode);
  }

  /// Translates text with parameter interpolation and proper-noun immunity protection.
  String translateWithParams(String key, [Map<String, String>? params, String? languageCode]) {
    String text = translate(key, languageCode);
    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, paramVal) {
        text = text.replaceAll('{$paramKey}', paramVal);
      });
    }
    // Proper-Noun Immunity Rule: Brand name 'EcoSusRural' is guaranteed strictly untouched
    text = text.replaceAll(RegExp(r'\{brandName\}', caseSensitive: false), 'EcoSusRural');
    return text;
  }







  /// Synchronous variant backed by the bundled maps + primed asset packs.



  /// Never throws; never breaks app functions when a word is missing.



  String translateSync(String key, [String? languageCode]) {



    final rawCode = (languageCode ?? state.code).trim().toLowerCase();



    final targetCode = rawCode.isEmpty ? 'en' : rawCode;



    final engine = _engineFor(targetCode);



    final bundled = _translateBundled(key, targetCode);



    if (bundled != null) return bundled;



    return engine.resolve(key).text;



  }







  /// Async variant that first ensures the asset pack is loaded.



  Future<String> translateAsync(String key, [String? languageCode]) async {



    final rawCode = (languageCode ?? state.code).trim().toLowerCase();



    final targetCode = rawCode.isEmpty ? 'en' : rawCode;



    await TranslationRepository.instance.packFor(targetCode);



    return translateSync(key, targetCode);



  }







  /// SINGLE-LANGUAGE MODE: translated content directly in original structure.



  Map<String, String> translateBundle(Iterable<String> keys,



      [String? languageCode]) {



    final rawCode = (languageCode ?? state.code).trim().toLowerCase();



    final out = <String, String>{};



    for (final k in keys) {



      out[k] = translateSync(k, rawCode);



    }



    return out;



  }







  /// MULTI-LANGUAGE BUNDLE MODE: {code: {key: text}} for a list of targets.



  Map<String, Map<String, String>> translateBundleMany(



      Iterable<String> keys, Iterable<String> targets) {



    final out = <String, Map<String, String>>{};



    for (final t in targets) {



      out[t] = translateBundle(keys, t);



    }



    return out;



  }







  /// Looks up only the compile-time bundled maps (no asset access).



  /// Returns null when nothing is found so the caller can use the engine.



  String? _translateBundled(String key, String targetCode) {



    if (_localizedStrings.containsKey(targetCode)) {



      final map = _localizedStrings[targetCode]!;



      if (map.containsKey(key)) return map[key]!;



    }



    final parentCode = kDialectToParent[targetCode];



    if (parentCode != null && _localizedStrings.containsKey(parentCode)) {



      final map = _localizedStrings[parentCode]!;



      if (map.containsKey(key)) return map[key]!;



    }



    // Regional group fallback: Indian languages get Hindi before English.



    if (_isIndianLanguage(targetCode)) {



      final hiMap = _localizedStrings['hi']!;



      if (hiMap.containsKey(key)) return hiMap[key];



    }



    final enMap = _localizedStrings['en']!;



    if (enMap.containsKey(key)) {



      // Only short-circuit when the target has no asset pack; otherwise



      // let the engine decide so asset + glossary rules stay consistent.



      if (TranslationRepository.instance.snapshot(targetCode).isEmpty) {



        return enMap[key];



      }



    }



    return null;



  }



}







final languageProvider =



    StateNotifierProvider<LanguageNotifier, AppLanguageState>((ref) => LanguageNotifier());







/// Helper extension on WidgetRef for clean, reactive dynamic translation in any Consumer widget



extension WidgetRefTranslation on WidgetRef {
  /// Translates a key dynamically for the active locale, supporting parameter interpolation.
  String tr(String key, [Map<String, String>? params]) {
    // Watch languageProvider state so that any language change triggers an immediate rebuild!
    final langState = watch(languageProvider);
    final notifier = read(languageProvider.notifier);
    return notifier.translateWithParams(key, params, langState.code);
  }
}







/// A glossary of terms that may be missing in some languages.



/// When a key is not found in any translation map, this glossary provides



/// a short explanation in the user's language at that place.



const Map<String, Map<String, String>> _fallbackGlossary = {



  'marketplace': {



    'en': 'A place where farmers and artisans sell products directly to buyers.',



    'hi': 'किसानों और कारीगरों के लिए सीधे खरीदारों को उत्पाद बेचने का स्थान।',



    'bn': 'কৃষক ও কারিগররা সরাসরি ক্রেতাদের কাছে পণ্য বিক্রি করেন এমন জায়গা।',



    'te': 'రైతులు మరియు శిల్పులు నేరుగా కొనుగోలుదారులకు వస్తువులను అమ్మే ప్రదేశం.',



    'ta': 'விவசாயிகள் மற்றும் கைவினைஞர்கள் நேரடியாக வாங்குபவர்களுக்கு பொருட்களை விற்கும் இடம்.',



    'mr': 'शेतकरी आणि कारागीर थेट खरेदीदारांना उत्पादन विकतात ठिकाण.',



    'gu': 'ખેડૂતો અને કારીગરો સીધા ખરીદારોને ઉત્પાદન વેચે છે તે સ્થળ.',



    'ar': 'مكان يبيع فيه المزارعون والحرفيون المنتجات مباشرة للمشترين.',



    'es': 'Un lugar donde agricultores y artesanos venden productos directamente a compradores.',



    'fr': 'Un endroit où les agriculteurs et artisans vendent des produits directement aux acheteurs.',



    'de': 'Ein Ort, an dem Landwirte und Handwerker Produkte direkt an Käufer verkaufen.',



  },



  'subscription': {



    'en': 'A recurring payment plan that gives you benefits for a fixed period (day/week/month/year).',



    'hi': 'एक आवर्ती भुगतान योजना जो आपको एक निश्चित अवधि (दिन/सप्ताह/महीना/वर्ष) के लिए लाभ देती है।',



    'bn': 'একটি পুনরাবৃত্তি পেমেন্ট পরিকল্পনা যা নির্দিষ্ট সময়ের জন্য সুবিধা দেয়।',



    'te': 'నిర్దిష్ట కాలానికి ప్రయోజనాలు ఇచ్చే పునరావృత్ చెల్లింపు ప్రణాళిక.',



    'ta': 'ஒரு குறிப்பிட்ட காலத்திற்கு நன்மைகளை வழங்கும் திரும்பவரும் கட்டண திட்டம்.',



    'mr': 'निश्चित कालावधीसाठी फायदे देणारा पुనరావృత్తी पेमेंट योजना.',



    'gu': 'નિશ્ચિત સમયગાળા માટે લાભો આપતી પુનરાવર્તિત ચૂકવણી યોજના.',



    'ar': 'خطة دفع متكررة تمنحك مزايا لفترة محددة.',



    'es': 'Un plan de pago recurrente التي تمنحك فوائد لفترة محددة.',



    'de': 'Ein wiederkehrender Zahlungsplan, der Ihnen Vorteile für einen festen Zeitraum gibt.',



  },



  'wallet': {



    'en': 'Your digital money storage inside the app for payments and transfers.',



    'hi': 'भुगतान और स्थानांतरण के लिए ऐप के अंदर आपका डिजिटल पैसा भंडारण।',



    'bn': 'পেমেন্ট এবং ট্রান্সফারের জন্য অ্যাপের ভিতরে আপনার ডিজিটাল টাকা সঞ্চয়।',



    'te': 'చెల్లింపులు మరియు బదిలీల కోసం యాప్ లోపల మీ డిజిటల్ డబ్బు నిల్వ.',



    'ta': 'கொடுப்பனவு மற்றும் பரிமாற்றங்களுக்கான செயலியின் உள்ளே உங்கள் டிஜிட்டல் பணச் சேமிப்பு.',



    'mr': 'पेमेंट आणि ट्रान्सफरसाठी अॅपमधील तुमचे डिजिटल पैसे साठवणूक.',



    'gu': 'ચૂકવણી અને ટ્રાન્સફર માટે એપની અંદર તમારી ડિજિટલ પૈસાનો સંગ્રહ.',



    'ar': 'تخزين أموالك الرقمية داخل التطبيق للمدفوعات والتحويلات.',



    'es': 'Su almacenamiento de dinero digital dentro de la aplicación para pagos y transferencias.',



    'de': 'Ihre digitale Geldbewahrung innerhalb der App für Zahlungen und Überweisungen.',



  },



};







/// Localizations for EcoSusRural.



class LanguageLocalizations {



  final Locale locale;



  LanguageLocalizations(this.locale);







  static LanguageLocalizations? of(BuildContext? context) => null;







  String translate(String key, [String? languageCode]) {



    final code = (languageCode ?? locale.languageCode).trim().toLowerCase();



    if (_localizedStrings.containsKey(code)) {



      final map = _localizedStrings[code]!;



      if (map.containsKey(key)) return map[key]!;



    }



    final parent = kDialectToParent[code];



    if (parent != null && _localizedStrings.containsKey(parent)) {



      final map = _localizedStrings[parent]!;



      if (map.containsKey(key)) return map[key]!;



    }



    if (code != 'hi' && kDialectToParent[code] != null &&



        _localizedStrings['hi']!.containsKey(key)) {



      return _localizedStrings['hi']![key]!;



    }



    if (_localizedStrings.containsKey('en')) {



      final enMap = _localizedStrings['en']!;



      if (enMap.containsKey(key)) return enMap[key]!;



    }



    if (_fallbackGlossary.containsKey(key)) {



      final g = _fallbackGlossary[key]!;



      return g[code] ?? g['en'] ?? key;



    }



    return key;



  }



}
