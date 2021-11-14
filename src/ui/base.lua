--
-- Base Script
-- @Auther Wiggy boy
--

if not UltimateTest then
    UltimateTest = {}

    function GetSide()
        if GetCvarBool('ui_minimap_rightside') then
            return 'right'
        else
            return 'left'
        end
    end

    function GetOppositeSide()
        if not GetCvarBool('ui_minimap_rightside') then
            return 'right'
        else
            return 'left'
        end
    end
end
