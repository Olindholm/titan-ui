local interface = object
local interfaceName = interface:GetName()

-- Health
local function ActiveHealth1324(sourceWidget, health, maxHealth, healthPercent, healthShadow)
    println('titan-minimap: health = ' .. health )
end
interface:RegisterWatch('ActiveHealth', ActiveHealth1324)

----------------------------------------------------------
-- 					Bottom Section						--
----------------------------------------------------------
local mini_map_right = nil

local function PositionBottomSection()
    mini_map_right = interface:GetWidget('mini_map_right')

    if (not GetCvarBool('ui_minimap_rightside')) then		-- Minimap on left
        interface:GetWidget('mini_map_right'):SetVisible(false)
        interface:GetWidget('mini_map_left'):SetVisible(true)
    else
        interface:GetWidget('mini_map_right'):SetVisible(true)
        interface:GetWidget('mini_map_left'):SetVisible(false)
    end
end
interface:RegisterWatch('MiniMapPosition', PositionBottomSection)

Game.mapEffect = {}
local function MapEffect(sourceWidget, param0, param1, param2, param3, param4, param5, param6, param7)
	local effect_panel = interface:GetWidget('effect_panel')
	Game.mapEffect[param3] = Game.mapEffect[param3] or {}

	local function DoPing()
		if interface:GetWidget('minimap'):IsVisible() then
			effect_panel:UICmd([[StartEffect(']]..param0..[[', GetMinimapDrawX('minimap', ']]..param1..[[') 			/ GetScreenWidth(), 	GetMinimapDrawY('minimap', 1.0 - ]]..param2..[[) 			/ GetScreenHeight(), ']]..param3..[[', GetMinimapDrawX('minimap', ']]..param5..[[') 			/ GetScreenWidth(), 	GetMinimapDrawY('minimap', 1.0 - ]]..param6..[[) 			/ GetScreenHeight())]])
		else
			effect_panel:UICmd([[StartEffect(']]..param0..[[', GetMinimapDrawX('minimap_altview', ']]..param1..[[') 	/ GetScreenWidth(), 	GetMinimapDrawY('minimap_altview', 1.0 - ]]..param2..[[) 	/ GetScreenHeight(), ']]..param3..[[', GetMinimapDrawX('minimap_altview', ']]..param5..[[') 	/ GetScreenWidth(), 	GetMinimapDrawY('minimap_altview', 1.0 - ]]..param6..[[) 	/ GetScreenHeight())]])
		end
		Game.mapEffect[param3].hostTime = HostTime()
	end

	local clientNum = -1
	local is_player_muted = false
	local player_name = StripClanTag(param4)

	if (Game.playerNameToClient) and (Game.playerNameToClient[player_name]) then
		clientNum = Game.playerNameToClient[player_name]
	end

	if clientNum ~= -1 then
		is_player_muted = AtoB(UIManager.GetActiveInterface():UICmd([[IsVoiceMuted(']] .. clientNum .. [[')]]))
	end

	-- Proceed with regular map ping logic if the player is not ignored and if the player is not muted
	if (param7 == "false" and is_player_muted == false) then
		if (not Game.mapEffect[param3].hostTime) or (not Game.mapEffect[param3].numPings) or ( (HostTime() - Game.mapEffect[param3].hostTime) > 5000) then
			Game.mapEffect[param3].numPings = 1
			DoPing()
		elseif	((Game.mapEffect[param3].numPings < 3) or GetCvarBool("ui_unlimitedPings")) then
			DoPing()
			Game.mapEffect[param3].numPings = Game.mapEffect[param3].numPings + 1
		end
	end
end
interface:RegisterWatch('MapEffect', MapEffect)

function Init()
    PositionBottomSection()
end
