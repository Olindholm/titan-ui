--
-- Minimap Script
-- @Auther Wiggy boy
--
local interface = object
local interfaceName = interface:GetName()

local function UnloadShop(shopInterface)
    if (shopInterface ~= nil) then
        UIManager.UnloadInterface(shopInterface)
    end
end

local function LoadShop(shopInterface)
    UIManager.LoadInterface(shopInterface)
    UIManager.AddOverlayInterface('game_shop_v3')
end

local shopInterface = nil

local function ReloadShop()
    UnloadShop(shopInterface)
    shopInterface = GetCvarString("shop_interface")
    LoadShop(shopInterface)
end
interface:RegisterWatch('ShopInterface', ReloadShop)

-- This must be placed at the end to
-- be able to "use" all functions.
-- It must also be global (aka not local)
Shop = {}
function Shop:Init()
    ReloadShop()
end
