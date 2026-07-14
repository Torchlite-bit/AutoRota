# Aegis_SBR — Turtle WoW 1.18.1 Custom Mechanics

Confirmed Turtle-specific facts that DIVERGE from vanilla 1.12 and therefore change
rotations. Keep this separate from `rotations.md` so the audit can cite mechanics
directly. Turtle has shipped two major "Class Change" batches (CC1, CC2/1.17.2) plus
1.18.0/1.18.1 tuning. Verify against the live client for edge cases; Turtle's custom
client can differ from stock 1.12.

## Talent trees (reference)
- Warrior: https://talents.turtlecraft.gg/warrior
- Paladin: https://talents.turtlecraft.gg/paladin
- Hunter: https://talents.turtlecraft.gg/hunter
- Rogue: https://talents.turtlecraft.gg/rogue
- Priest: https://talents.turtlecraft.gg/priest
- Shaman: https://talents.turtlecraft.gg/shaman
- Mage: https://talents.turtlecraft.gg/mage
- Warlock: https://talents.turtlecraft.gg/warlock
- Druid: https://talents.turtlecraft.gg/druid

Primary sources: Turtle WoW Wiki (turtle-wow.fandom.com), forum.turtle-wow.org /
forum.turtlecraft.gg theorycraft threads, r/turtlewow, community class guides.

## Paladin (largest divergence)
- **Offensive Holy Shock REMOVED**; Holy Shock is heal-only (row 5). Old ranged "Shockadin"
  intentionally removed.
- New baseline melee abilities: **Holy Strike** and **Crusader Strike**, sharing ONE **6s
  cooldown**. Holy Strike: instant, 43% spell-power coefficient (damage), 5% healing-power
  (heal — it's an AoE group heal).
- **Blessed Strikes** talent: Crusader Strike has 20/40/60/80/100% chance to reset Holy
  Shock's cooldown; after such a reset, Holy Shock's GCD is reduced by 1s.
- Holy is a **melee-capable healer**: melee + Holy Strike (group heal) + Crusader Strike
  (reset Holy Shock for instant, un-silenceable heals). Can be >30% of endgame healing.
- Ret: keep a Seal up always; **Seal of Righteousness generally preferred** (triggers
  Windfury/Crusader enchants). Holy Strike is mana-free and returns mana with Judgement of
  Wisdom.
- Hand spells (BoP/Freedom/Sacrifice) no longer overwrite normal Blessings.

## Hunter
- **Survival is a MELEE archetype** (dev-branded "Melee Hunter"). Carve = 10-yd cone AoE,
  up to 5 targets, **shares cooldown with Multi-Shot**. Stinging Nettle Lacing: Mongoose
  Bite + Fire traps apply reduced-duration Serpent Sting. Wing Clip's "Phantom Strike"
  triggers on-swing effects (Windfury etc.) without damage.
- **Aimed Shot is baseline (lvl 20)**; **"Trueshot" renamed Steady Shot** (first MM
  capstone). MM endgame = Auto Shot + Steady Shot weave; Aimed Shot often dropped.
- Aspect of the Wolf now grants melee AP and no longer blocks ranged abilities.
- Piercing Shots: crit Aimed/Steady/Multi bleeds (no threat).

## Shaman
- **Elemental core is Flame Shock + Molten Blast + Lightning Bolt**, not LB-spam. Molten
  Blast (Rekindled Flame) refreshes Flame Shock. **Electrify** (replaced Elemental Fury):
  LB/CL stack +2% Nature dmg / +20% spell crit-damage, to 5, passively.
- Nature damage has **no raid-amplification debuff** → Elemental is bottom-tier raid DPS.
- **Lightning Strike** (Enhancement custom capstone): 60% weapon + 20% weapon as Nature,
  10s CD, consumes/empowers a shield charge. Stormstrike + Lightning Strike **no longer
  trigger chance-on-hit effects** (e.g. Windfury) on Turtle.
- **Shaman can TANK** (Turtle-unique, in active dev): Rockbiter affects ALL threat;
  shield-charge avoidance builds; Stoneskin/Strength totems.
- Water Shield exists (mana return / dodge-stacking builds).

## Mage
- **Arcane is a real DPS tree**: Arcane Surge (post-resist proc), Arcane Rupture (buffs
  Missiles), Resonance Cascade (spell duplication), Temporal Convergence (buffs Rupture).
  Arcane Surge GCD doesn't scale with haste (drops off >~30% haste).
- **Fire (1.18.0/1.18.1): Ignite = 4s window**; **Fire Blast applies Scorch stacks**
  (renamed Fire Vulnerability); Blast Wave CD shortened. **Hot Streak**: Fireball/Fire Blast
  crits reduce next Pyroblast cast time.
- **Frost gained Icicles + Flash Freeze + an Ice Barrier damage bonus** (breaks
  Frostbolt-only monotony).

## Rogue
- Combat is the only endgame-viable PvE spec. **Surprise Attack** (Combat capstone): usable
  after dodge, unblockable. **Combo points reset (not lost) on target switch.** Blade Rush
  scales energy regen with agility. Rogues can wield 1H axes.

## Priest
- **Discipline reworked into holy-damage support DPS** (Smite/Holy Fire focus). **PW:Shield
  castable in Shadowform.** **Proclaim Champion** (Holy capstone): tank buff (DR, resist,
  mana return to priest, hourly battle-res).

## Warlock
- **Dark Harvest** (Affliction capstone). **Nightfall** procs from Corruption, Dark Harvest,
  and drains. **Malediction** lets Curse of Agony coexist with another curse.

## Druid
- **Powershift Shred** dominant for Feral DPS (bleeds weaker, can't crit). **Savage Bite**
  high threat (removes MCP dependency). **Barkskin (Feral)** defensive.
- **Balance rework**: Insect Swarm + Moonfire DoTs augment Wrath/Starfire nukes; Moonfire
  18s; Sylvan Blessing mana regen; boomkin itemization added (T2.5/AQ40).
- Direct form-to-form shifting; feral consumables allowed.

## Global caps
- **32 buffs / 16 debuffs** per unit — avoid burning debuff slots on low-value applications
  near the cap.

## Required addon stack (recap)
- **SuperWoW**: `CastSpellByName(name[, unit])`, `UNIT_CASTEVENT`, `SpellInfo(id)`, GUIDs.
- **Nampower**: cast queueing/timing (matters for Fire mage Ignite window, hunter shot
  clipping).
- **SuperCleveRoidMacros**: macro conditionals.
