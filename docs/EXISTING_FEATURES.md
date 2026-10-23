# EXISTING FEATURES INVENTORY: EcoSusRural

This document details every feature currently implemented, verified, and operational in the codebase.

---

## 1. Multilingual Support & Bhashini Scaffolding
- **100+ Language Framework:** Official Schedule 8 Indian languages + major regional dialects + international languages.
- **Hierarchical Fallback:** Missing keys resolve to parent dialect, then to English, then to in-memory glossary, ensuring zero UI breakage.
- **Persistence:** User language preference persists across app lifecycles via `shared_preferences`.

## 2. Authentication & Role-Based Access Control (RBAC)
- **Role Coverage:** Buyer, Farmer, Artisan, Craftsperson, SHG, FPO, MSME, Wholesaler, Exporter, Hub Operator, Agricultural Expert, Admin.
- **Phone OTP Authentication:** Client-side local OTP verification with dev-bypass gating (`ECSUS_DEV_LOGIN`) and server-side proxy hooks.
- **Single-Device Session:** Hardware/session tracking tokens to prevent unauthorized multi-device concurrency.

## 3. Profiles & Document Verification
- **Farmer Profile Setup:** Land holding area, soil classifications, organic/conventional declaration, primary crop lists.
- **Seller Verification:** Business registration submission, GSTIN/Udyam input fields, KYC document upload workflow with privacy controls.

## 4. Rural Marketplace, Products & Batches
- **Product Catalog:** Categories for dried produce, spices, handicrafts, organic inputs, farm tools, and solar appliances.
- **Batch Tracking & Traceability:** QR code generation linking batches to source farm, drying date, and moisture content.
- **Cart & Order Flow:** Multi-item cart management with quantity adjustment and dynamic total calculation.

## 5. Payments (EcoBharat Pay)
- **Unified Interface:** EcoBharat Pay checkout experience with UPI QR display, wallet balance simulation, and payment authorization flow.
- **Server Verification Support:** Backend routes for verifying signature tokens and preventing client-side payment spoofing.

## 6. Smart Solar Dryer Monitoring
- **Dual Transport:** Bluetooth Low Energy (BLE) scanning & pairing alongside WiFi HTTP streaming.
- **Crop Profiles:** Standardized drying curves and target moisture thresholds for Chilies, Ginger, Turmeric, Tomatoes, Grapes, and Herbs.
- **Real-Time Telemetry:** Live temperature, humidity, airflow, and battery charge level visualization with `CustomPainter` charts.

## 7. Weather & Mandi Impact Intelligence
- **Live Weather Integration:** Direct live connection to Open-Meteo with 7-day hourly and daily forecast metrics.
- **Mandi Arrival Projection:** Algorithmic calculation of rain/heat impact on agricultural market arrivals and local price volatility.

## 8. Government Schemes & Subsidies
- **Scheme Explorer:** Searchable database of central and state agricultural schemes (PM-KISAN, PMFBY, SMAM, Solar Subsidy schemes).
- **Application Assistance:** Step-by-step document checklist and direct application submission wizard.

## 9. Rural Education & Skill Development
- **Course Catalog:** Video tutorials and guides on modern solar drying, natural farming inputs, organic certification, and export packaging.
- **Progress Tracking:** Completed module checklist and practical assessment quizzes.
