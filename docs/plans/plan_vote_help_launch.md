# vote.help — November 2026 General Election Launch Plan

**Author:** Joshua Baer, Founder & CEO of Capital Factory (operated by Capital Thought, LLC)
**Created:** 2026-05-26
**Target launch (public GA):** 2026-09-08 · **Election Day:** 2026-11-03
**Runway from today:** ~23 weeks / 161 days

---

## 1. The thesis

`vote.help` is the national successor to txvotes.app: a free, nonpartisan, AI-powered
personalized voting guide. A voter enters their address and a few preferences; the app
returns a plain-language, balanced explanation of everything on *their* ballot. We already
have a battle-tested Texas product (2,200+ tests, streaming guide generation, response
caching, an automated bias-audit system, Spanish i18n, a post-election phase machine).
November 2026 is the moment to take it national.

**Trust is the product, and it's now AI + human.** An election tool that's wrong, or
perceived as partisan, is worse than useless. Our trust stack is three layers:
1. **AI generation** sourced from a ranked source hierarchy with web search.
2. **Automated audit** — 4-LLM bias scoring + a bias-test suite + accuracy cross-referencing.
3. **Human review — the League of Women Voters** has offered to help with fact-checking and
   bias review. This is the keystone: a century-old nonpartisan institution putting human
   eyes on the content. It directly answers our two biggest risks (accuracy at scale,
   partisanship perception) and is a credibility halo no competitor can easily match.

**Two customers, per Agent First** ([agentsfirst.dev](https://agentsfirst.dev) — the framework
Joshua Baer authored)**:** the human voter who needs their ballot explained, and the AI agent
(ChatGPT/Claude/Perplexity) asked "what's on my ballot?" that needs a trustworthy tool to call.
We ship a human PWA *and* an agent interface (MCP / typed API) so when someone asks an assistant
about their ballot, the answer is *powered by vote.help*. Building vote.help to the published
agentsfirst.dev playbook also makes it a flagship **reference implementation** of the framework —
the civic-tech proof point for "design for the agent customer first," and a story that ties the
launch back to Capital Factory's own thought leadership.

---

## 2. Decisions

- ✅ **Domain: `vote.help`** (decided 2026-05-26). Acquire/confirm + matching social handles in P0.
- ✅ **Human review partner: League of Women Voters** (offered 2026-05-26) — integrate as the
  human layer of the trust stack (see §4).
- ✅ **Launch scope: Tier-1 = Texas, Colorado, Washington DC** (decided 2026-05-26). Deep +
  LWV-reviewed in these three; Tier-2 national federal/statewide and Tier-3 best-effort local
  layer on top (§5). National × every down-ballot race in 23 weeks isn't realistic at our
  accuracy bar *or* LWV's throughput, so the three deep states anchor the launch.
- ✅ **`vote` repo created** (2026-05-26) — `capitalthought/vote`, seeded from txvotes with full
  history (the successor). `vote.help` confirmed as a live Cloudflare zone.
- 🟥 **LWV editorial authority: advisory vs. blocking** — **P0 week-1 blocker.** This is an
  architectural decision, not an MOU footnote: *blocking* authority requires a hold/approve
  state machine in the publishing pipeline (changes the data model + reviewer-console design);
  *advisory* is a simpler integration. Decide before the P1 console is built. (See §4.)
- ⬜ **Agent/MCP API in launch scope** — open. Agent First says interface-first; the plan
  review flagged "no proven agent demand under a hard deadline." **Recommendation:** keep a
  *minimal read-only* MCP (`get_ballot`, `get_guide`) in P1, defer richer agent tooling to
  post-launch. Josh's framework call.

> **Plan-review revisions (2026-05-26):** Items below incorporate two multipov plan reviews —
> growth + ruthless-simplifier (job `ebda6a11`) and the full technical panel (job `408c64b2`:
> staff/architecture, security, devops, test, auditor). The biggest structural change from the
> technical round is the new **P0.5 Safety & Scale Foundations** phase, which resequences
> security, observability, and load testing *before* real ballot data — the panel's strongest
> consensus.

---

## 3. Working backwards — the timeline

Election Day is fixed at **Nov 3, 2026**; everything else derives backwards from it. Key fixed
external dates (Texas; other states get their own config):

| Date | Event |
|---|---|
| 2026-10-05 (~) | TX voter-registration deadline (30 days out) — **registration push** |
| 2026-10-19 (~) | TX early voting begins — **traffic surge begins** |
| 2026-10-30 (~) | TX early voting ends |
| **2026-11-03** | **Election Day** — peak load, GOTV, "I voted" |

### Phase ladder (each phase: Tech track + Marketing track)

| Phase | Window | Weeks out | Theme |
|---|---|---|---|
| **P0 Foundation** | May 26 – Jun 15 | T-23 → T-20 | Decisions, domain, repo, scope, cost model, LWV MOU |
| **P0.5 Safety & Scale** | Jun 15 – Jul 28 | T-20 → T-14 | Security S3–S9, cache-stampede, allowlist, observability, load test — **gates P2** (runs alongside P1) |
| **P1 Platform & Brand** | Jun 15 – Jul 14 | T-20 → T-16 | Multi-state engine, `vote` repo, rebrand, agent API, reviewer console |
| **P2 Data & AI for General** | Jul 14 – Aug 11 | T-16 → T-12 | General ballots, accuracy safeguards, LWV review loop, scale |
| **P3 Beta & Hardening** | Aug 11 – Sep 8 | T-12 → T-8 | Soft launch, load test, security, monitoring |
| **P4 Public Launch** | Sep 8 – Oct 5 | T-8 → T-4 | GA, press w/ LWV, SEO live, registration push |
| **P5 GOTV Blitz** | Oct 5 – Nov 3 | T-4 → 0 | Early-vote + election-day surge, daily marketing, LWV chapter distribution |
| **P6 Election Day + Wind-down** | Nov 3+ | 0 → post | Peak ops, post-election transition, retro |

---

### P0 — Foundation & Decisions (May 26 – Jun 15)

**Tech**
- Confirm/acquire `vote.help`; grab matching social handles.
- `/repo-setup` the `capitalthought/vote` repo, seeded from txvotes with history (successor;
  txvotes archived after cutover — decision already locked in todo.md).
- Design the **general-election data model**: general ballot ≠ primary — one ballot per address
  with R/D/third-party/independent head-to-head per office, plus judicial, props, bonds, local.
  New KV schema (`ballot:general:{state}:{geo}:2026`), versioned.
- **Cost & scale model:** project November traffic + per-guide cost across scope tiers. Pick
  default model (Claude Sonnet vs Gemini Flash for scale — both wired). Raise Anthropic spend
  caps deliberately *before* they bite (we already hit one on the TX key).
- Multi-state architecture sign-off (build on in-flight PRs #17–20).

**Marketing / Partnerships**
- **Formalize the LWV relationship** — scope of review (which races, what turnaround, national
  vs chapter-level), a lightweight MOU, named points of contact, co-branding terms. This is the
  single highest-value relationship in the plan; nail it down early.
- Lock brand: name, logo, palette, voice (nationalize the "Star & Stripes" civic identity).
- Positioning: *free, nonpartisan, AI ballot guide — reviewed with the League of Women Voters.*
- Competitive map (Vote.org, Ballotpedia, BallotReady, iSideWith, VOTE411); find the wedge
  (personalized + plain-language + human-reviewed + agent-accessible + radically transparent).
- Build the broader partnership list (§6); open warm intros now — civic orgs move slowly.
- "Coming soon" page with email capture.

**Exit criteria:** domain owned, `vote` repo live, scope chosen, data + cost model approved,
brand locked, **LWV scope agreed — including the advisory-vs-blocking editorial-authority
decision (gates the P1 pipeline + console design; do not defer).**

---

### P0.5 — Safety & Scale Foundations (Jun 15 – Jul 28, runs alongside P1, **gates P2**)

> **Plan-review finding (Security + DevOps + Auditor converged):** the original plan sequenced
> security, observability, and load testing into P3 — *after* the reviewer console and real
> ballot data go live. That's backwards for an election system; you'd discover failures during
> the Oct 19–Nov 3 surge. These foundations move earlier and gate the P2 data seeding.

- **Close the S3–S9 security backlog here, not P3** — each with a fail-closed branch *and* a
  load test that attempts the documented attack: data-poisoning, KV-enumeration, event-endpoint
  validation, Census geocoder SSRF + PII-logging, security headers (CSP/X-Frame).
- **Cache-stampede protection (blocker):** add request coalescing + stale-while-revalidate to
  the guide + ballot-description caches, and a circuit-breaker around the Census/GIS geocode
  lookup. A cold hot-district key at 8am on Election Day must fire **one** upstream call, not
  10k. Test: 100+ simultaneous misses on one key → exactly one LLM call.
- **Source allowlist (blocker):** dedicated `allowlist:` KV namespace, **signed + versioned**
  updates distributed to the updater worker; web_search ingestion **fails closed** when a
  source isn't on the list. Designed in P0, enforced here — not discovered during P3.
- **Rate limiting at national scale:** per-IP KV limits get bypassed behind CDNs/anycast (the
  TX impl assumes direct client-IP visibility that won't exist nationally). Add device/auth
  fingerprint limits + a much lower limit tier on any updater- or audit-touching endpoint.
- **Daily-updater cron hardening:** stagger KV writes by state tier; add backpressure + a
  circuit-breaker that pauses the cron when KV write latency/error rate exceeds threshold
  (document the trigger, e.g. >200k daily ballots) — before it exhausts Worker CPU at peak.
- **Observability contract:** structured logs with correlation IDs + required fields
  (timestamp, service, operation, outcome, actor/context, error stack) on every guide gen / KV
  write / cron run; centralized aggregation; define the Oct 19–Nov 3 incident metrics, alerts,
  and **who watches them**.
- **Constrained load test (moved up from P3):** simulate 10–50× TX traffic at 30% cache-miss on
  new `ballot:general:*` keys **before** seeding general data in P2; acceptance criteria include
  verifying the advisory/blocking review queue does not grow unbounded under that load.

**Exit criteria (gates P2):** S3–S9 closed; cache-stampede coalescing + concurrency test green;
allowlist enforced fail-closed; rate-limit + cron hardening shipped; observability contract live;
constrained scale test passing.

---

### P1 — Platform & Brand (Jun 15 – Jul 14)

**Tech**
- Land multi-state generalization (merge/rebase PRs #17–20): `STATE_CONFIG` routing, KV
  namespacing, national geocoding/district resolution (Census + state GIS).
- **Geocoding validation strategy (plan-review finding):** district misalignment = wrong
  ballots. Document cross-verification (Census vs. state GIS), per-state fixtures, and edge-case
  tests for district assignment before relying on it nationally.
- Migrate to `vote` repo; rebrand all copy/OG/logo/manifest "Texas Votes" → "Vote."
- General-election ballot pipeline end-to-end for a reference state (TX).
- **Reviewer console for LWV** — extend the existing `/admin/spot-check` dashboard (already
  confidence-sorted with approve/flag/export) into an LWV-facing review queue: lowest-confidence
  and flagged items first, accept/edit/flag, change tracking, per-reviewer attribution. This is
  what operationalizes the human layer.
- **Agent First interface v1 (descoped):** ship a *minimal read-only* `vote` MCP / typed API —
  `get_ballot(address)`, `get_guide(profile)` — following the [agentsfirst.dev](https://agentsfirst.dev)
  principles (Interface First, Contract First via `AGENTS.md`, Inspectable State via a `status`
  tool, structured/typed errors). Richer agent tooling (`explain_race`, writes) deferred to
  post-launch pending the §2 decision.
- **Analytics instrumentation (was missing — plan-review finding):** define the event taxonomy
  (`address_entered → guide_generated → guide_completed → section_expanded → share_clicked →
  return_visit`) and pick the stack (PostHog / Amplitude / custom on Analytics Engine). Wire
  events as the funnel is built — not bolted on at the end. This is *behavioral* analytics,
  distinct from P3 reliability monitoring.
- **Activation / first-value design (plan-review finding):** design the empty-state and the
  address-entry → first-guide moment explicitly. A voter in a Tier 2/3 (AI-only) state must
  see *what they'll get* **before** entering an address, and coverage/confidence labels must
  read as a trust signal, not a disclaimer. This is the highest-leverage conversion surface.

**Marketing**
- Brand site live (real identity + waitlist; guide still "coming soon").
- **SEO foundation** (biggest organic channel, slowest to mature): programmatic pages for
  "[state] voting guide 2026," "what's on my ballot [state]," candidate pages. Start now.
- Content calendar; begin evergreen civic-education content.
- Convert LWV + first partners from intro → LOI.

**Exit criteria:** national engine works for TX general end-to-end; agent API live; LWV reviewer console usable; brand site up; SEO scaffolding indexed.

---

### P2 — Data & AI for the General (Jul 14 – Aug 11)

**Tech**
- **Gated by P0.5 safety sign-off** — do not route real ballot data into the system until the
  security backlog, cache-stampede protection, allowlist, and constrained load test are green.
- **Seed general-election ballots for launch-tier states.** General ballot is effectively set
  post-primary/runoff (TX runoff ~now), so candidates are known — seed in earnest.
- Scale the candidate-research pipeline (Claude + web_search) across states/districts.
- **Accuracy safeguards (election-grade):** cross-reference AI output vs Ballotpedia /
  VoteSmart / state SOS filings; fall back to verified static datasets on conflict (both on the
  txvotes todo — promote to launch-blockers).
- **LWV human-review loop, in production:** AI generates → automated audit/bias scoring →
  low-confidence + flagged items route to LWV reviewers via the console → corrections →
  publish. The confidence sort means human time goes where it matters most. Throughput here
  is a real constraint and directly informs scope (deep human review on Tier 1; AI+audit on
  Tier 2/3 with clear labeling).
- Re-run bias/audit suite for general-election framing (head-to-head, third parties).
- Scale-test guide generation + caching at projected concurrency.

**Marketing**
- Lock partnerships (signed); build co-marketing assets, including LWV co-branding.
- Press kit + founder narrative (Joshua Baer / Capital Factory civic-tech story) — LWV partnership is the headline.
- Recruit nonpartisan civic **creators/influencers** (GOTV lives on TikTok/IG/X).
- List-building (email/SMS) with explicit election-reminder opt-in.
- Wire a "register / check registration" CTA (partner deep-link).

**Exit criteria:** launch-tier ballot data complete + accuracy-checked + **LWV review loop running**; audit green; partnerships signed; press kit ready.

---

### P3 — Beta & Hardening (Aug 11 – Sep 8)

**Tech**
- **Soft launch** to closed beta (CF network, LWV chapters, partner orgs, friendly press).
- **Full-scale load test** confirming the P0.5 constrained test holds at real November scale;
  final tuning of caching, rate limits, fallback models, CDN.
- **Security + observability already landed in P0.5** — P3 is verification under beta traffic
  (re-run attack load tests, confirm alerts fire, exercise the incident runbook), not first build.
- Cost guardrails validated under load (auto-throttle, spend alarms); incident runbook dry-run.
- **Behavioral funnel dashboards** (per-state, per-tier) from the P1 event taxonomy — so the
  8-week live window is optimized on data, and so LWV throughput decisions are data-driven.

**Marketing**
- Beta feedback → testimonials (LWV reviewers + voters); refine messaging from real usage.
- Schedule launch PR with LWV; line up media embargo; finalize creator deals.
- Pre-write GOTV campaign assets (registration, early-vote, election-day sequences).

**Exit criteria:** survives load test; S-series cleared; monitoring live; launch comms scheduled.

---

### P4 — Public Launch (Sep 8 – Oct 5)

**Tech**
- **GA.** Full launch-tier coverage live. Real-time monitoring; public "flag this" → fast-fix
  loop (routes to LWV/internal review). Post-election phase machine armed for Nov 3.

**Marketing**
- **LAUNCH:** joint press with the League of Women Voters (the trust headline), founder op-ed,
  podcast/press tour, coordinated partner promotion.
- SEO content fully live; paid search where allowed (Google/Meta restrict election ads — plan
  verification lead time or lean organic + partnerships).
- **Voter-registration-deadline push** culminating ~Oct 5.
- Get vote.help into agent ecosystems so assistants can cite it.

**Exit criteria:** GA stable under real traffic; LWV-co-branded press landed; registration push executed.

---

### P5 — GOTV Blitz (Oct 5 – Nov 3)

**Tech**
- Scale ops through early-vote (Oct 19) and election-day surge; daily freshness; on-call.
- Watch API spend daily (scales with traffic); throttle/fallback as needed.

**Marketing**
- Early-voting push (Oct 19); daily social cadence; reminder email/SMS sequences.
- **LWV chapter distribution** — local chapters are a national, trusted, on-the-ground GOTV
  network; activate them.
- "Make your plan to vote" + creator activations; election-day GOTV.
- **"I Voted" viral loop** (built) — turn every user into a sharer.

**Exit criteria:** uptime through the surge; measurable GOTV lift.

---

### P6 — Election Day & Wind-down (Nov 3+)

- Peak load; post-election phase auto-transition (built) → results links.
- Thank-you to users/partners/LWV; impact retro (guides generated, reach, partner ROI, review stats).
- Decide 2027/2028 cadence; archive txvotes per the locked migration plan.

---

## 4. The human-review layer (League of Women Voters)

This is new and load-bearing, so it gets its own section.

- **What LWV does:** human fact-checking + bias review of AI-generated candidate data and guides.
- **How it plugs in:** AI generation → automated audit/bias scoring (existing) → **confidence-
  sorted review queue** → LWV reviewers accept/edit/flag → corrections persist → publish. Built
  on the existing `/admin/spot-check` tooling, extended into a multi-reviewer console with
  attribution and change tracking.
- **Why confidence-sorting matters:** human review doesn't scale to every race, so we spend it
  where AI confidence is lowest or where items are user-flagged. High-confidence, well-sourced
  content flows through; uncertain content waits for human sign-off.
- **Scope coupling:** LWV throughput is a gating input to §5 — deep human review on Tier 1
  states, AI+automated-audit (clearly labeled) on Tier 2/3.
- **Editorial authority decided FIRST (P0 blocker, §2):** advisory vs. blocking changes the
  architecture. *Blocking* → the pipeline needs an explicit hold/approve state (content can't
  publish until signed off) and the console is the gate. *Advisory* → content publishes with
  AI+automated audit and LWV edits flow as corrections. Pick before building the P1 console.
- **Review SLA + in-review fallback (plan-review finding):** define turnaround targets and,
  critically, **what the user sees while an item is pending review** — a graceful "reviewed
  content shown; this item is AI-generated and under review" state, not a blank or a hard block.
- **Immutable audit log (plan-review finding):** every publishing state-machine transition
  writes to an append-only log admins can't delete — schema `{action, actorId, targetBallotId,
  previousState, newState, timestamp, reason}` — for both advisory and blocking modes. The
  reviewer console's attribution/change-tracking is not a substitute for this.
- **Reviewer access controls (plan-review finding):** if LWV is in *blocking* mode, their
  approvals gate publishing — so harden it: strong session management, least-privilege
  per-reviewer roles, and audit logging of every approve/edit/flag action.
- **Marketing value:** "reviewed with the League of Women Voters" is the trust headline and a
  distribution channel (national org + local chapters). Co-branding terms set in P0.
- **Remaining MOU questions (P0):** national vs chapter-level reviewers; which tiers/races they
  cover; attribution/co-brand. (Editorial authority + SLA are resolved above, not here.)

---

## 5. Recommended launch scope (the realism call)

Three coverage tiers, shipped in priority order; launch with Tier 1+2, Tier 3 best-effort.

- **Tier 1 — Deep + human-reviewed: Texas, Colorado, Washington DC** (decided 2026-05-26).
  Texas is done-ish; CO/DC have prior work to harvest (CO data from PRs #18/#19, DC from the
  `plan_dc_primaries.md` + `dc-mar.js` address resolution already in the codebase). Full ballot
  (statewide, congressional, legislative, judicial, props, major local), with LWV human review.
- **Tier 2 — National federal + statewide:** every state's US Senate, US House, Governor, and
  statewide constitutional offices. AI + automated audit; LWV spot-checks the flagged tail.
- **Tier 3 — Best-effort local:** AI-seeded local races behind clear confidence labels.

**Why:** protects the accuracy bar (trust), matches LWV review capacity to where it counts,
gives a genuine national headline, and bounds the data effort. Be explicit in-product about
coverage depth + review status per state.

**Tier-3 carries real Election-Day risk (plan-review finding):** a wrong local result (e.g. a
judicial race) going viral on Nov 3 is a trust event. Either (a) define an Election-Day incident
path for Tier-3 — fast takedown/correction + a prominent "AI-generated, unverified" treatment —
or (b) **cut Tier 3 from launch** and ship Tier 1+2 only with honest coverage labels. Decide in
P0; don't carry unmonitored AI-only local data into a peak-traffic day without a plan.

---

## 6. Marketing channels (ranked)

1. **Nonpartisan partnerships — LWV first** — credibility + national/chapter distribution. The
   anchor of the whole go-to-market. Then Vote.org, When We All Vote, VOTE411, campus + library nets.
2. **SEO / organic** — highest-leverage, slowest to mature → start P1. Own "[state] voting guide 2026."
3. **Agent ecosystem** — be the ballot tool assistants call, built to the
   [agentsfirst.dev](https://agentsfirst.dev) framework. Novel, compounding, and doubles as a
   thought-leadership angle: a published-framework reference implementation, not just a product.
4. **PR / earned media** — LWV partnership + founder story + civic-tech angle; CF network.
5. **Creators / influencers** — nonpartisan civic creators on TikTok/IG/X for GOTV reach.
6. **Email / SMS** — opt-in election reminders (registration → early vote → election day).
7. **Viral loops** — "I Voted" share + shareable personalized guide (built).
8. **Paid** — constrained by political-ad policies; verification lead time. Optional.

---

## 7. Key risks & mitigations

| Risk | Mitigation |
|---|---|
| **Accuracy at national scale** | Tiered scope; cross-ref Ballotpedia/VoteSmart/SOS; **LWV human review on the uncertain tail**; confidence labels; fast public-correction loop |
| **Perceived partisanship** | Nonpartisan-by-design; published bias audits; symmetric prompts; transparency pages; **LWV human bias review** |
| **LWV review throughput < demand** | Confidence-sort the queue; scope human review to Tier 1 + flagged items; clearly label AI-only content |
| **API cost blowout** | Cost model in P0; aggressive caching; Gemini Flash fallback; spend alarms + auto-throttle; raise caps deliberately |
| **Traffic spikes** (early vote + election day) | Load test in P3; CF edge caching; rate limits; cached guides |
| **Adversarial attacks** (poisoning, misinfo, scraping) | Clear S3–S9 before launch; source allowlists; monitoring |
| **Political-ad restrictions** | Lean organic + partnerships; start ad-platform verification early if used |
| **Data deadline slip** in a state | General ballots set post-primary/runoff (now); per-state config isolates slippage |
| **Tier-3 wrong local result goes viral on Election Day** | Election-Day incident path (fast correction + "unverified" treatment), or cut Tier 3 (§5) |
| **Flying blind in the live window** (no behavioral data) | Event taxonomy wired in P1; per-state/tier funnel dashboards in P3 |
| **Activation drop from un-designed empty-state** | Design first-value moment + pre-address coverage messaging in P1; labels as trust signals |

---

## 8. Success metrics

- **Reach:** unique voters served; guides generated; states with live coverage.
- **Quality:** AI bias-audit score (hold ≥ ~7.8/10, target 8.5+); **LWV review pass/edit rate**;
  accuracy spot-check pass rate; correction turnaround.
- **Engagement:** guide-completion rate; "I Voted" shares; returning visitors through GOTV.
- **Re-engagement (plan-review finding):** day-2 / day-7 return rate; abandoned-guide recovery
  rate; reminder open rate — instrumented from the P1 event taxonomy, not just counted at the end.
- **Distribution:** partner referrals (LWV chapters); agent-sourced sessions; organic rank.
- **Reliability:** uptime through the surge; p95 guide latency; cost per guide.

---

## 9. What we already have (don't rebuild)

Streaming guide generation · response + ballot caching · automated 4-LLM bias audit ·
bias-test suite · **`/admin/spot-check` human-review dashboard (the LWV console's foundation)** ·
Spanish i18n · post-election phase machine · rate limiting · daily updater · data-quality +
transparency pages · 2,200+ tests · multi-state scaffolding in flight (PRs #17–20) · the
host-based phase override (reusable per-state).

The lift is **national data + general-election model + brand/repo migration + agent interface +
LWV review workflow + marketing**, not a rewrite.

---

## 10. Immediate next actions (this week)

1. **Josh:** confirm/acquire `vote.help`.
2. **Josh + LWV:** scope the review partnership (races, turnaround, national vs chapter, co-brand) → light MOU.
3. **Josh:** approve launch scope (Tier 1 states list).
4. Land PR #22 (CI/modernize) and PR #23 (old.txvotes demo); rebase/merge multi-state PRs #17–20.
5. `/repo-setup vote`; begin general-election data-model design doc.
6. Build the November cost & traffic model; raise Anthropic spend caps deliberately.
