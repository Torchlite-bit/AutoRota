-- ============================================================
-- AutoRota Data Dumper  (Turtle WoW 1.12 client / SuperWoW)
--
-- Extracts the raw data that lets AutoRota's name/ID handling be verified:
--   /ardump spells   full spell database (id -> name, rank, ranges, icon) via a
--                    batched SpellInfo() id scan, PLUS your spellbook resolved
--                    to ids (the exact spells the modules reference)
--   /ardump talents  every talent's tab, index, name, rank/max, icon
--   /ardump buffs    your current buffs and self-debuffs, with their spell ids
--   /ardump debuffs  the current target's debuffs, with their spell ids
--   /ardump all      talents + the full spell scan
--
-- Output goes to <WoW>\imports\ via SuperWoW's ExportFile, AND is always stored
-- in the AutoRotaDumpDB saved variable (so it survives even without ExportFile;
-- find it in WTF\Account\<acct>\SavedVariables\AutoRotaDump.lua after /reload).
--
-- Lua 5.0 / 1.12 safe: table.getn, no '#', string.find captures (no string.match),
-- ipairs/pairs, frame OnUpdate batching so the id scan never freezes the client.
-- ============================================================

AutoRotaDumpDB = AutoRotaDumpDB or {}

local MAXID = 60000   -- top spell id to scan (override: /ardump spells 80000)
local CHUNK = 1500    -- ids processed per frame during the scan

local f = CreateFrame("Frame", "AutoRotaDumpFrame")
f:Hide()

local function pr(msg, r, g, b)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffARDump|r " .. msg, r or 1, g or 1, b or 1)
end

-- SuperWoW returns some aura ids as a wrapped negative; normalize to positive.
local function fixId(id)
    if id and id < -1 then return id + 65536 end
    return id
end

-- Write text to <WoW>\imports\<fname> when ExportFile (SuperWoW) is present, and
-- always keep a copy in the saved variable. Reports where the data landed.
local function emit(key, fname, text)
    AutoRotaDumpDB[key] = text
    if ExportFile then
        ExportFile(fname, text)
        pr("wrote " .. fname .. " to your WoW\\imports\\ folder (also in AutoRotaDumpDB).")
    else
        pr("ExportFile not found (need SuperWoW). Saved to AutoRotaDumpDB - open " ..
            "SavedVariables\\AutoRotaDump.lua after /reload.", 1, 0.8, 0.3)
    end
end

local function header(what)
    local _, class = UnitClass("player")
    return "# AutoRotaDump: " .. what .. "\n"
        .. "# locale=" .. (GetLocale and GetLocale() or "?")
        .. "  class=" .. (class or "?")
        .. "  level=" .. (UnitLevel and UnitLevel("player") or "?")
        .. "  SuperWoW=" .. (SUPERWOW_VERSION or "no") .. "\n"
end

-- ---------- talents ----------
local function dumpTalents()
    local tabs = GetNumTalentTabs and GetNumTalentTabs() or 0
    if tabs == 0 then pr("no talent API available.", 1, 0.5, 0.3); return end
    local lines = { header("talents"), "# tab\tindex\tname\trank/max\ticon" }
    for tab = 1, tabs do
        local tabName = GetTalentTabInfo and GetTalentTabInfo(tab) or ("Tab " .. tab)
        table.insert(lines, "## " .. tab .. " - " .. (tabName or ("Tab " .. tab)))
        local n = GetNumTalents(tab)
        for i = 1, n do
            local name, icon, _, _, rank, maxr = GetTalentInfo(tab, i)
            if name then
                table.insert(lines, tab .. "\t" .. i .. "\t" .. name .. "\t" ..
                    (rank or 0) .. "/" .. (maxr or 0) .. "\t" .. (icon or ""))
            end
        end
    end
    emit("talents", "ARDump_Talents.txt", table.concat(lines, "\n"))
    pr("talent dump complete (" .. tabs .. " tabs).")
end

-- ---------- spellbook (your learned spells: name + rank) ----------
local function knownSpells()
    local out, i = {}, 1
    while true do
        local name, rank = GetSpellName(i, "spell")
        if not name then break end
        table.insert(out, { name = name, rank = rank or "" })
        i = i + 1
    end
    return out
end

-- ---------- spell database scan (batched) ----------
local scan = nil

local function finishSpellScan()
    -- full database, sorted by id
    local ids = {}
    for id in pairs(scan.db) do table.insert(ids, id) end
    table.sort(ids)
    local lines = {
        header("spell database"),
        "# total spells found: " .. scan.n,
        "# id\tname\trank\tminRange\tmaxRange\ticon",
    }
    for _, id in ipairs(ids) do
        local s = scan.db[id]
        table.insert(lines, id .. "\t" .. s.name .. "\t" .. s.rank .. "\t" ..
            s.minR .. "\t" .. s.maxR .. "\t" .. s.tex)
    end
    emit("spelldb", "ARDump_SpellDB.txt", table.concat(lines, "\n"))

    -- your spellbook, each entry resolved to an id via name|rank
    local known = knownSpells()
    local k = { header("known spells (your spellbook, resolved to ids)"), "# name\trank\tid" }
    local unresolved = 0
    for _, e in ipairs(known) do
        local id = scan.byKey[e.name .. "|" .. e.rank]
        if not id then
            -- fall back to a name-only match (ignores rank) if the exact key missed
            id = scan.byName[e.name]
            if not id then unresolved = unresolved + 1 end
        end
        table.insert(k, e.name .. "\t" .. e.rank .. "\t" .. (id or "?"))
    end
    emit("known", "ARDump_Known.txt", table.concat(k, "\n"))

    pr("spell scan done: " .. scan.n .. " spells in db, " .. table.getn(known) ..
        " known (" .. unresolved .. " unresolved).")
end

local function startSpellScan(maxid)
    if not SpellInfo then pr("SpellInfo not found - needs SuperWoW.", 1, 0.5, 0.3); return end
    if scan then pr("a scan is already running (" .. scan.id .. "/" .. scan.max .. ").", 1, 0.8, 0.3); return end
    scan = { id = 1, max = maxid or MAXID, db = {}, byKey = {}, byName = {}, n = 0 }
    pr("scanning spell ids 1.." .. scan.max .. " ... a few seconds, you can keep playing.")
    f:Show()
end

f:SetScript("OnUpdate", function()
    if not scan then f:Hide(); return end
    local stop = scan.id + CHUNK
    if stop > scan.max then stop = scan.max end
    while scan.id <= stop do
        local id = scan.id
        local ok, name, rank, tex, minR, maxR = pcall(SpellInfo, id)
        if ok and name and name ~= "" then
            scan.n = scan.n + 1
            scan.db[id] = { name = name, rank = rank or "", tex = tex or "",
                            minR = minR or 0, maxR = maxR or 0 }
            scan.byKey[name .. "|" .. (rank or "")] = id
            if not scan.byName[name] then scan.byName[name] = id end
        end
        scan.id = scan.id + 1
    end
    if scan.id > scan.max then
        finishSpellScan()
        scan = nil
        f:Hide()
    end
end)

-- ---------- live buffs / debuffs (with ids) ----------
local function dumpBuffs()
    if not GetPlayerBuff then pr("GetPlayerBuff not available.", 1, 0.5, 0.3); return end
    local lines = { header("player auras"), "# kind\tslot\tid\tname\tstacks" }
    pr("--- your buffs (slot / id / name) ---")
    local function scanFilter(filter, label)
        for i = 0, 31 do
            local ix = GetPlayerBuff(i, filter)
            if ix and ix ~= -1 then
                local id = GetPlayerBuffID and fixId(GetPlayerBuffID(ix))
                local nm = (id and SpellInfo) and SpellInfo(id) or "?"
                local st = (GetPlayerBuffApplications and GetPlayerBuffApplications(ix)) or 1
                table.insert(lines, label .. "\t" .. i .. "\t" .. (id or "?") .. "\t" .. (nm or "?") .. "\t" .. st)
                pr("  " .. label .. " [" .. i .. "] " .. (id or "?") .. "  " .. (nm or "?"))
            end
        end
    end
    scanFilter("HELPFUL", "buff")
    scanFilter("HARMFUL", "self-debuff")
    emit("buffs", "ARDump_Buffs.txt", table.concat(lines, "\n"))
end

local function dumpDebuffs()
    if not UnitExists("target") then pr("no target - select a mob with debuffs first.", 1, 0.8, 0.3); return end
    local lines = { header("target debuffs"), "# slot\tid\tname\tstacks\ttexture" }
    pr("--- target debuffs (slot / id / name) ---")
    local any = false
    for i = 1, 40 do
        local tex, stacks, d3, d4, d5 = UnitDebuff("target", i)
        if not tex then break end
        any = true
        local id
        if type(d3) == "number" then id = d3
        elseif type(d4) == "number" then id = d4
        elseif type(d5) == "number" then id = d5 end
        id = fixId(id)
        local nm = (id and SpellInfo) and SpellInfo(id) or "?"
        table.insert(lines, i .. "\t" .. (id or "?") .. "\t" .. (nm or "?") .. "\t" .. (stacks or 0) .. "\t" .. tex)
        pr("  [" .. i .. "] " .. (id or "?") .. "  " .. (nm or "?") .. "  x" .. (stacks or 0))
    end
    if not any then pr("  (target has no debuffs)"); return end
    emit("debuffs", "ARDump_Debuffs.txt", table.concat(lines, "\n"))
end

-- ---------- slash command ----------
SLASH_ARDUMP1 = "/ardump"
SLASH_ARDUMP2 = "/spelldump"
SlashCmdList["ARDUMP"] = function(msg)
    local a = string.lower(msg or "")
    -- first word + optional trailing number, without string.match (not in 5.0)
    local _, _, word, num = string.find(a, "^(%a*)%s*(%d*)")
    word = word or ""
    if word == "spells" or word == "" then
        startSpellScan(tonumber(num))
    elseif word == "talents" then
        dumpTalents()
    elseif word == "buffs" then
        dumpBuffs()
    elseif word == "debuffs" then
        dumpDebuffs()
    elseif word == "all" then
        dumpTalents()
        startSpellScan(tonumber(num))
    else
        pr("commands: /ardump spells [maxid] | talents | buffs | debuffs | all")
    end
end

DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffAutoRota Data Dumper|r loaded. Type /ardump for commands.", 0.6, 1, 0.6)
