/// 20-question exporter exam: 15 MCQ + 5 subjective on becoming a global exporter.
library exporter_quiz;

import 'processing_models.dart';

const List<ExporterQuizQuestion> kExporterQuiz = [
  ExporterQuizQuestion(
    id: 'q1',
    question: 'Which code is mandatory to start exports from India?',
    options: ['IEC from DGFT', 'PAN only', 'GST only', 'FSSAI only'],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q2',
    question: 'Which system classifies handicrafts for customs duty?',
    options: ['HS codes', 'PIN codes', 'IFSC codes', 'MICR codes'],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q3',
    question: 'FSSAI licensing for dried foods mainly assures what?',
    options: [
      'Food safety & hygiene compliance',
      'Export subsidy approval',
      'Currency conversion',
      'Courier booking'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q4',
    question: 'Which certificate helps an organic product earn the Organic Tag?',
    options: [
      'Accredited lab test + physical sample verification',
      'Only a self-declaration',
      'Only a photo of the farm',
      'Only a buyer email'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q5',
    question: 'Why must every export lot send a physical sample to our lab?',
    options: [
      'Proper tests before the Organic Tag for domestic + export use',
      'To increase courier business',
      'To delay the shipment',
      'To change the product colour'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q6',
    question: 'Spice Board CRES registration is needed for what?',
    options: [
      'Exporting spices officially',
      'Selling vegetables locally',
      'Booking cold storage',
      'Printing invoices'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q7',
    question: 'Pesticide-residue testing on spices protects what?',
    options: [
      'EU/US buyer acceptance & consumer health',
      'Only the packaging colour',
      'Only the transport speed',
      'Only the invoice font'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q8',
    question: 'Vacuum drying is preferred over open sun-drying because…',
    options: [
      'It retains aroma, colour and nutrition hygienically',
      'It is always free',
      'It needs no electricity ever',
      'It removes all taste'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q9',
    question: 'Warehouse receipt financing lets a farmer…',
    options: [
      'Get a loan against stored stock',
      'Avoid all storage',
      'Skip lab tests',
      'Sell without invoice'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q10',
    question: 'Seller handles export clearance + freight under which incoterm?',
    options: ['CIF', 'EXW', 'DDU (buyer clears)', 'FOR (domestic rail)'],
    correctIndex: 0,
  ),

  ExporterQuizQuestion(
    id: 'q11',
    question: 'A biodegradable product in our marketplace must be…',
    options: [
      'Compostable / eco-safe whether GI-tagged or not',
      'Only GI-tagged',
      'Only plastic-coated',
      'Only imported'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q12',
    question: 'Cold-chain + moisture-sealed transit matters most for…',
    options: [
      'Dried fruits & dehydrated vegetables',
      'Iron tools',
      'Cement bags',
      'Printed books'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q13',
    question: 'Which document quotes moisture, purity and shelf-life?',
    options: [
      'Lab quality certificate',
      'Visiting card',
      'Pamphlet',
      'Greeting card'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q14',
    question: 'Fair-price guarantee in the artisan hub means…',
    options: [
      'Artisan cost + dignified margin, no middlemen',
      'Lowest possible artisan payout',
      'Random pricing daily',
      'Buyer decides after delivery'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q15',
    question: 'Master Farmer Faculty lets a farmer…',
    options: [
      'Teach video courses & earn in off-season',
      'Only watch ads',
      'Delete lab reports',
      'Avoid storage booking'
    ],
    correctIndex: 0,
  ),
  ExporterQuizQuestion(
    id: 'q16',
    isSubjective: true,
    question:
        'Describe your product, target country and which lab reports you will upload before sending the physical sample.',
    guidance:
        'Mention product, country, FSSAI/pesticide/microbiology reports as applicable, then sample dispatch.',
  ),
  ExporterQuizQuestion(
    id: 'q17',
    isSubjective: true,
    question:
        'Work out your first export costing: product cost + packaging + freight + margin. Show the steps.',
    guidance:
        'Show per-unit cost, packaging, freight, duties and your margin to reach the CIF price.',
  ),
  ExporterQuizQuestion(
    id: 'q18',
    isSubjective: true,
    question:
        'Which storage did you book (item, days, per-day charge) and what is your expected bill with packaging?',
    guidance: 'Use: bill = days x per-day charge + packaging cost.',
  ),
  ExporterQuizQuestion(
    id: 'q19',
    isSubjective: true,
    question:
        'For your dried produce, state the wet:dry ratio you assume (default 9:1) and the expected daily output.',
    guidance:
        'Example: 90 kg wet mango at 9:1 gives about 10 kg dried per day.',
  ),
  ExporterQuizQuestion(
    id: 'q20',
    isSubjective: true,
    question:
        'How will you keep the product biodegradable / plastic-free from farm to buyer?',
    guidance:
        'Mention compostable pouches, paper tape, jute fillers and take-back if any.',
  ),
];
