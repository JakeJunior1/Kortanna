---
name: council
description: >-
  When facing a CONSEQUENTIAL decision, plan, or judgment call and you want it
  pressure-tested instead of rubber-stamped — e.g. "should we go with X or Y?",
  "poke holes in this architecture/strategy before I commit", "am I just being
  told what I want to hear?" — convene an LLM council: N opposed-incentive
  personas argue it independently, rank each other ANONYMOUSLY, and a chairman
  synthesizes one verdict. An anti-sycophancy check, run over the native Workflow
  tool (no app, no external API). Do NOT use for code/work review (spawn an
  adversarial reviewer subagent instead) or for factual lookups.
---

# council

A single model tends to AGREE with you (sycophancy), so a lone "what do you think?"
mostly reflects your own view back. The council breaks that: several personas with
**opposed incentives** answer independently, then judge each other **blind to who
wrote what**, then **Kortanna** (the chair) synthesizes. Two lineages converge here — Karpathy's
`llm-council` (multi-member, anonymized peer-rank, chairman synthesis) and the
5-advisor anti-sycophancy council. Realized on the **native Workflow tool**: the
council is just a fan-out → rank → synthesize script — not a web app, not metered API.

## When this applies
- A **consequential** choice — architecture, strategy, a risky plan, build-vs-buy, a
  "which approach" fork — that you want stress-tested **before** committing.
- You suspect **sycophancy**: the easy answer agrees with you and you want the
  strongest case *against*.
- **Skip it** for: code/work review (spawn an adversarial reviewer instead), factual
  lookups, or low-stakes choices where one good answer is enough. This is a judgment
  instrument, not a search tool.

## The council (default roster — 5 opposed incentives)
The *diversity of incentive* is what fights sycophancy, not the count. Edit per decision.
- **The Contrarian** — only why it fails: failure points, worst cases, what the plan ignores.
- **The First-Principles Thinker** — strip to fundamentals, challenge every assumption, rebuild.
- **The Expansionist** — overlooked upside, asymmetric wins, second-order opportunity.
- **The Outsider** — the naive cross-industry questions an insider is too close to ask.
- **The Executor** — ignore theory; what to do *this week* (the email/call/file to make) and what to defer.

## How it runs (3 stages, over the Workflow tool)
Invoking this skill authorizes a `Workflow` call. Adapt the script below (set the
decision, edit the roster):
1. **Opinions** — each persona answers the decision INDEPENDENTLY, in character (`parallel`).
2. **Rank (anonymized)** — each persona sees the others as *Response A/B/C…* with persona
   identity STRIPPED, and ranks them best→worst on accuracy + insight. Anonymization is
   the point: no model can defend "its own" answer or defer to a perceived authority.
3. **Kortanna (the chair)** — one synthesizer (Opus, high effort) reads all opinions + rankings and
   returns ONE verdict, <250 words: **DECISION · PRIMARY RATIONALE · KEY RISK · NEXT 7
   DAYS**, plus a one-line **STRONGEST DISSENT** (the best surviving objection) so the
   consensus never buries the minority case.

```js
export const meta = {
  name: 'council',
  description: 'LLM council: opposed-incentive personas debate a decision, rank anonymously, chairman synthesizes',
  phases: [{ title: 'Opinions' }, { title: 'Rank' }, { title: 'Kortanna' }],
}
const QUESTION = args?.question || '<<the decision / plan to pressure-test — be specific>>'

// Opposed-incentive personas. Diversity of INCENTIVE is the anti-sycophancy lever.
const MEMBERS = [
  { id: 'contrarian',       brief: 'THE CONTRARIAN — list only why this fails: failure points, worst cases, what the plan ignores.' },
  { id: 'first-principles', brief: 'THE FIRST-PRINCIPLES THINKER — strip to fundamentals, challenge every assumption, rebuild from scratch.' },
  { id: 'expansionist',     brief: 'THE EXPANSIONIST — overlooked upside, asymmetric wins, second-order opportunity.' },
  { id: 'outsider',         brief: 'THE OUTSIDER — the naive cross-industry questions an insider is too close to ask.' },
  { id: 'executor',         brief: 'THE EXECUTOR — ignore theory; what to do THIS WEEK (the specific email/call/file to make) and what to defer.' },
]
const OPINION = { type:'object', required:['position','key_points','main_risk'], properties:{
  position:{type:'string'}, key_points:{type:'array',items:{type:'string'}}, main_risk:{type:'string'} } }
const RANK = { type:'object', required:['order','why'], properties:{
  order:{type:'array',items:{type:'string'},description:'labels best→worst, e.g. ["C","A","B"]'}, why:{type:'string'} } }

phase('Opinions')
const opinions = await parallel(MEMBERS.map(m => () =>
  agent(`You are ${m.brief}\n\nDECISION:\n${QUESTION}\n\nGive your honest, in-character take.`,
        { label:`opine:${m.id}`, phase:'Opinions', schema:OPINION })))

// Anonymize: strip persona identity → Response A/B/C… (identity is hidden — that is what matters).
const panel = opinions.filter(Boolean).map((o,j) => `### Response ${String.fromCharCode(65+j)}\n${JSON.stringify(o)}`).join('\n\n')

phase('Rank')
const rankings = await parallel(MEMBERS.map(m => () =>
  agent(`Anonymized council responses below. Rank them best→worst on accuracy + insight. You cannot tell which is yours — judge purely on merit.\n\n${panel}`,
        { label:`rank:${m.id}`, phase:'Rank', schema:RANK })))

phase('Kortanna')
return await agent(
  `You are KORTANNA, the head of the council (the chair). Synthesize ONE recommendation from the council's opinions and their anonymized rankings. Under 250 words. Structure exactly:\nDECISION · PRIMARY RATIONALE · KEY RISK · NEXT 7 DAYS\nThen a final line — STRONGEST DISSENT: the single best objection, even though you ruled against it.\n\nOPINIONS:\n${panel}\n\nRANKINGS:\n${JSON.stringify(rankings.filter(Boolean))}`,
  { label:'kortanna', phase:'Kortanna', model:'opus', effort:'high' })
```

Pass the decision via the Workflow `args` (`{ question: "..." }`) or edit `QUESTION` in the script.

## Knobs
- **Roster** — swap personas to fit the decision (add a *Domain Skeptic*, a *User
  Advocate*, a *Security/Risk* seat…). 3–7 members is the useful band.
- **Per-member backend** — give a member a different tier for cheap diversity:
  `{ ..., model:'sonnet' }` or `{ ..., effort:'low' }`. Same-vendor tiers correlate, so
  this is a *weak* diversity axis — persona incentive is the strong one.
- **Cross-vendor member (optional, strongest decorrelation)** — for a genuinely
  independent voice, make one member shell out to the **Codex CLI**
  (`codex exec "<persona brief + decision>"`) and return its text. Subscription-covered
  via `codex login` (ChatGPT sign-in) — **needs a paid ChatGPT plan**; skip on free.
  See `manifest/clis.md`.
- **Lite mode** — for a smaller decision, skip the Workflow: spawn 2–3 persona subagents
  directly and synthesize yourself. Same shape, less ceremony.

## Notes
- **A council *advises* — the human decides.** The verdict is a pressure-tested
  recommendation, not authorization to act. In a planning session this is a **read-only**
  fan-out (analysis, never building).
- **Anonymized ranking is load-bearing** — reveal which persona wrote which answer and
  you reintroduce the bias the council exists to remove.
