-- ============================================================
-- Class_Priest_UI  -  priest window body for AutoRota
-- Builds and binds only the priest specific controls. The shared
-- window shell and profile management live in AutoRota_UI.lua.
-- ============================================================

local M = AutoRota.classes.PRIEST

function M:BuildBody(ui, f)
    -- General
    ui:FS(f, "GameFontNormal", "General"):SetPoint("TOPLEFT", f, "TOPLEFT", 20, -142)
    self.healCB = ui:CreateCheck("healMode", f, "Heal mode (group healing)", nil, function(on) if ui.buf then ui.buf.healMode = on; ui:Refresh() end end)
    self.healCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 22, -166)
    self.innerFireCB = ui:CreateCheck("useInnerFire", f, "Keep Inner Fire up", "Inner Fire", function(on) if ui.buf then ui.buf.useInnerFire = on; ui:Refresh() end end)
    self.innerFireCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 200, -166)

    -- Shadow & leveling (damage)
    ui:FS(f, "GameFontNormal", "Shadow & leveling"):SetPoint("TOPLEFT", f, "TOPLEFT", 20, -200)
    self.shadowformCB = ui:CreateCheck("useShadowform", f, "Hold Shadowform", "Shadowform", function(on) if ui.buf then ui.buf.useShadowform = on; ui:Refresh() end end)
    self.shadowformCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 22, -224)
    self.mindBlastCB = ui:CreateCheck("useMindBlast", f, "Mind Blast", "Mind Blast", function(on) if ui.buf then ui.buf.useMindBlast = on; ui:Refresh() end end)
    self.mindBlastCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 200, -224)
    self.swpCB = ui:CreateCheck("useShadowWordPain", f, "Shadow Word: Pain", "Shadow Word: Pain", function(on) if ui.buf then ui.buf.useShadowWordPain = on; ui:Refresh() end end)
    self.swpCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 22, -248)
    self.devouringCB = ui:CreateCheck("useDevouringPlague", f, "Devouring Plague", "Devouring Plague", function(on) if ui.buf then ui.buf.useDevouringPlague = on; ui:Refresh() end end)
    self.devouringCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 200, -248)
    self.holyFireCB = ui:CreateCheck("useHolyFire", f, "Holy Fire", "Holy Fire", function(on) if ui.buf then ui.buf.useHolyFire = on; ui:Refresh() end end)
    self.holyFireCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 22, -272)
    self.mindFlayCB = ui:CreateCheck("useMindFlay", f, "Mind Flay", "Mind Flay", function(on) if ui.buf then ui.buf.useMindFlay = on; ui:Refresh() end end)
    self.mindFlayCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 200, -272)
    self.pwShieldMeleeCB = ui:CreateCheck("usePWShieldMelee", f, "Shield when in melee", "Power Word: Shield", function(on) if ui.buf then ui.buf.usePWShieldMelee = on; ui:Refresh() end end)
    self.pwShieldMeleeCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 22, -296)
    self.spiritTapCB = ui:CreateCheck("useSpiritTapFinisher", f, "Finisher (secure kill)", "Mind Blast", function(on) if ui.buf then ui.buf.useSpiritTapFinisher = on; ui:Refresh() end end)
    self.spiritTapCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 200, -296)

    ui:FS(f, "GameFontNormalSmall", "Filler"):SetPoint("TOPLEFT", f, "TOPLEFT", 24, -322)
    self.fillerDD = ui:CreateDropdown("filler", f, 150, function(v) if ui.buf then ui.buf.filler = v; ui:Refresh() end end)
    self.fillerDD:SetPoint("TOPLEFT", f, "TOPLEFT", 110, -320)
    self.useWandCB = ui:CreateCheck("useWand", f, "Use wand", nil, function(on) if ui.buf then ui.buf.useWand = on; ui:Refresh() end end)
    self.useWandCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 270, -320)
    self.executeSlider = ui:CreateSlider("executeHp", f, "finisher below", function(v) if ui.buf then ui.buf.executeHp = v; ui:Refresh() end end)
    self.executeSlider:SetPoint("TOPLEFT", f, "TOPLEFT", 28, -360)
    self.manaFloorSlider = ui:CreateSlider("fillerManaFloor", f, "wand below mana", function(v) if ui.buf then ui.buf.fillerManaFloor = v; ui:Refresh() end end)
    self.manaFloorSlider:SetPoint("TOPLEFT", f, "TOPLEFT", 200, -360)

    -- Healing
    ui:FS(f, "GameFontNormal", "Healing"):SetPoint("TOPLEFT", f, "TOPLEFT", 20, -406)
    self.healAtSlider = ui:CreateSlider("healThreshold", f, "heal members below", function(v) if ui.buf then ui.buf.healThreshold = v; ui:Refresh() end end)
    self.healAtSlider:SetPoint("TOPLEFT", f, "TOPLEFT", 28, -432)
    self.flashHealCB = ui:CreateCheck("useFlashHeal", f, "Flash Heal (emergency)", "Flash Heal", function(on) if ui.buf then ui.buf.useFlashHeal = on; ui:Refresh() end end)
    self.flashHealCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 22, -468)
    self.greaterHealCB = ui:CreateCheck("useGreaterHeal", f, "Greater Heal (big)", "Greater Heal", function(on) if ui.buf then ui.buf.useGreaterHeal = on; ui:Refresh() end end)
    self.greaterHealCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 200, -468)
    self.flashAtSlider = ui:CreateSlider("flashHealPct", f, "Flash only below", function(v) if ui.buf then ui.buf.flashHealPct = v; ui:Refresh() end end)
    self.flashAtSlider:SetPoint("TOPLEFT", f, "TOPLEFT", 28, -510)
    self.pwShieldCB = ui:CreateCheck("usePWShield", f, "Power Word: Shield", "Power Word: Shield", function(on) if ui.buf then ui.buf.usePWShield = on; ui:Refresh() end end)
    self.pwShieldCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 22, -542)
    self.renewCB = ui:CreateCheck("useRenew", f, "Renew", "Renew", function(on) if ui.buf then ui.buf.useRenew = on; ui:Refresh() end end)
    self.renewCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 200, -542)
    self.prayerCB = ui:CreateCheck("usePrayer", f, "Prayer of Healing (AoE)", "Prayer of Healing", function(on) if ui.buf then ui.buf.usePrayer = on; ui:Refresh() end end)
    self.prayerCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 22, -566)
    self.innerFocusCB = ui:CreateCheck("useInnerFocus", f, "Inner Focus on AoE", "Inner Focus", function(on) if ui.buf then ui.buf.useInnerFocus = on; ui:Refresh() end end)
    self.innerFocusCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 200, -566)
    self.offensiveCB = ui:CreateCheck("offensiveWeave", f, "Weave Smite/Holy Fire", "Smite", function(on) if ui.buf then ui.buf.offensiveWeave = on; ui:Refresh() end end)
    self.offensiveCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 22, -590)
    self.lightwellCB = ui:CreateCheck("useLightwell", f, "Place Lightwell", "Lightwell", function(on) if ui.buf then ui.buf.useLightwell = on; ui:Refresh() end end)
    self.lightwellCB.cb:SetPoint("TOPLEFT", f, "TOPLEFT", 200, -590)

    ui:Divider(f, -190)   -- above Shadow & leveling
    ui:Divider(f, -396)   -- above Healing

    ui:Tip(self.healCB.cb, "Heal mode", "Heal the party/raid with responsive downranking, and weave damage between heals.", "Also /ar heal on|off. Off runs the shadow/leveling damage rotation.")
    ui:Tip(self.innerFireCB.cb, "Inner Fire", "Keep Inner Fire active at all times for the armor and spell bonus.")
    ui:Tip(self.shadowformCB.cb, "Hold Shadowform", "Stay in Shadowform. While in it, Holy spells (Smite, Holy Fire, heals) are skipped.", "Leave off for a leveling priest who still casts Holy spells.")
    ui:Tip(self.mindBlastCB.cb, "Mind Blast", "Cast on cooldown - the Shadow Weaving trigger and the leveling pull.")
    ui:Tip(self.swpCB.cb, "Shadow Word: Pain", "Keep the DoT up. Turn off in raids to respect debuff-slot limits.")
    ui:Tip(self.devouringCB.cb, "Devouring Plague", "Undead-only DoT; used automatically when known.")
    ui:Tip(self.holyFireCB.cb, "Holy Fire", "Fire DoT and a strong nuke. Skipped while in Shadowform.")
    ui:Tip(self.mindFlayCB.cb, "Mind Flay", "Channelled shadow filler. Used when the filler is not the wand and mana is healthy.")
    ui:Tip(self.pwShieldMeleeCB.cb, "Shield when in melee", "Cast Power Word: Shield when a mob reaches melee or you drop below half health.", "Skipped while Weakened Soul is on you, so it never wastes a cast.")
    ui:Tip(self.spiritTapCB.cb, "Finisher (secure kill)", "Under the threshold below, burst with Mind Blast then Smite to land the killing blow", "and the experience (which also feeds Spirit Tap).")
    ui:Tip(self.fillerDD, "Filler", "Used when every enabled cast is up. Wand conserves mana (the 5-second rule);", "Mind Flay and Smite spend it. The wand is always used when mana drops below the floor.")
    ui:Tip(self.useWandCB.cb, "Use wand for mana regen", "On: the filler drops to the wand below the mana floor to let mana regenerate (the 5-second rule).", "Off: the priest keeps casting and never wands - it can run dry. With no wand equipped it auto-casts Mind Flay or Smite instead.")
    ui:Tip(self.executeSlider, "Finisher below", "Target health percent under which the kill-securing finisher fires.")
    ui:Tip(self.manaFloorSlider, "Wand below mana", "Your mana percent under which the filler drops to the wand to let mana regenerate.")
    ui:Tip(self.healAtSlider, "Heal members below", "Members below this health get healed; lower ranks are chosen for small deficits.")
    ui:Tip(self.flashHealCB.cb, "Flash Heal", "Fast, expensive heal reserved for emergencies so it does not drain your mana.")
    ui:Tip(self.greaterHealCB.cb, "Greater Heal", "Big, slow heal used (downranked) for large deficits.")
    ui:Tip(self.flashAtSlider, "Flash only below", "Health percent under which Flash Heal is allowed as an emergency heal.")
    ui:Tip(self.pwShieldCB.cb, "Power Word: Shield", "Shield a hurt member, but only when there is no Weakened Soul - the over-bubble guard.")
    ui:Tip(self.renewCB.cb, "Renew", "Keep the heal-over-time on a hurt member as efficient maintenance.")
    ui:Tip(self.prayerCB.cb, "Prayer of Healing", "Group heal when several members are hurt at once.")
    ui:Tip(self.innerFocusCB.cb, "Inner Focus on AoE", "Pop Inner Focus before Prayer of Healing to negate its mana cost.")
    ui:Tip(self.offensiveCB.cb, "Weave Smite/Holy Fire", "When no one needs healing, cast Smite/Holy Fire as offensive support.", "Skipped in Shadowform. Pairs with Enlighten-style talents.")
    ui:Tip(self.lightwellCB.cb, "Place Lightwell", "Place a Lightwell when out of combat, off cooldown, and known.")
end

function M:RefreshBody(ui, buf)
    -- filler dropdown: wand always, the casts only if known
    local fo = { { label = "Wand (Shoot)", value = "Wand" } }
    if self:KnowsSpell("Mind Flay") then table.insert(fo, { label = "Mind Flay", value = "Mind Flay" }) end
    if self:KnowsSpell("Smite")     then table.insert(fo, { label = "Smite",     value = "Smite" })     end
    local fcur = buf.filler or "Wand"
    local fshown, fc
    if fcur == "Wand" then fshown, fc = "Wand (Shoot)", ui.COL.white
    elseif self:KnowsSpell(fcur) then fshown, fc = fcur, ui.COL.white
    else fshown, fc = fcur .. " (not learned)", ui.COL.red end
    ui:SetDropdown(self.fillerDD, fo, fcur, fshown, fc)

    -- General
    ui:BindCheck(self.healCB, buf.healMode)
    ui:BindCheck(self.innerFireCB, buf.useInnerFire, "Inner Fire")

    -- Shadow & leveling
    ui:BindCheck(self.shadowformCB, buf.useShadowform, "Shadowform")
    ui:BindCheck(self.mindBlastCB, buf.useMindBlast, "Mind Blast")
    ui:BindCheck(self.swpCB, buf.useShadowWordPain, "Shadow Word: Pain")
    ui:BindCheck(self.devouringCB, buf.useDevouringPlague, "Devouring Plague")
    ui:BindCheck(self.holyFireCB, buf.useHolyFire, "Holy Fire")
    ui:BindCheck(self.mindFlayCB, buf.useMindFlay, "Mind Flay")
    ui:BindCheck(self.pwShieldMeleeCB, buf.usePWShieldMelee, "Power Word: Shield")
    ui:BindCheck(self.spiritTapCB, buf.useSpiritTapFinisher, "Mind Blast")
    self.executeSlider:SetValue(buf.executeHp or 0);        self.executeSlider.valText:SetText((buf.executeHp or 0) .. "%")
    self.manaFloorSlider:SetValue(buf.fillerManaFloor or 0); self.manaFloorSlider.valText:SetText((buf.fillerManaFloor or 0) .. "%")
    ui:BindCheck(self.useWandCB, buf.useWand)
    if not self:HasWand() then
        self.useWandCB.label:SetText("Use wand (none)")
        ui:Color(self.useWandCB.label, ui.COL.grey)
    end
    -- the damage filler/sliders matter in DPS mode
    local dpsOn = not buf.healMode
    ui:SliderEnable(self.executeSlider, dpsOn and buf.useSpiritTapFinisher)
    ui:SliderEnable(self.manaFloorSlider, dpsOn)

    -- Healing
    self.healAtSlider:SetValue(buf.healThreshold or 0); self.healAtSlider.valText:SetText((buf.healThreshold or 0) .. "%")
    self.flashAtSlider:SetValue(buf.flashHealPct or 0); self.flashAtSlider.valText:SetText((buf.flashHealPct or 0) .. "%")
    ui:BindCheck(self.flashHealCB, buf.useFlashHeal, "Flash Heal")
    ui:BindCheck(self.greaterHealCB, buf.useGreaterHeal, "Greater Heal")
    ui:BindCheck(self.pwShieldCB, buf.usePWShield, "Power Word: Shield")
    ui:BindCheck(self.renewCB, buf.useRenew, "Renew")
    ui:BindCheck(self.prayerCB, buf.usePrayer, "Prayer of Healing")
    ui:BindCheck(self.innerFocusCB, buf.useInnerFocus, "Inner Focus")
    ui:BindCheck(self.offensiveCB, buf.offensiveWeave, "Smite")
    ui:BindCheck(self.lightwellCB, buf.useLightwell, "Lightwell")
    -- heal sliders matter in heal mode
    ui:SliderEnable(self.healAtSlider, buf.healMode)
    ui:SliderEnable(self.flashAtSlider, buf.healMode and buf.useFlashHeal)
end

-- Open the shared window for this class.
M.OpenConfig = function(mod)
    if not AutoRotaUI then
        AutoRota:Throttle("UI not ready yet, try again in a moment.")
        return
    end
    AutoRotaUI:Toggle()
end
