# Android signing fingerprints

Extracted from `build/verified/EcoSusRural-internal-test.apk` on 24 October 2026.

- Application ID: `com.example.eco_sus_rural`
- Certificate subject: `CN=Android Debug, O=Android, C=US`
- SHA-1: `56:C4:72:27:A0:DA:5E:CD:99:C3:90:59:7E:A8:8F:30:B0:B4:5E:62`
- SHA-256: `14:A7:6D:13:B9:67:4B:9F:2F:47:BF:31:23:29:32:B1:69:7B:61:28:13:A5:21:6D:8C:C2:B9:E8:78:CF:48:C4`

These are public certificate fingerprints. The current release build uses the debug signing certificate. A future private release key or Google Play app signing certificate will have different fingerprints and must also be registered for Google authentication.

Recheck the certificate directly from any APK:

```powershell
node scripts/apk-signing-certificate.cjs build/verified/EcoSusRural-internal-test.apk
```
