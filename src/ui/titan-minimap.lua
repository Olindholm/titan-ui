local interface = object
local interfaceName = interface:GetName()

local function GetSide()
    if GetCvarBool('ui_minimap_rightside') then
        return 'right'
    else
        return 'left'
    end
end

local function GetOppositeSide()
    if not GetCvarBool('ui_minimap_rightside') then
        return 'right'
    else
        return 'left'
    end
end

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

local pingLimit = 3
local pingCooldown = 5000 -- ms
local mapEffect = {}

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
	local effect_panel = interface:GetWidget('effect_panel')
	mapEffect[color] = mapEffect[color] or {}

	local clientNum = -1
	local is_player_muted = false
	local player_name = StripClanTag(source)

    println(Game.sourceToClient)
	if (Game.sourceToClient) and (Game.sourceToClient[player_name]) then
		clientNum = Game.sourceToClient[player_name]
	end

	if clientNum ~= -1 then
		is_player_muted = AtoB(UIManager.GetActiveInterface():UICmd([[IsVoiceMuted(']] .. clientNum .. [[')]]))
	end

	-- Proceed with regular map ping logic if the player is not ignored and if the player is not muted
	if (param7 == "false" and is_player_muted == false) then
		if (not mapEffect[color].hostTime) or (not mapEffect[color].numPings) or ( (HostTime() - mapEffect[color].hostTime) > pingCooldown) then
			mapEffect[color].numPings = 1
            ShowMinimapPing(effect, x, y, color)
            mapEffect[color].hostTime = HostTime()
		elseif	((mapEffect[color].numPings < pingLimit) or GetCvarBool("ui_unlimitedPings")) then
            ShowMinimapPing(effect, x, y, color)
			mapEffect[color].numPings = mapEffect[color].numPings + 1
            mapEffect[color].hostTime = HostTime()
		end
	end

    println(mapEffect[color].numPings)
end
interface:RegisterWatch('MapEffect', MapEffect)

-- This must be placed at the end to
-- be able to "use" all functions.
-- It must also be global (aka not local)
function Init()
    ShowCorrectMinimap()
end
