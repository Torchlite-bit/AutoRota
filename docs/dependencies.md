# Aegis_SBR — Dependency Stack (SuperWoW, Nampower, SuperCleveRoidMacros)

Aegis_SBR is built on three client mods. This documents what each one actually provides —
APIs, events, behaviors, and gotchas — so rotation code targets them correctly instead of
assuming vanilla or retail behavior. **Verify against the versions actually installed on the
user's client**; all three projects have moved forks and changed APIs over time (notes
below). Last researched: 2026.

---

## 1. SuperWoW  (balakethelock/SuperWoW)
A client DLL that extends the 1.12 Lua API with unit GUIDs, cast events, and spell
metadata. This is the backbone of Aegis's targeting and cast detection.

**What Aegis relies on:**
- **Unit GUIDs** — every unit has a stable GUID. Functions accept a GUID where a unitID is
  expected, enabling "soft" targeting (act on a unit without changing your target). GUIDs
  are also returned by many queries (e.g. `UnitExists("player")` returns `exists, guid`).
- **`CastSpellByName(name[, unit])`** — SuperWoW adds the optional second arg so you can
  cast at a specific unit/GUID without targeting it. Core to acting on off-target units.
- **`UNIT_CASTEVENT`** — fires on cast activity for any unit. Args (1.12 globals):
  `arg1` = caster GUID, `arg2` = target GUID, `arg3` = event type
  (`"START"` / `"CAST"` / `"CHANNEL"` / `"FAIL"` etc.), `arg4` = spell ID,
  `arg5` = cast duration (ms). Aegis registers this and dispatches `"CAST"` events to the
  active module's `OnCastEvent(caster, target, spellName)` after resolving the ID → name
  via `SpellInfo`. (Used today for Shaman totem-drop tracking; the basis for future
  interrupt/defensive detection.)
- **`SpellInfo(spellID)`** → returns spell name (and more). Aegis uses it to turn the
  `UNIT_CASTEVENT` numeric spell ID into a name for matching.
- **Combat-log / owner tagging** — SuperWoW exposes the owner of pets/totems/guardians in
  combat-log context, which is what makes **totem destruction detection** feasible
  (roadmap Phase 2): tag a totem's GUID on cast, watch for its death with owner = player.

**Gotchas:**
- GUIDs are large numbers — be careful never to compare them as truncated Lua numbers where
  precision could be lost; treat them as opaque tokens. (Nampower returns GUIDs as hex
  strings for this exact reason — see below.)
- SuperWoW's presence is the gate for `UNIT_CASTEVENT` and `SpellInfo`; Aegis already guards
  registration with `if SpellInfo then ...` so a client without SuperWoW degrades instead of
  erroring. Keep that pattern.
- Feature reference: https://github.com/balakethelock/SuperWoW/wiki/Features

---

## 2. Nampower  (spell queueing / cast efficiency DLL)
Solves a core 1.12 design flaw: the client won't start a second spell until the server
acknowledges the previous one completed, which wastes time equal to your latency every cast.
Nampower stops the client from waiting, and adds spell queueing so a press during the tail
of the current cast fires the instant it's legal.

**Fork/version note (IMPORTANT):**
- The widely-used **pepopo978/nampower has CEASED development**; the maintained line moved to
  **gitea.com/avitasia/nampower**. Other active forks (Emyrk, Dusk-92, gralle mirrors) expose
  an **expanded Lua API documented in `SCRIPTS.md` and events in `EVENTS.md`** in-repo.
- **SuperCleveRoidMacros requires Nampower v3.0.0+** (see §3), so assume a modern Nampower is
  present, but **verify the exact fork/version** before relying on any specific function —
  the API surface differs between the classic pepo build and the newer avitasia/Emyrk line.

**Behaviors that affect rotation logic:**
- **Queueing window**: pressing a spell within the queue window before the current cast ends
  queues it to fire immediately on completion. **Only ONE GCD spell can be queued at a time**
  (a new GCD press REPLACES the queued one); up to **5 non-GCD spells** can queue.
- **Server-tick buffer**: there's a ~50 ms server tick; Nampower uses a small buffer
  (default ~55 ms) to avoid rejections. As of a 2025 update the tick is subtracted from the
  GCD timer, so for cast-time spells ≥ ~ the GCD no buffer is generally needed. Non-GCD
  spells may need `NP_NonGcdBufferTimeMs` spacing (only one non-GCD spell processes per
  server tick). **Implication for a one-button engine:** firing two non-GCD abilities in the
  same press/tick may drop one — space them across ticks/presses rather than stacking.
- **CVar toggles** exist to control queueing (`NP_QueueCastTimeSpells`,
  `NP_QueueInstantSpells`) — some rotations deliberately toggle these off around specific
  casts. Don't assume queueing is always on.

**Expanded Lua API (newer forks — confirm availability before use; from `SCRIPTS.md`):**
- Casting/queue: `QueueSpellByName`, `QueueScript`, `CastSpellByNameNoQueue`,
  `CastSpellNoQueue`.
- Cast info: `GetCastInfo`, `GetCurrentCastingInfo`.
- Cooldowns: `GetSpellIdCooldown`, `GetItemIdCooldown` (with item metadata),
  `GetTrinketCooldown`, `GetTrinkets`, `GetAmmo`.
- Auras: `GetPlayerAuraDuration`, `CancelPlayerAuraSlot`, `CancelPlayerAuraSpellId`,
  `IsAuraHidden`; `GetSpellDuration` (channel duration / first aura effect duration);
  `GetSpellRangeData(rangeIndex)` → minRange, maxRange, flags, name.
- Movement/state: `PlayerIsMoving`, `PlayerIsRooted`, `PlayerIsSwimming`.
- **GUIDs as hex strings**: newer Nampower returns object GUIDs as hex strings (e.g.
  `"0xF5300000000000A5"`) because 1.12 Lua can't hold full 64-bit ints — match/compare
  accordingly if mixing Nampower GUIDs with SuperWoW ones.
- **Custom events (`EVENTS.md`)**: `SPELL_CAST_EVENT` (fires when you start a cast, before
  it's sent to server), `SPELL_START_SELF/OTHER`, `SPELL_GO_SELF/OTHER`,
  `SPELL_DAMAGE_EVENT_SELF/OTHER`, buff/debuff events (`BUFF_ADDED_SELF`,
  `BUFF_REMOVED_SELF`, `BUFF_UPDATE_DURATION_SELF`), `AURA_CAST_ON_SELF/OTHER` (includes an
  aura-cap bitfield for the 32-buff/16-debuff slots — useful for the buff-cap-safety idea).

**Gotcha:** queueing can conflict with other addons that manage casting (QuickHeal/Healbot/
Quiver historically). Aegis IS a casting manager — if a specific interaction misbehaves,
suspect queue timing first.

---

## 3. SuperCleveRoidMacros  (jrc13245/SuperCleveRoidMacros)
Enhanced macro engine for 1.12.1 (Vanilla/Turtle): conditional execution, dynamic
tooltips/icons, extended `/cast` syntax, count-based AoE conditionals, soft-target scanning.
Based on CleverMacro + Roid-Macros. **NOTE: the repo is now a public archive** (development
ceased) — behavior is stable but won't get new features; verify installed behavior.

**Hard requirements (from the wiki):**
- **Nampower v3.0.0+** — required (spell queueing, DBC data, auto-attack events).
- **UnitXP_SP3** — required for distance checks and `[multiscan]` enemy scanning / count-mode
  conditionals.
- **Reactive abilities MUST be on the action bars** for `[reactive]`-style detection to work
  (Revenge, Overpower, Riposte, etc.). *(A future Nampower-based update was planned to lift
  this, but treat the on-bar requirement as current.)* This mirrors Aegis's own
  `EnsureAutoAttack` lesson — some detections depend on the ability being slotted.
- **Unique macro names** required (no blanks/duplicates/spell-name collisions).
- **Macro line length: 261 characters max** (longer can crash without MacroLengthWarn).

**Conditional/behavior facts relevant to the engine:**
- A macro must start with `#showtooltip` (or `#showtooltip spell/item/id`) for dynamic
  icon/tooltip; the icon updates to the **first true condition's action, evaluated left→
  right, top→bottom** — the same "first passing branch wins" model Aegis uses internally.
- Rich conditionals: `[mod:...]`, `[stance:#]` (Shadowform/Stealth = stance 1), `[stealth]`,
  `[combat]`, `[channeling]`, `[combo:#]`, `[cooldown/nocooldown]` (GCD NOT ignored),
  `[cdgcd:...]` (CD incl. GCD), `[hp:...]`, `[stat:...]` (str/agi/ap/rap/healing/spell-power/
  resistances/etc.), `[equipped:...]`, `[known:...]` (spell/talent, optional rank),
  `[reactive]`, `[buff:/nobuff:]`, `[debuff:/nodebuff:]` (own debuffs only unless pfUI
  libdebuff or Cursive provides data), `[casting:...]` on `@unit`.
- **Count-mode / AoE conditionals** (need UnitXP_SP3): `meleerange:>N`, `behind:>=N`,
  `facing:>N`, `inrange:Spell>N`, `insight:>0`, `distance:30>N` — count enemies for
  "AoE-if-N-targets" decisions. Filter qualifiers avoid false positives when combining checks.
- **`[multiscan:...]`** soft-casts at scanned enemies without changing target (needs
  UnitXP_SP3; scanned targets must be in combat with the player). Modifiers like `[mouseuse]`
  auto-place ground-target circles.
- Extra slash verbs with conditionals: `/use`, `/equip`, `/target` (3D scan), `/castsequence`
  (`reset=` options), `/castpet`, `/startattack`, `/stopattack`, `/stopcasting`, `/stopmacro`.
- Flags: `!Spell` (spammable), `~Spell` (toggle buff/aura on/off), `?` (hide icon/tooltip),
  `#` (hide) — prefix semantics matter if Aegis ever emits macro text.

**Debuff-timer caveat:** debuff time-left conditionals only read YOUR OWN debuffs unless
pfUI libdebuff or Cursive is present with data — don't assume enemy-debuff timers are
available for gating without one of those.

**Docs:** https://github.com/jrc13245/SuperCleveRoidMacros/wiki (Conditionals, Slash-
Commands, Reference-Tables pages).

---

## How this maps to Aegis
- Aegis executes rotations **in Lua directly** (priority lists calling `CastSpellByName` /
  Nampower queue functions), rather than emitting SuperCleveRoid macro text. The
  SuperCleveRoid detail matters because (a) the user runs it alongside Aegis, (b) its
  conditional model and its "reactive abilities must be on bars" / debuff-timer-source rules
  describe the same client constraints Aegis's own detections face, and (c) future features
  (interrupts, AoE-target-count decisions) will want the same UnitXP_SP3 count-mode data.
- **Practical rules for rotation code:**
  1. Cast off-target via `CastSpellByName(name, guidOrUnit)` (SuperWoW) rather than
     retargeting.
  2. Detect casts via `UNIT_CASTEVENT` + `SpellInfo` (SuperWoW) — already wired; prefer this
     over blind timers.
  3. Respect Nampower's **one-GCD-queued-at-a-time** and **one-non-GCD-per-tick** limits —
     don't try to fire two GCD/non-GCD abilities in a single press expecting both to land.
  4. Any detection that needs an ability "known & ready" may depend on it being **on a bar**
     (reactive abilities) — mirror the `EnsureAutoAttack` fallback approach where relevant.
  5. Enemy-debuff-timer gating needs a data source (pfUI libdebuff/Cursive) — don't assume it.
  6. Watch the **32-buff / 16-debuff caps**; Nampower's `AURA_CAST_ON_*` cap bitfield can
     drive buff-cap-safety logic later.
