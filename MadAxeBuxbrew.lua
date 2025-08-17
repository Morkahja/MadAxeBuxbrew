-- MadAxeBuxbrew (Per-Character) v2.6.0  — Turtle/1.12, Lua 5.0-safe

-------------------------------------------------
-- Emotes
-------------------------------------------------
local EMOTES = {
  "lets out a savage roar.",
  "howls like a beast unchained.",
  "beats her chest with her weapon hilt.",
  "laughs like a berserker as the scent of blood fills the air.",
  "raises her weapon high.",
  "growls a deep war-chant.",
  "roars a brutal challenge.",
  "stomps the ground.",
  "howls skyward.",
  "stomps in rhythm.",
  "bellows to the wind.",
  "pounds her chest with both fists.",
  "throws her head back and howls.",
  "radiates unshakable fury.",
  "swings her weapon in a wide arc.",
  "lets her weapon hum with fury.",
  "bangs her weapon on iron plates.",
  "spins her weapon with one hand, letting the wind scream through it.",
  "taps her weapon against her thigh like a war drum.",
  "raises her weapon with a grunt, rallying for the first strike.",
  "snaps her weapon into both hands, grinning ear to ear.",
  "throws her weapon up, catches it mid-spin, and laughs.",
  "leans into her weapon with a low growl, daring anyone to charge.",
  "slashes the air in front of her, then roars with glee.",
  "holds her weapon to her heart, then slams it down at her feet.",
  "scrapes her weapon across her armor, sparks flying before the storm.",
  "kicks over a chair and snarls like she's starting a bar fight.",
  "wipes ale foam from her mouth and grins.",
  "clinks two mugs together till they shatter.",
  "lifts her mug high, catching the torchlight in her grin.",
  "laughs as she lights a fuse with her cigar.",
  "slams a keg tap open as she lets out a war cry.",
  "grins wide as the fuse burns on her powder keg.",
  "stands in the ale haze, laughing as the fight starts.",
  "slams a keg down hard enough to make the tables jump.",
  "kicks a keg downhill and grins as it bursts open.",
  "juggles three mugs before throwing one in someone's face.",
  "lets her powder horn puff smoke as she laughs.",
  "slaps a bar tab down and walks away laughing.",
  "slams her mug down and charges.",
  "strikes flint on her mug handle before charging.",
  "kicks over a keg and grins as it spills.",
  "slams her boots on the table, the tavern roars.",
  "flares with rage, mugs start to slam.",
  "unleashes a roar that rattles every mug in the room.",
  "lets her laugh tear through the tavern like a warhorn.",
  "brims with fury so thick the air smells like spilled ale.",
  "lets her presence fire up every drunk in the hall.",
  "stands tall on the table, every brawler swings harder.",
  "raises her mug, the room drowns in cheers.",
  "howls so loud it makes mugs jump off tables.",
  "stomps the floorboards till dust falls from the rafters.",
  "channels her rage, the whole tavern roars with her.",
  "beats her chest as every mug nearby sloshes harder.",
  "unleashes such fury that even the calm start screaming.",
  "drives her will into the air and the air answers.",
  "steps forward, the front line surges with strength.",
  "tenses her muscles, as everyone tightens their grip.",
  "calls the storm through her veins.",
  "lets her fury flow, as even the earth seems ready to strike.",
  "erupts with presence and all hesitation burns away.",
  "ignites a fire so fierce it spreads through every heart.",
  "lashes the spirit of war into her kin with one brutal shout.",
}

-------------------------------------------------
-- State
-------------------------------------------------
local WATCH_SLOT = nil
local WATCH_MODE = false
local LAST_EMOTE_TIME = 0
local EMOTE_COOLDOWN = 90

-------------------------------------------------
-- Helpers
-------------------------------------------------
local function chat(t)
  if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffff8800MAE:|r " .. t) end
end

-- Per-character DB key lives in a brand-new file: MadAxeBuxbrewPC.lua
local function ensureDB()
  if type(MadAxeBuxbrewPCDB) ~= "table" then MadAxeBuxbrewPCDB = {} end
  return MadAxeBuxbrewPCDB
end

-- Lazy load once (handles weird event orders)
local _loaded_once = false
local function ensureLoaded()
  if not _loaded_once then
    local db = ensureDB()
    if WATCH_SLOT == nil then WATCH_SLOT = db.slot or nil end
    _loaded_once = true
  end
end

local function tlen(t) if t and table.getn then return table.getn(t) end return 0 end
local function pick(t) local n=tlen(t); if n<1 then return nil end; return t[math.random(1,n)] end

local function doEmoteNow()
  local now = GetTime()
  if now - LAST_EMOTE_TIME < EMOTE_COOLDOWN then return end
  LAST_EMOTE_TIME = now
  local e = pick(EMOTES)
  if e then SendChatMessage(e, "EMOTE") end
end

-------------------------------------------------
-- Hook UseAction (1.12)
-------------------------------------------------
local _Orig_UseAction = UseAction
function UseAction(slot, checkCursor, onSelf)
  ensureLoaded()
  if WATCH_MODE then chat("pressed slot " .. tostring(slot)) end
  if WATCH_SLOT and slot == WATCH_SLOT then doEmoteNow() end
  return _Orig_UseAction(slot, checkCursor, onSelf)
end

-------------------------------------------------
-- Slash Commands (use /maepc; no string methods with :)
-------------------------------------------------
SLASH_MADAXEBUXBREWPC1 = "/maepc"
SlashCmdList["MADAXEBUXBREWPC"] = function(raw)
  ensureLoaded()
  local s = raw or ""
  s = string.gsub(s, "^%s+", "")
  local cmd, rest = string.match(s, "^(%S+)%s*(.-)$")

  if cmd == "slot" then
    local n = tonumber(rest)
    if n then
      WATCH_SLOT = n
      ensureDB().slot = n
      chat("watching action slot " .. n .. " (saved in memory; /reload to write file)")
    else
      chat("usage: /maepc slot <number>")
    end

  elseif cmd == "watch" then
    WATCH_MODE = not WATCH_MODE
    chat("watch mode " .. (WATCH_MODE and "ON" or "OFF"))

  elseif cmd == "emote" then
    doEmoteNow()

  elseif cmd == "info" then
    chat("watching slot: " .. (WATCH_SLOT and tostring(WATCH_SLOT) or "none"))
    chat("cooldown: " .. EMOTE_COOLDOWN .. "s")

  elseif cmd == "timer" then
    local remain = EMOTE_COOLDOWN - (GetTime() - LAST_EMOTE_TIME)
    if remain < 0 then remain = 0 end
    chat("time left: " .. string.format("%.1f", remain) .. "s")

  elseif cmd == "reset" then
    WATCH_SLOT = nil
    ensureDB().slot = nil
    chat("cleared saved slot (/reload to flush file)")

  elseif cmd == "save" then
    ensureDB().slot = WATCH_SLOT
    chat("saved to memory; /reload to write file")

  elseif cmd == "debug" then
    local t = type(MadAxeBuxbrewPCDB)
    local v = (t == "table") and tostring(MadAxeBuxbrewPCDB.slot or "nil") or "n/a"
    chat("DB="..t.." | SV slot="..v.." | WATCH_SLOT="..tostring(WATCH_SLOT))

  else
    chat("/maepc slot <n> | watch | emote | info | timer | reset | save | debug")
  end
end

-------------------------------------------------
-- Init / Save / RNG
-------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LOGOUT")

f:SetScript("OnEvent", function(_, event)
  if event == "VARIABLES_LOADED" or event == "PLAYER_ENTERING_WORLD" then
    ensureLoaded()
    if WATCH_SLOT ~= nil then chat("loaded slot " .. tostring(WATCH_SLOT)) else chat("no saved slot found") end

  elseif event == "PLAYER_LOGIN" then
    math.randomseed(math.floor(GetTime()*1000)); math.random()

  elseif event == "PLAYER_LOGOUT" then
    ensureLoaded()
    if WATCH_SLOT ~= nil then
      ensureDB().slot = WATCH_SLOT
      chat("writing slot " .. tostring(WATCH_SLOT) .. " to file...")
    else
      chat("no slot set; leaving file unchanged")
    end
  end
end)
