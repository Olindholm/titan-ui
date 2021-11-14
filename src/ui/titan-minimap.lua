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

local function MapEffect(sourceWidget, effect, x, y, color, source, param5, param6, param7)
	mapEffects[color] = mapEffects[color] or { numPings = 0, hostTime = 0 }

	local clientNum = -1
	local is_player_muted = false
	local player_name = StripClanTag(source)

	if (Game.playerNameToClient) and (Game.playerNameToClient[player_name]) then
		clientNum = Game.playerNameToClient[player_name]
	end

	if clientNum ~= -1 then
		is_player_muted = AtoB(UIManager.GetActiveInterface():UICmd([[IsVoiceMuted(']] .. clientNum .. [[')]]))
	end

	-- Proceed with regular map ping logic if the player is not ignored and if the player is not muted
    local time = HostTime()
	if (param7 == "false" and is_player_muted == false) then

        -- If ping cooldown is over, reset numPings
        if ( (time - mapEffects[color].hostTime) > pingCooldown) then
			mapEffects[color].numPings = 0
        end

        -- If limit not reached, ping!
        if (mapEffects[color].numPings < GetPingLimit()) then
            ShowMinimapPing(effect, x, y, color)

            mapEffects[color].hostTime = HostTime()
            mapEffects[color].numPings = mapEffects[color].numPings + 1
        end
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
