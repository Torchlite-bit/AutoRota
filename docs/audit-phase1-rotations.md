# Aegis_SBR — Phase 1 Rotation-Correctness Audit (v0.14.0 code vs docs/rotations.md)

> ⛔ **Report only.** Per CLAUDE.md Critical Rule #1 this audit changes NO rotation code.
> Each class below gets: (1) what the module actually does, (2) a discrepancy table, (3)
> match notes (things checked that agree — so they aren't re-litigated later). The user
> decides per class what (if anything) to change; approved changes then land as their own
> verified batches.
>
> **Confidence tags** (from `docs/rotations.md`): `[T]` Turtle-confirmed · `[V]` vanilla
> assumption · `[?]` needs in-game verification (dummy-test before shipping). A `[T]` tag on
> a research *section* does not make every number in it verified — numeric parameters that
> can be checked in-game cheaply (buff stack caps, durations) are individually flagged `[?]`
> when the code disagrees, because `/sbr debug` can settle them in seconds.
>
> Audit order = roadmap divergence order: Paladin → Hunter → Shaman → Mage → Druid →
> Warrior → Rogue → Priest → Warlock. Audited at code version **0.14.0**.

---

## 1. PALADIN (`classes/Class_Paladin.lua`)

### What the code does

**Damage/tank mode** (strict single-cast, per press): `0` pre-cast opener seal while out of
melee range (never judges out of range) → `1` shared-CD strike (see ladders below) → `2`
Holy Shield when its own CD is free (held through the GCD) → `2b` Consecration on CD when
the AoE toggle is on (skipped during mana recovery) → `3` seal upkeep + Judgement
(`HandleSeals`) → `4` Hammer of Wrath at target ≤20% → `5` Repentance on CD → `6` Exorcism
vs Undead/Demon (skipped during mana recovery).

Strike ladders (both-strikes-on): **autodps** — without *Vengeful Strikes*: Crusader Strike
until Zeal at **3 stacks** and topped (renew <12s), else Holy Strike; with the talent: Holy
Strike to open/keep *Holy Might* (renew <7s), CS to ramp/hold Zeal at **3**, Zeal wins
ties, Holy Strike is the filler. **tankblock** — CS whenever the *Zealous Defense* block
buff is missing, else Holy Strike (threat). Seal logic: debuff seal judged once per target
(GUID-tracked with a 1.5s detection-dropout memory), then the damage seal is judged on CD
with reseal; optional seal-twist holds the judge until <0.4s before the next white swing;
Seal of Wisdom / Seal of Light hysteresis overrides for mana/HP management.

**Heal mode**: Blessed-Strikes CS weave to reload Holy Shock (never while anyone is under
the emergency line) → targeted heal (`DoHeal`: worst-hurt reachable member; Holy Shock for
emergencies or out-of-range; else downranked Flash of Light vs Holy Light by
least-overheal, with cast-time and Mortal-Strike-debuff compensation) → with nobody hurt:
Holy Strike splash filler (own mana floor) → Seal of Wisdom self-upkeep + optional
Judgement of Wisdom stamp.

### Discrepancies

| # | Ability / order | What the code does | What research says | Source + confidence | Recommended action | RISK if changed |
|---|---|---|---|---|---|---|
| P1 | **Zeal ramp target** | Ramps Crusader Strike to **3 stacks** of Zeal (`ZEAL_STACKS = 3`), renews when <12s | "ramp **Crusader Strike to 5 stacks of Zeal**" | rotations.md Ret `[T]` section — but the stack cap itself is a checkable number → treat as **[?]** | **Verify in-game first**: `/sbr debug` shows live buff stacks. If Zeal really caps at 5, raise `ZEAL_STACKS` (1-line change, gated) | If Zeal actually caps at 3 and we "fix" to 5, the ramp never completes → CS forever, Holy Might starves. If it caps at 5 and we stay at 3, we leave stacks on the table. Cheap to verify, do not change on paper |
| P2 | **Judgement vs strike order** | Strike is priority 1, Judgement (inside seal handling) is priority 3 | Ret: "Judgement on CD" listed **before** strikes | rotations.md Ret `[T]` | Probably **no change**: the module header says strikes queue on the next swing (on-next-swing = no GCD contention), which would make the order moot. **Verify [?]**: if strikes DO eat a GCD on Turtle, the order matters and should be discussed | If strikes are on-next-swing, reordering changes nothing. If they are on-GCD, swapping delays the strike a press — measurable on a dummy either way |
| P3 | **Holy Strike vs Crusader emphasis (talented Ret)** | Buff-timer alternation: HS keeps Holy Might, CS keeps Zeal, HS fills | "**Holy Strike on CD** (mana-free, mana via JoW) → ramp CS to Zeal" — HS-first emphasis | rotations.md Ret `[T]` (but self-tensioned: HS "on CD" + CS ramp can't both happen on ONE shared 6s CD) | **No change without a dummy log.** The code's alternation is a *more precise* statement of the same intent; research's phrasing can't be implemented literally | Replacing timer-driven alternation with naive "HS on CD" would drop Zeal entirely — clear regression risk |
| P4 | **Consecration role** | AoE-only manual toggle, cast on CD when on; skipped in mana recovery | Ret: "Consecration if mana allows" (single-target filler, mana-gated); Prot: "high-rank Consecration" core | rotations.md `[T]` | **User decision**: current design is deliberate (no reliable enemy count on 1.12; README documents it). If wanted for ST, that's just "toggle stays on" — a doc note, not a code change | Auto-casting Consecration ST would burn mana in leveling/5-mans; the manual toggle is the safer default |
| P5 | **Prot: Holy Shield trigger** | Cast whenever its own CD is free (toggle on) | "Holy Shield **on Redoubt proc**" | rotations.md Prot `[T]` — interplay claim, **[?]** in practice | **Report + verify**: needs in-game confirmation that holding Holy Shield for Redoubt procs is a real Turtle interaction (charges/uptime math). Do not change on paper | Holding a defensive for a proc that isn't real = uptime loss on a TANK defensive — highest-risk change in this class; demands strong evidence |
| P6 | **Prot: Bulwark of the Righteous missing** | Not referenced anywhere in the module | Row-7 Prot capstone: "Holy damage + 40% DR, 3-min CD" — part of the tank rotation | rotations.md Prot `[T]` | **Gap, report**: if the user tanks with this talent, add as an opt-in toggle (new ability = rotation change → needs sign-off + exact spell name from the client) | Low risk to add as opt-in-default-off; wrong spell name just no-ops (KnowsSpell gate) |
| P7 | **Prot: which seal** | Template: debuff *Seal of the Crusader* + damage *Seal of Righteousness*; Wisdom only via mana-management hysteresis | Prot: "judge **Seal of Wisdom**, reseal" as the core loop (mana sustain) | rotations.md Prot `[T]` | **Config-level**: the engine already supports it (set Wisdom as debuff seal / mana-manage). At most change the `prot` TEMPLATE default — still gated since templates seed rotations | Template-only change; existing profiles unaffected (NormalizeProfile never overwrites) |
| P8 | **Seal-less white swings** | `sealTwist` (hold Judgement until <0.4s pre-swing) exists but defaults **off**; after a judge, the reseal happens next press → a white swing can land seal-less | "Judgement on CD (**respect swing timer; never white-swing seal-less**)" | rotations.md Ret `[T]` | **User decision**: flipping `sealTwist` default on (or defaulting it on in the retri template) matches research; it's already implemented | Twist ON can delay Judgement up to a swing — on slow weapons that postpones JoW/JoL uptime; hand-tuned default may be deliberate |
| P9 | **Heal mode: melee-as-healing philosophy** | Strikes only weave when **nobody is hurt** (Holy Strike splash filler) or to reload Holy Shock; targeted heals always preempt | Holy min-max: "MELEE the boss — Holy Strike (AoE group heal) + CS (reset Holy Shock). **>30% of endgame healing** can come from melee" — melee is a primary healing channel, not downtime filler | rotations.md Holy `[T]` | **Discuss**: an optional "aggressive melee-holy" mode (weave Holy Strike even with moderate group damage, e.g. above the emergency line) would match the research. Significant behavior change → per-class sign-off + in-game testing | Weaving strikes while people are hurt trades targeted-heal latency for splash volume; badly tuned it drops someone. The current conservative gate is defensible |
| P10 | **Heal mode: Daybreak not tracked** | No handling of the Daybreak crit-heal buff (12s +20% healing-taken/+5% max-HP) | Daybreak capstone called out for Holy | rotations.md Holy `[T]` | **Note only**: it's a passive proc on the TARGET; possible future use is target-preference while the buff runs. Not worth logic until tuning phase | — |
| P11 | **Leveling ladder leans CS** | Pre-talent autodps: CS to 3 Zeal first, HS only after | Leveling: "Seal of Command R1 + **Holy Strike** (free) + Judgement between autos" — HS-lean while leveling | rotations.md Leveling `[T]` | **User decision**: pre-talent HS-lean is arguable (HS is mana-free at low ranks? — verify mana costs); current CS-lean is the hand-tuned ExAutoCSHS heritage | Wrong lean while leveling costs little; verify Holy Strike's actual "free" claim (code's DOWNRANK table lists nonzero HS mana ceilings — research's "mana-free" may be Turtle-wrong or rank-1-only **[?]** |

### Match notes (checked, no discrepancy)

- Strikes share ONE cooldown — code models it exactly (`ResolveSharedCD`, one pick per
  window). Matches `[T]`.
- Blessed Strikes → Holy Shock reset weave is implemented (heal mode, talent-detected,
  never over an emergency). Matches `[T]`.
- Holy Shock is heal-only in code (never cast offensively). Matches the Turtle removal
  `[T]`.
- Hammer of Wrath ≤20% = standard execute gate; Exorcism restricted to Undead/Demon with
  creature-type check. Vanilla-correct `[V]`.
- Seal choice is user-config (SoR default in templates = research's preference). ✓
- Hand spells (BoP/Freedom/Sacrifice) are Phase 4 scope — correctly absent today.

---

*(Sections 2-9 appended as each class is audited.)*
