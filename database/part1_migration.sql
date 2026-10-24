-- Apply only to the existing EcoSusRural database with its migration role.
-- Additive migration; no unrelated tables or databases are changed.
BEGIN;
CREATE TABLE IF NOT EXISTS account_location_preferences (
  account_id TEXT NOT NULL, purpose TEXT NOT NULL CHECK (purpose IN ('weather','farm','business','market')),
  preference JSONB NOT NULL, updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY(account_id, purpose)
);
CREATE TABLE IF NOT EXISTS account_reminders (
  account_id TEXT NOT NULL, reminder_id TEXT NOT NULL, metadata JSONB NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), PRIMARY KEY(account_id, reminder_id)
);
CREATE TABLE IF NOT EXISTS product_listing_drafts (
  account_id TEXT NOT NULL, draft_id TEXT NOT NULL, payload JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending_review', updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY(account_id, draft_id)
);
CREATE TABLE IF NOT EXISTS private_grievances (
  account_id TEXT NOT NULL, submission_id TEXT NOT NULL, payload JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'received_by_ecosusrural', created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY(account_id, submission_id)
);
REVOKE ALL ON private_grievances FROM PUBLIC;
CREATE TABLE IF NOT EXISTS official_price_snapshots (
  dataset TEXT NOT NULL CHECK(dataset IN ('mandi','msp')), content_hash TEXT NOT NULL,
  source_url TEXT NOT NULL CHECK(source_url LIKE 'https://%'), payload JSONB NOT NULL,
  fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(), PRIMARY KEY(dataset,content_hash)
);
CREATE TABLE IF NOT EXISTS scheme_directory (
  scheme_id TEXT PRIMARY KEY, name TEXT NOT NULL, provider TEXT NOT NULL,
  provider_category TEXT NOT NULL, description TEXT NOT NULL, eligibility TEXT NOT NULL,
  required_documents JSONB NOT NULL DEFAULT '[]', official_information_url TEXT,
  official_application_url TEXT, application_status TEXT NOT NULL DEFAULT 'unknown',
  opening_date DATE, closing_date DATE, last_verified_at TIMESTAMPTZ,
  geographic_availability JSONB NOT NULL DEFAULT '[]', applicant_categories JSONB NOT NULL DEFAULT '[]',
  link_checked_at TIMESTAMPTZ, link_status INTEGER,
  CHECK(official_information_url IS NULL OR official_information_url LIKE 'https://%'),
  CHECK(official_application_url IS NULL OR official_application_url LIKE 'https://%')
);
COMMIT;
