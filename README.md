# VFB-CATMAID
Catmid server loaded with published data

Note: Restores from /backup volume taking a single *.bz2 backup file.

## Analytics tracking

This image emits hits to the VFB Google Analytics 4 property
(`G-K7DDZVVXM7`) by default, matching the tracker on
virtualflybrain.org. The gtag.js loader is inserted into CATMAID's
Django templates at container start by `/opt/VFB/inject_gtm.py`.

Override or disable via `GA_TAG_ID`:

- `GA_TAG_ID=G-K7DDZVVXM7` (default) — feed the VFB property.
- `GA_TAG_ID=G-XXXXXXXXXX` — feed a different GA4 property (e.g. a
  staging stream).
- `GA_TAG_ID=""` — emit no snippet at all.

Injection is idempotent: a `VFB-GA-INJECTED` marker prevents
double-insertion across restarts. Non-`G-…` values are refused as a
defensive XSS guard.

Consent gating is **not** applied here. The live VFB site itself
currently fires gtag with `anonymize_ip: false` and no CMP, so this
image inherits the same posture. Compliance is the wider Klaro rollout's
job, not this image.
