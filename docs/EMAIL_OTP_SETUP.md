# Email OTP sign-in

Email OTP uses Gmail SMTP through the Node backend. MongoDB stores short-lived hashed challenges in `email_otps` and verified accounts in `users`. The mobile app never receives the SMTP password or a server-generated code in an API response. Redis is not required for this flow.

## Local sender configuration

In the sending Google account, enable 2-Step Verification and create an app password. See [Google's app password instructions](https://support.google.com/accounts/answer/185833). This password authorizes the server to send mail; it is separate from the Google sign-in OAuth client ID.

Configure the ignored `backend/.env.local`:

```dotenv
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465
SMTP_SECURE=true
SMTP_USER=your-sender@gmail.com
SMTP_PASS=
SMTP_FROM="EcoSusRural" <your-sender@gmail.com>
```

Enter the app password locally after `SMTP_PASS=` and save. Never commit this file or include SMTP credentials in Flutter build settings. `JWT_SECRET` must be a strong persistent secret; email OTP HMAC protection uses a separately derived key from that secret.

Build and restart the backend after configuring the sender:

```powershell
cd backend
npm.cmd run build
npm.cmd test
npm.cmd start
```

Only one backend instance should use local port 5000. Stop the existing instance in its terminal before starting the updated code. Public deployment must use HTTPS and the host's secret environment settings.

## API and app

- `POST /api/auth/send-otp` with `{ "email": "recipient@example.org" }` validates the address and requests mail delivery. An HTTP 200 means the SMTP provider accepted the message, not proof it reached the inbox.
- `POST /api/auth/verify-otp` with `{ "email": "recipient@example.org", "otp": "123456" }` verifies the actual emailed code. The example value is not a bypass.
- Success returns a server access token, the account profile, and a separate email-verification token. Verification tokens are not accepted as access tokens.
- `/api/auth/me` restores the account session. `/api/auth/logout` revokes it. A new email sign-in replaces the previous session for that email account.
- The login screen has **Continue with email**. Registration uses the same server verification flow instead of accepting an arbitrary six-digit value.
- Email OTP and Google sign-in retain separate account IDs; automatic linking of existing accounts is not performed.

## Limits and verification

Codes expire after five minutes, allow three incorrect guesses, are consumed atomically once, and have a 60-second resend cooldown. Send and verification routes also have IP limits. Resending invalidates the previous code. MongoDB TTL cleanup removes expired documents, while server checks enforce expiry immediately. Missing SMTP or failed delivery never claims to have sent a code.

Backend tests cover concurrent requests, expiry, resend, lockout, replay, delivery failure, missing configuration, and verified sign-in/logout using isolated collection and mail doubles. Flutter tests cover request formatting, failed delivery, rejected codes, cooldown UI, and secure session storage. Tests do not send real emails or alter production accounts.
