# 📜 Changelog

All notable changes to **AutoRota** are documented here. Versions are listed newest first.

---

## v0.5.2b — Paladin Strike Overhaul

A focused pass on the **Paladin** strike engine (*Holy Strike* / *Crusader Strike*),
making it talent- and weapon-aware, adding mana-based downranking, and folding the
old per-strike checkboxes into a single control. Logic is informed by the proven
*ExAutoCSHS* addon. Warrior and Rogue behaviour is unchanged.

### 🛡️ Paladin: Strike Engine Rework
- **Strike Mode dropdown** replaces the separate *Holy Strike* and *Crusader Strike* checkboxes. One control both **enables** the strikes and picks the **style**: `Off`, `Auto (talent/weapon)`, `Crusader Strike`, `Holy Strike`, and `Holy then Crusader`. Existing profiles migrate automatically — both strikes on → *Auto*, one on → that one, both off → *Off*.
- **Talent + weapon aware Auto:** *Auto* reads both your talents and your equipped weapon, for two separate decisions:
  - *Holy Might* is maintained **only if you have Vengeful Strike** — the talent that makes *Holy Strike* apply the buff. A leveling paladin without it never wastes a global chasing a buff it cannot get.
  - The *Holy*-vs-*Crusader* **lean** is set by **Righteous Strike** (deep Protection) **or** a shield/offhand equipped → *Holy* lean for threat; a two-hander with no threat talent → *Crusader* lean. Swapping weapons changes the lean live.
- **Zeal upkeep is universal:** *Zeal* is built to 3 stacks and refreshed in **every** mode and on **every** weapon, above the filler choice — so it is always maintained, whether you are tanking with a 1H or leveling with a 2H.
- **Per-target opener:** the first strike on each new target follows your opener (Auto gets *Holy Might* rolling if the talent makes it work, otherwise opens by the tanking lean), then normal maintenance takes over.
- **Prioritize Zeal (opt-in):** builds *Zeal* to 3 stacks before anything else, then follows the selected mode.
- **Mana downranking (opt-in):** *Downrank when low* casts lower ranks of *Holy*/*Crusader Strike* as your raw mana drops, to keep swinging while leveling. Thresholds mirror the *ExAutoCSHS* tables — **absolute mana, not percent** — so a large mana pool stays at full rank and only a nearly-empty pool steps down. The chosen rank is always clamped to your highest known rank.
- **Consecration now leads AoE:** when enabled, *Consecration* is cast right after the strike (priority 2b) instead of last, so it is a primary AoE source rather than a leftover filler. It is still a manual toggle and still held during mana recovery.

### ✨ Added
- **`/ar strike off|auto|cs|hs|hscs`** *(Paladin)* — sets the strike mode on the active profile, bindable for mid-fight changes.

### 🔧 Changed
- **Paladin config panel reorganised:** *Strike mode* now leads the **Spells** section, with *Prioritize Zeal* and *Downrank when low* beside it. The two per-strike checkboxes are gone, so the panel is slightly shorter.
- **`.toc`** version bumped to **0.5.2b**. *(The login-banner string in `AutoRota.lua` is a separate one-line `ver` field; bump it to match if you want the banner to read 0.5.2b.)*

### 🐛 Fixed
- **Downranking now actually engages.** A Lua quirk — `string.gsub` returning *two* values, with the replacement count being read as a numeric base — made rank parsing fail for ranks 5 and up, silently pinning everything to full rank. Rank detection is fixed.
- **Trace output restored.** The second Paladin trace line (strike / downrank diagnostics) was landing inside the 0.4s trace throttle and being dropped every press; both lines now print together. The line reports `mode`, each strike's `R=used/max`, `lean`, offhand `oh`, `dr`, raw `mana`, and your `veng`/`rght` talent ranks.
- Removed dead strike-related profile-validity checks, so a not-yet-learned strike never blocks activating a profile — it simply degrades gracefully, the same way the Rogue handles its level-gated abilities.

### 📝 Notes & Tips
- In **Crusader** mode, a Vengeful-talented paladin will still weave the occasional *Holy Strike* to keep *Holy Might* up (a damage gain even for a CS-focused player), matching *ExAutoCSHS*. If you want a strict no-HS option, that would be a separate toggle.
- **Leveling on a 2H and want *Holy Strike* in the mix** (for its holy damage / heal)? Set the mode to **Holy Strike** — it still builds and refreshes *Zeal* with *Crusader Strike* and fills with *Holy Strike*. *Auto* deliberately leans *Crusader* on a two-hander for DPS, which is why it does not weave HS there unless you are Vengeful-talented.
- Talent names live as constants at the top of `Class_Paladin.lua` (`Vengeful Strike`, `Righteous Strike`); if Turtle renames a talent, that is the single place to adjust. The downrank mana thresholds are editable in the same file.

---

## v0.5b — Warrior Beta

The headline of this release is a brand new **Warrior** combat module, plus a
minimap button and a couple of **Paladin** additions. Rogue behaviour is unchanged.

### ⚔️ New: Warrior Module `(Beta)`
A roleless, toggle-driven engine covering **Arms, Fury, and Protection** from early
leveling through endgame raiding. Enable the abilities you have and the priority
degrades gracefully as you learn the rest.

- **All-Spec Roleless Design:** One profile schema serves every spec via toggles. Unlearned abilities are skipped automatically and flagged *(not learned)* in the panel, so a single setup keeps working as you level.
- **Stance & Rage Aware Casting:** A warrior-specific gate verifies rage, stance, and cooldown *before* committing to a cast, so a stance- or rage-locked ability can never stall the priority chain. Stance rules follow vanilla 1.12 and stay conservative if Turtle relaxes them.
- **Reactive Proc Windows:** Reads the combat log for target dodges and your own block/dodge/parry to open short windows for *Overpower* (Battle Stance) and *Revenge* (Defensive Stance), mirroring the Rogue's Riposte tracker.
- **Optional Stance Dancing:** Experimental opt-in (off by default) that auto-swaps to Battle Stance for *Overpower*, then drifts back to your configured home stance, throttled by a swap cooldown to prevent thrashing.
- **Smart Rage Dump:** Queues *Heroic Strike* (or *Cleave* in AoE mode) onto your next swing only above a configurable rage floor, and suppresses it during the *Execute* phase so surplus rage funnels into *Execute*.
- **Cooldown Automation:** *Death Wish*, *Recklessness*, and *Berserker Rage* fire on cooldown, only on Elite/Boss targets, or fully manually — the same three-state model used by the other classes — while *Bloodrage* tops up rage on demand, even before the pull.
- **Threat Toolkit:** Maintains *Sunder Armor* up to a chosen stack count and weaves *Shield Slam*, *Revenge*, and *Shield Block* upkeep for Protection tanking.
- **Starter Templates:** Ships with `starter`, `fury`, `arms`, and `prot` presets. Create one with `/ar new <name> <template>`.

### 🛡️ Paladin Updates
- **Consecration (opt-in):** New AoE filler, cast on cooldown when enabled. Because the 1.12 client cannot reliably count nearby enemies, it is a manual toggle — the *Consecration (AoE)* checkbox, or `/ar aoe` for a quick keybind flip. It sits last in the priority so it never delays strikes, *Holy Shield*, seal/Judgement upkeep, or the execute, and it is held during mana recovery.
- **Exorcism (opt-in):** New on-cooldown nuke, used only against *Undead* and *Demon* targets (checked via creature type). Also held during mana recovery.
- Both default to off, are flagged *(not learned)* in the panel until trained, and gain `/ar spell` aliases (`consec` / `cons`, `exo`). `/ar aoe` now works for Paladins too, toggling Consecration.

### ✨ Added
- **Minimap Button:** A draggable minimap button (`AutoRota_Minimap.lua`) that wears your character's class crest (paladin, rogue, warrior, etc., with a cog fallback). Left-click opens the configuration panel, right-click runs the rotation once, and dragging moves it around the minimap edge. Its position is saved per character; toggle visibility with **`/armap`**.
- **`/ar aoe`** *(Warrior)* — toggles AoE mode (rage dump becomes *Cleave*, *Whirlwind* used on cooldown). Bindable for mid-fight flips.
- **`/ar cd on|elite|off`** *(Warrior)* — sets cooldown usage to always, Elite/Boss only, or fully manual.
- **`/ar dance`** *(Warrior)* — toggles experimental stance dancing for *Overpower*.
- **`/ar spell <alias> on|off`** *(Warrior)* — flips an individual ability on the active profile, with short aliases (`ms`, `bt`, `ss`, `ww`, `op`, `rev`, `exec`, `sa`, `tc`, `hs`, `cleave`, `sweep`, `dw`, `reck`, `br`, `bld`, `sb`).

### 🔧 Changed
- **`.toc`** now loads `AutoRota_Minimap.lua` plus `classes\Class_Warrior.lua` and `classes\Class_Warrior_UI.lua`, and the addon version is bumped to **0.5b**.
- **README** updated with the Warrior section, the Paladin Consecration/Exorcism notes, the new commands in the CLI table, and the toggle / spell-alias references.
- The **Paladin config window** grew slightly to fit the two new ability checkboxes (mana/HP sections shifted down to match).

### 📝 Notes & Known Limitations
- **AoE is a manual toggle.** SuperWoW exposes no reliable "enemies in range" count on the 1.12 client, so AoE mode is flipped by you (`/ar aoe` or the checkbox) rather than auto-detected.
- **Stance dancing is experimental** and disabled by default. With it off, *Overpower* only fires while already in Battle Stance and *Revenge* only in Defensive Stance. With it on, expect a little rage loss per swap (Tactical Mastery dependent) and tune to taste in game.
- **Stance assumptions are vanilla 1.12** (e.g. *Whirlwind* is Berserker-only, *Thunder Clap* is Battle-only). If Turtle has relaxed a restriction the module simply stays safe rather than misfiring. Rage costs and stance requirements live as constants at the top of `Class_Warrior.lua` for easy tuning.
- **`Heroic Strike` / `Cleave` queueing relies on Nampower** (a required dependency), which avoids the classic re-toggle flicker when the on-next-swing ability is re-issued.
- **`Shield Slam`** requires a shield equipped; enable it only on a Protection setup.

---

## v0.4 — Configuration Panel & Database

- **Graphical Configuration Panel:** Introduced a complete in-game UI shell (`/ar ui`) for managing the rotation visually, replacing macro-embedded configuration.
- **Profile Database:** Added saved, per-character profiles you can create, rename, activate, and delete, seeded from per-class templates.
- **Multi-Class Architecture:** Reworked the core into a shared engine that dynamically loads the module matching your class, with the **Paladin** ("Roleless Seal Model") and **Rogue** (combo-point priority) modules.
- **Zero-Clipping Logic:** Standardised the strict single-cast-per-press priority with early returns across modules to prevent GCD clipping.
- `/pa`, `/paladinauto`, and `/autopala` retained as aliases for `/ar` so older paladin-era macros keep working.
