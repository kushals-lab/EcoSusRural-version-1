# EcoSusRural Project Migration Manifest

**Timestamp:** 2026-10-24T02:30:00+05:30  
**Project Root:** `c:\Users\user\OneDrive\Desktop\EcoSusRural mvp`  
**Migration Mode:** Non-destructive copy & descriptive feature-specific renaming  
**Original Files Status:** 100% Preserved & Unmodified  

---

## 1. Migration File Mapping Manifest

| ID | Original Location | Migrated Location | Feature Domain | Integrity / Verification |
|---|---|---|---|---|
| M01 | `docs/DATABASE_SCHEMA.md` (DDL) | `database/ecosusrural_postgresql_schema.sql` | PostgreSQL Relational Schema | Created / Verified |
| M02 | `backend/src/db/postgres.js` | `database/ecosusrural_database_connection.js` | Database Connection Pool (Node.js) | Verified |
| M03 | Architecture specification | `database/ecosusrural_database_connection.py` | Database Connection Pool (Python) | Created / Verified |
| M04 | `backend/src/routes/mandiRoutes.js` | `backend/src/routes/mandi_price_api_service.js` | Live Mandi Price API (data.gov.in) | Verified |
| M05 | `backend/src/routes/weatherRoutes.js` | `backend/src/routes/live_weather_service.js` | Meteorological Forecast (Open-Meteo) | Verified |
| M06 | `backend/src/routes/dryerRoutes.js` | `backend/src/routes/solar_dryer_telemetry_routes.js` | Smart Solar Dryer IoT Telemetry | Verified |
| M07 | `backend/src/routes/paymentRoutes.js` | `backend/src/routes/ecobharat_pay_payment_routes.js` | EcoBharat Pay Payment Processing | Verified |
| M08 | `backend/src/routes/schemeRoutes.js` | `backend/src/routes/government_schemes_routes.js` | Government Schemes & Subsidies | Verified |
| M09 | `backend/src/routes/apiGateway.js` | `backend/src/routes/python_ai_engine_proxy_gateway.js` | Python AI Engine Microservice Proxy | Verified |
| M10 | `backend/src/routes/authRoutes.js` | `backend/src/routes/authentication_routes.js` | Multi-Factor Authentication & Tokens | Verified |
| M11 | `backend/src/ai/gateway.js` | `backend/src/ai/rural_ai_gateway_service.js` | Rural AI Gateway & Vision Validation | Verified |
| M12 | `backend/src/ai/answerEngine.js` | `backend/src/ai/grounded_answer_engine.js` | Grounded Multi-Tool Answer Engine | Verified |
| M13 | `backend/src/ai/adapters/textModel.js` | `backend/src/ai/adapters/openai_compatible_text_adapter.js` | OpenAI-compatible Chat Model Adapter | Verified |
| M14 | `backend/src/ai/adapters/visionModel.js` | `backend/src/ai/adapters/agricultural_vision_adapter.js` | Agricultural Vision Pipeline Adapter | Verified |
| M15 | `backend/src/ai/tools/analytics.js` | `backend/src/ai/tools/agricultural_rainfall_analytics.js` | Rainfall & Trend Analytics Tool | Verified |
| M16 | `backend/src/ai/tools/sources.js` | `backend/src/ai/tools/grounded_sources_catalog.js` | Grounded Data Catalog & Source Audit | Verified |
| M17 | `backend/src/ai/tools/weatherForecast.js` | `backend/src/ai/tools/open_meteo_forecast_tool.js` | Open-Meteo Live Forecast Fetcher | Verified |
| M18 | `backend/src/ai/tools/weatherHistory.js` | `backend/src/ai/tools/open_meteo_history_cache_tool.js` | Historical Weather Cache & Archive | Verified |
| M19 | `backend/src/data/schemes.js` | `backend/src/data/government_schemes_repository.js` | Verified Government Schemes Dataset | Verified |
| M20 | `backend/src/realtime/chatSocket.js` | `backend/src/realtime/e2ee_realtime_chat_socket_gateway.js` | E2EE WebSocket Chat Gateway | Verified |
| M21 | `backend/src/security/secrets.js` | `backend/src/security/jwt_secrets_resolver.js` | Production Fail-Closed JWT Secrets | Verified |
| M22 | `backend/src/controllers/paymentControllers.js` | `backend/src/controllers/ecobharat_pay_controller.js` | Idempotent Payment Processor | Verified |
| M23 | `backend/smoke_test.js` | `backend/security_smoke_test_suite.js` | Backend Security Smoke Test Suite | Verified |
| M24 | `backend/smoke_test.mjs` | `backend/security_smoke_test_suite.mjs` | Backend Security Smoke Test Suite (ESM) | Verified |
| M25 | `backend/fix_end.py` | `backend/repair_smoke_test_exit_handler.py` | Exit Handler Deduplication Script | Verified |
| M26 | `backend/fix_end2.py` | `backend/truncate_duplicate_test_runner.py` | Duplicate Main Handler Truncation Tool | Verified |
| M27 | `backend/fix_end3.py` | `backend/generate_security_smoke_test.py` | Security Smoke Test Code Generator | Verified |
| M28 | `ai_service/compute_model.py` | `ai_service/sustainability_scoring_model.py` | Sustainability Score Math Model | Verified |
| M29 | `ai_service/config.py` | `ai_service/ai_service_environment_config.py` | AI Microservice Configuration | Verified |
| M30 | `ai_service/main.py` | `ai_service/rural_ai_assistant_service.py` | Rural AI Assistant FastAPI Server | Verified |
| M31 | `ai_service/utils.py` | `ai_service/ai_payload_sanitizer.py` | AI Request Payload Sanitizer | Verified |
| M32 | `scripts/_write_rural_provider.ps1` | `scripts/generate_rural_search_provider.ps1` | Rural Search Provider Generator | Verified |
| M33 | `scripts/final_verify.py` | `scripts/verify_seller_registration_flow.py` | Seller Registration Verification Suite | Verified |
| M34 | `scripts/remove_otpsent.py` | `scripts/patch_seller_registration_otp.py` | Seller OTP Dead-Code Patch Script | Verified |
| M35 | `scripts/run_windows.ps1` | `scripts/launch_windows_sac_runner.ps1` | Windows Smart App Control Runner | Verified |

---

## 2. Reversal Instructions

To completely reverse this migration without affecting any core application behavior:
```powershell
Remove-Item -Recurse -Force "database"
Remove-Item -Force "backend\src\routes\mandi_price_api_service.js"
Remove-Item -Force "backend\src\routes\live_weather_service.js"
Remove-Item -Force "backend\src\routes\solar_dryer_telemetry_routes.js"
Remove-Item -Force "backend\src\routes\ecobharat_pay_payment_routes.js"
Remove-Item -Force "backend\src\routes\government_schemes_routes.js"
Remove-Item -Force "backend\src\routes\python_ai_engine_proxy_gateway.js"
Remove-Item -Force "backend\src\routes\authentication_routes.js"
Remove-Item -Force "backend\src\ai\rural_ai_gateway_service.js"
Remove-Item -Force "backend\src\ai\grounded_answer_engine.js"
Remove-Item -Force "backend\src\ai\adapters\openai_compatible_text_adapter.js"
Remove-Item -Force "backend\src\ai\adapters\agricultural_vision_adapter.js"
Remove-Item -Force "backend\src\ai\tools\agricultural_rainfall_analytics.js"
Remove-Item -Force "backend\src\ai\tools\grounded_sources_catalog.js"
Remove-Item -Force "backend\src\ai\tools\open_meteo_forecast_tool.js"
Remove-Item -Force "backend\src\ai\tools\open_meteo_history_cache_tool.js"
Remove-Item -Force "backend\src\data\government_schemes_repository.js"
Remove-Item -Force "backend\src\realtime\e2ee_realtime_chat_socket_gateway.js"
Remove-Item -Force "backend\src\security\jwt_secrets_resolver.js"
Remove-Item -Force "backend\src\controllers\ecobharat_pay_controller.js"
Remove-Item -Force "backend\security_smoke_test_suite.js"
Remove-Item -Force "backend\security_smoke_test_suite.mjs"
Remove-Item -Force "backend\repair_smoke_test_exit_handler.py"
Remove-Item -Force "backend\truncate_duplicate_test_runner.py"
Remove-Item -Force "backend\generate_security_smoke_test.py"
Remove-Item -Force "ai_service\sustainability_scoring_model.py"
Remove-Item -Force "ai_service\ai_service_environment_config.py"
Remove-Item -Force "ai_service\rural_ai_assistant_service.py"
Remove-Item -Force "ai_service\ai_payload_sanitizer.py"
Remove-Item -Force "scripts\generate_rural_search_provider.ps1"
Remove-Item -Force "scripts\verify_seller_registration_flow.py"
Remove-Item -Force "scripts\patch_seller_registration_otp.py"
Remove-Item -Force "scripts\launch_windows_sac_runner.ps1"
```
