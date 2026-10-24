# Part 1 implementation checklist

## Inspected architecture

Flutter uses Riverpod, Material routes, ScreenUtil, shared_preferences and http.
The public API is Express; FastAPI is an authenticated AI compute service, not
the user or weather API. PostgreSQL is accessed through parameterized pg queries.
The existing Bhashini/translation repository and language packs are preserved.
Existing uncommitted changes predate this task and are not reset.

## Implementation and verification

- [ ] Network transport versus backend health, retries, cancellation, cache provenance.
- [ ] Account-scoped location selection, native permission denial, manual search, Settings.
- [ ] Real weather, selected coordinates, timestamps, active refresh, responsive forecast.
- [ ] Persistent reminders, Android scheduling, reboot, horizon, stopwatch/timer/world clock.
- [ ] Verified external scheme destinations and honest application status.
- [ ] Separate mandi/MSP sources, timestamps, history and protected grievance support.
- [ ] Value-addition pages 5.1–5.5 and navigation/layout regression checks.
- [ ] Offline learning/product drafts and safe upload resumption.
- [ ] Analysis, relevant tests, API validation, file-by-file report and deployment gaps.

## External constraints to verify

No credentials or subscription entitlements are assumed. OpenWeather 5-day data
cannot supply seven daily forecasts; the existing Open-Meteo adapter is retained
for seven-day forecasts. Commercial Open-Meteo usage requires appropriate terms.
Local registration currently does not issue a trusted backend access token;
account synchronization must fail closed until real authentication is configured.
Physical Android permission, reboot and alarm delivery need device verification.

## Sources reviewed

- https://openweathermap.org/price
- https://open-meteo.com/en/docs
- https://open-meteo.com/en/docs/geocoding-api
- https://developer.android.com/develop/background-work/services/alarms
- https://developer.android.com/about/versions/14/changes/schedule-exact-alarms
- https://www.pmkisan.gov.in/RegistrationFormupdated.aspx
- https://pgportal.gov.in/
