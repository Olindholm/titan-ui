--
-- Minimap Script
-- @Auther Wiggy boy
--
require("/ui/base.lua")

local interface = object
local interfaceName = interface:GetName()

--
-- Minimap ( Left / Right )
--

local function ShowCorrectMinimap()
    interface:GetWidget('minimap_panel_' .. GetSide()):SetVisible(true)
    interface:GetWidget('minimap_panel_' .. GetOppositeSide()):SetVisible(false)
end
interface:RegisterWatch('MiniMapPosition', ShowCorrectMinimap)

--
-- Minimap Effects (Pings)
--

local function GetPingLimit()
    if GetCvarBool("ui_unlimitedPings") then
        return 1000 -- "unlimited"
    end

    return 3
end

local pingCooldown = 5000 -- ms
local mapEffects = {}
local showChatMutedPlayersPings = false
local showVoiceMutedPlayersPings = false

local function ShowMinimapPing(effect, x, y, color)
    local minimap = 'minimap_' .. GetSide()
    local pingEffectCmd =   "StartEffect('" .. effect .. "', " ..
                                "GetMinimapDrawX('" .. minimap .. "', '" .. x .. "') / GetScreenWidth(), " ..
                                "GetMinimapDrawY('" .. minimap .. "', 1.0 - " .. y .. ") / GetScreenHeight(), " ..
                                "'" .. color .. "', " ..
                                "GetMinimapDrawX('" .. minimap .. "', '" .. x .. "') / GetScreenWidth(), " ..
                                "GetMinimapDrawY('" .. minimap .. "', 1.0 - " .. y .. ") / GetScreenHeight()" ..
                            ")"

    interface:GetWidget('effect_panel'):UICmd(pingEffectCmd)
end

local function MapEffect(sourceWidget, effect, x, y, color, playerName, param5, param6, playerIsChatMuted)
	mapEffects[color] = mapEffects[color] or { numPings = 0, hostTime = 0 }

    playerIsChatMuted = AtoB(playerIsChatMuted) -- Convert from str to bool
    playerIsVoiceMuted = IsPlayerVoiceMuted(playerName)

    -- Determine whether or not to show the ping
    -- depending on whether the player is muted or not
    showMinimapPing = (showChatMutedPlayersPings or not playerIsChatMuted) and
                     (showVoiceMutedPlayersPings or not playerIsVoiceMuted)

	-- Proceed with regular map ping logic if the player is not ignored and if the player is not muted
    local time = HostTime()

    -- If ping cooldown is over, reset numPings
    if ( (time - mapEffects[color].hostTime) > pingCooldown) then
        mapEffects[color].numPings = 0
    end

    -- If limit not reached, ping!
    if (mapEffects[color].numPings < GetPingLimit()) then
	    if (showMinimapPing) then ShowMinimapPing(effect, x, y, color) end

        mapEffects[color].hostTime = time
        mapEffects[color].numPings = mapEffects[color].numPings + 1
    end
end
interface:RegisterWatch('MapEffect', MapEffect)

-- This must be placed at the end to
-- be able to "use" all functions.
-- It must also be global (aka not local)
Minimap = {}
function Minimap:Init()
    ShowCorrectMinimap()
end
