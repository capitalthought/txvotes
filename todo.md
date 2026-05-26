# US Votes TODO List

> **Active work only.** Open `[ ]` + parked `[~]` items live here.
> Completed `[x]` work is archived in `todo-archive.md` (sibling file).
> Grouped by domain. Items are checkboxes with bold titles and prose explanations.

## Open

### Data & Content

#### County Ballot Gaps
_From data audit (Feb 23). All 254 counties now have ballot keys. Some have empty/failed data._

- [ ] **LOW PRIORITY** Re-seed empty county ballots — Code fixes deployed via PR #7 (reject empty results, better prompts) and PR #8 (robust JSON extraction). Seeded results:
  - Randall (48381): 1 Republican race (seeded in previous session)
  - Smith (48423): 5 Republican + 2 Democrat races (seeded in previous session)
  - Archer (48009): 3 Republican races found. No Democrat primary (expected — small rural red county).
  - Austin County (48015): Still 0 races — may genuinely lack contested county-level primaries (population ~30K, very rural). Consider marking as "no contested county races."
  - ~~**Verify:** Check `/admin/coverage` — Randall, Smith, Archer should show race counts > 0~~ **Verified 2/27** — all three show Y for County Info, GOP Ballot, and Dem Ballot on `/admin/coverage`.

#### Precinct Maps
- [ ] Seed precinct maps for top counties — Code improvements deployed (PR #7: first-digit convention, GIS hints, validation). Re-seeding attempted for 28 counties but all return "Could not determine precinct map" — ZIP-to-commissioner-precinct data isn't available via web search. **Fundamental data sourcing problem, not a code problem.** Options: (1) hardcode static maps using official county GIS PDFs, (2) accept limitation and deprioritize.
  - 10/30 top counties have maps from initial seed; remaining 20 need manual GIS research

### Features
- [ ] Design a candidate/community data submission system — allow candidates and others to submit data for races with limited info. Must be trusted, not spammable or gameable (needs verification/moderation design)
- [ ] Make city/region support self-service — configuration-driven approach so any city/region can set up their own voting guide without code changes
- [ ] Create versions for runoffs and general election — support multiple election cycles beyond the primary (detailed plan at docs/plans/plan_runoff_general_election.md, 4-phase timeline March-October)
- [ ] **Plan Colorado expansion** — Enter planning mode and figure out how to expand the platform to Colorado. Research CO election structure, counties, ballot format, data sources, and what needs to change in the codebase (multi-state routing, KV key namespacing, branding, etc.). Write the plan to `docs/plans/plan_colorado_expansion.md`.
- [ ] **create a new repo called vote and make a new version of the site branded as vote.help instead of txvotes.app** (added 2026-05-26 via /todo) — Spin up a national-umbrella version of the platform under a new `capitalthought/vote` repo, branded `vote.help`. **Strategy decided (Josh 2026-05-26): `vote` is the new home and SUPERSEDES txvotes — txvotes will be archived after cutover, not run in parallel.** Overlaps the in-flight multi-state generalization (open PRs #17–20, `USV-*`) and the `usvotes.app` umbrella already reserved for this. Sub-steps: (1) `/repo-setup` a new `capitalthought/vote` repo seeded from this codebase (move history, not a throwaway fork — it's the successor); (2) confirm/register the `vote.help` domain — **purchase, needs Josh approval**; (3) rebrand assets/copy/OG images/logo from "Texas Votes" to the national "Vote" brand; (4) DNS + worker route for `vote.help`, keep txvotes.app routes alive during transition; (5) cut over (redirect txvotes.app → vote.help), then **archive the `txvotes` repo** (GitHub archive + note in README pointing to `vote`). Sequence the archive LAST, only once `vote.help` is verified serving prod.

- [ ] **P1 (vote rebuild): harvest multi-state work from txvotes PRs #17–20 instead of re-deriving** (added 2026-05-26 via /todo) — The Feb/Mar multi-state PRs were kept open as reference (not merged — txvotes is being archived). When building multi-state in the `vote` repo (vote.help plan P1), carry forward: **CO county/FIPS data** from #18 (`worker/src/counties/co.js`), **CO deep-dive questions** from #19, **dynamic `STATE_CONFIG` routing** from #20, and the per-state **`kvPrefix`** approach from #17. **Reconcile `kvPrefix` (#17) with `ELECTION_SUFFIX` (current main)** — they're two parallel refactors of the same KV-keying; the new `ballot:general:{state}:{geo}:2026` schema should subsume both. Also re-apply the `old.txvotes.app`-style host phase override pattern in whatever phase resolver the new repo uses.

### Factual Accuracy
_Latest audit (Feb 23): ChatGPT 7.5, Gemini 7.5, Claude 8.2, Grok 7.8 (avg 7.8/10). Accuracy is the lowest dimension at 7.0/10 — all four auditors scored 7._

- [ ] Add cross-referencing against Ballotpedia/Vote Smart — verify AI-generated candidate positions, endorsements, and backgrounds against established independent databases before publishing. *Flagged by: Claude. Improves: Accuracy.*
- [ ] Create fallback to verified static datasets — when AI web search fails, returns contradictory results, or contradicts official filings, automatically fall back to pre-verified data from official sources (SOS filings, county clerk records). *Flagged by: Grok, synthesis. Improves: Accuracy.*

### Daily Updater & Freshness
- [ ] Add county ballots and voting info to daily updater refresh — currently only statewide races are auto-updated; county ballots, county_info, and precinct maps are seeded once and never refreshed
- [ ] Design a post-Election Day site and have it ready to automatically switch when the polls close — currently the site shows stale "March 3, 2026" messaging with no post-election UX, no runoff messaging, no results. After election ends, app still shows "Vote Now" CTAs and generates guides for concluded races.

### Security (post-election)
_External black-box assessment of txvotes.app public surface (Brad Feld, Feb 24). No source code access, no active exploitation. Ranked by severity._

- [ ] **[S3] Harden daily updater against data poisoning (MEDIUM-HIGH)** — The updater uses Claude web_search to refresh candidate data. The audit export documents exact source hierarchy and validation thresholds. An attacker could create SEO-optimized fake pages to inject false endorsements, polling, or positions that persist in KV. Fix: cross-reference AI search results against a known-good source allowlist.
- [ ] **[S4] Prevent KV key enumeration (MEDIUM)** — The audit export reveals KV key patterns (`ballot:statewide:{party}_primary_2026`, `county_info:{fips}`). If any endpoint accepts KV keys as parameters, an attacker could enumerate all stored data. Fix: audit all endpoints that read KV keys for user-supplied input, restrict to known patterns.
- [ ] **[S5] Validate and sanitize event tracking endpoint (MEDIUM)** — `/app/api/ev` accepts arbitrary POST data with no auth or input validation. If event data renders in admin dashboards without sanitization, this is a stored XSS vector. Also allows analytics poisoning. Fix: validate event schema, sanitize before rendering.
- [ ] **[S6] Audit Census geocoder proxy for SSRF/logging (MEDIUM)** — The Worker proxies addresses to the Census Bureau Geocoder. If the address parameter isn't validated server-side, minor SSRF risk exists. If any logging misconfiguration exists, addresses could be retained unintentionally. Fix: validate address input, verify no logging of PII.
- [ ] **[S8] Mitigate client-side data tampering on shared computers (LOW)** — All user data in localStorage. On shared computers (libraries, kiosks), an attacker could pre-load manipulated ballot data so the next user sees biased recommendations. Fix: integrity check on stored data, or session-based storage.
- [ ] **[S9] Add security headers (CSP, X-Frame-Options) (LOW)** — Missing or unverified Content-Security-Policy, X-Frame-Options, and other security headers. The app could be embedded in an iframe on a phishing site (clickjacking) or be vulnerable to inline script injection. Fix: add proper security headers in the Worker response.

### API Usage Optimization (post-election)
_From Claude API usage review (Feb 22). Recurring cost ~$26/month (updater $20 + audit $5.70). Per-guide cost $0.02-$0.07._

- [ ] Architecture review for general elections — more races, more candidates, higher traffic. May need response caching (cache guide responses by profile hash for 1 hour).

### Ballot Generation Speed
_From speed optimization research (Feb 23). Current guide generation takes 10-30+ seconds._

#### Prompt Size Reduction
- [ ] **Truncate endorsement lists to top 3 per candidate** — Some candidates have 8+ endorsements in the ballot data, all serialized into the prompt. Cap at 3 most notable endorsements. _Estimated: 0.5-1s from token reduction on endorsement-heavy ballots._

#### Architecture Changes (Higher Effort)
- [ ] **Pre-generate guide skeletons at ballot update time** — When the daily updater refreshes ballot data, pre-generate ballot descriptions and cache them. At guide time, the LLM call only needs the voter profile + pre-built ballot text, skipping all ballot-building logic. _Estimated: 50-100ms savings on worker CPU, main benefit is code simplicity._
- [ ] **Split guide generation into parallel per-category LLM calls** — Instead of one big prompt with all races, split into 3-4 parallel calls: federal races, state executive, judicial, local. Each call has a smaller prompt and returns faster. Merge results on the worker. Risk: more API calls = more rate limit exposure, and profileSummary must be generated separately. _Estimated: wall-clock could drop 30-50% (from max-of-parallel vs sum-of-sequential), but adds complexity and error handling._

### DC Expansion
_Phase 1 (multi-state infrastructure) complete. Plan at `docs/plans/plan_dc_primaries.md`. Target: mid-May 2026 (4 weeks before June 16 DC primary)._

#### Phase 2: DC Address Resolution
- [ ] **Register for MAR 2 API key** — Go to `https://developers.data.dc.gov/Identity/Account/Register`, create account, copy API key, then run `cd worker && npx wrangler secret put DC_MAR_API_KEY -c wrangler.txvotes.toml`. Key is free. Needed as backup when legacy MAR eventually shuts down.

#### Phase 3: DC Ballot Data Pipeline
- [ ] **Seed DC citywide ballot data** — Create `dc:ballot:citywide:{party}_primary_2026` KV entries for Mayor, AG, Council Chair, Council At-Large, US House Delegate, Shadow Senator, Shadow Representative.
- [ ] **Seed DC ward-specific ballot data** — Create `dc:ballot:ward:{ward}:{party}_primary_2026` KV entries for Council Ward seats and State Board of Education (wards 1, 3, 5, 7 in 2026).

#### Phase 4: Interview Flow & PWA
- [ ] **Add state selector to interview flow** — First-visit screen to choose Texas or DC before starting the interview. Persist selection in localStorage. _Note: state selector + DC branding agent completed this work but worktree was lost. DC PWA routes partially recovered (index.js). PWA state-aware variables and 51 state-selector tests need to be re-implemented._
- [ ] **Add DC-specific interview issues** — DC Statehood, Metro/WMATA, Government Accountability, Home Rule, Housing (DC-specific), Public Safety, Education (DCPS).
- [ ] **Support 4-party selection for DC** — Democrat, Republican, Statehood Green, Libertarian + Independent option. DC is ~76% Democrat, ~16% Independent.
- [ ] **Default address form to DC/Washington when state=dc** — Pre-fill state and city fields for DC users. _Note: partial work recovered from stash — DC PWA routes added to index.js, but pwa.js state-aware variables need re-implementation._

#### Phase 5: Guide Generation for DC
- [ ] **Design RCV recommendation schema** — DC uses ranked-choice voting (Initiative 83). Guide responses need ranked recommendations (rank up to 5) instead of single picks. New JSON schema for RCV races.
- [ ] **Decide on RCV ranking depth** — Full 5 rankings or top 2-3? Deeper rankings need more research per candidate but provide more value.
- [ ] **Build RCV-aware prompt templates** — Modify guide generation prompts to explain RCV strategy (e.g., "rank your top 3 in order of preference").
- [ ] **Add RCV UI to ballot and cheat sheet** — Show ranked picks (#1, #2, #3) instead of single recommendation. Cheat sheet needs RCV-friendly layout.

#### Phase 6: Routing, Branding & Polish
- [ ] **Replace DC "Coming Soon" page with live PWA** — DC PWA routes added to index.js (partial recovery from stash). Still needs ballot data, guide generation, and pwa.js state-aware variables before it's fully functional.
- [ ] **Create DC-specific OG images and branding** — DC flag colors, DC-specific social sharing images, meta tags.
- [ ] **Add DC to landing page** — State selector or automatic detection on the main txvotes.app landing page.
- [ ] **Update README and CLAUDE.md for multi-state architecture** — Document new state-config.js, /tx/ and /dc/ routing, KV namespacing.

#### Phase 7: Testing & Launch
- [ ] **Full QA pass on DC flow** — End-to-end testing of DC interview, address resolution, guide generation, ballot display, cheat sheet, RCV UI.
- [ ] **Soft launch DC** — Enable /dc/app with real data, invite DC voters for feedback before public announcement.
- [ ] **Migrate TX KV keys to `tx:` prefix** — Currently TX keys are unprefixed for backward compat. Plan and execute migration to `tx:` prefix for consistency.

### Infrastructure
- [ ] Replace atxvotes-api worker with Cloudflare redirect rule — atxvotes.app only does 301 redirects to txvotes.app now (cron moved to usvotes-api). Replace the worker with a Cloudflare Bulk Redirect rule to eliminate the redundant worker entirely.
- [ ] Rename txvotes-api worker to usvotes-api in Cloudflare dashboard — config already uses `usvotes-api` but deploying requires the old name since `txvotes-api` owns the routes. Unassign routes from `txvotes-api` in the dashboard, then deploy with `usvotes-api` name. Temporarily reverted in wrangler.txvotes.toml to keep deploys working.
- [ ] **Set up tx.usvotes.app and dc.usvotes.app subdomains** — Configure Cloudflare DNS for usvotes.app with `tx` and `dc` subdomains pointing to the usvotes-api worker. Add route patterns in wrangler.txvotes.toml for `tx.usvotes.app/*` and `dc.usvotes.app/*`. Should work identically to txvotes.app and dcvotes.app respectively.
- [ ] **set up a copy of the site functioning as it was before the election on old.txvotes.app so that i can demo it to some other people** (added 2026-05-26 via /todo) — Stand up a pre-election demo at `old.txvotes.app`. The phase machinery already exists: the site computes phase from the date, but a per-state `site_phase:tx` KV override and a `?test_phase=pre-election` query param both force it. Likely approach: add a CF DNS record + worker route for `old.txvotes.app/*`, then either (a) pin that hostname to `pre-election` phase in the worker (host-based override, so the demo needs no query string), or (b) point it at a separate worker/KV with `site_phase:tx = pre-election`. Guide generation still hits the live Claude API, so confirm `ANTHROPIC_API_KEY` is set on whatever worker serves it.

### Credentials & Security
- [ ] Verify `CF_BEACON_TOKEN` in `wrangler.toml` is acceptable to have in plaintext — it's a low-risk analytics beacon token, but confirm it's not sensitive. All real secrets go through `wrangler secret put`.
- [ ] **Terminate the Resend account** (added 2026-05-26 via /todo) — Stats email was migrated off Resend to Postmark (the standing transactional-email vendor). Once Postmark is verified sending in prod, cancel/delete the Resend account and remove any `RESEND_API_KEY` secret still set on the worker (`npx wrangler secret list -c wrangler.txvotes.toml`).

### Deploy Process
- [ ] Agree on deploy rules — who can deploy, deploy from main only, manual vs CI-triggered deploys. Currently anyone with `npx wrangler deploy` access can push to production. Consider adding a deploy step to GitHub Actions that triggers on merge to main.
