local bol = RegisterMod("The Binding of Lucia", 1)
local game = Game()
local MAX_TEAR = 5

local BOLItemId = {
    RNAIL = Isaac.GetItemIdByName("Roofing Nail")
}

local BOLHasItem = {
    RNail = false
}

local BOLItemBonus = {
    RNAIL_DMG = 0.5,
    RNAIL_LCK = 1
}

-- EID Descriptions
if EID then 
    EID:addCollectible(BOLItemId.RNAIL, "↑ +0.5 Damage#↑ +1 Luck")
end

-- Updates inventory
local function BOLUpdateItems(player) 
    BOLHasItem.RNail = player:HasCollectible(BOLItemId.RNAIL)
end

-- When run starts / continues
function bol:onPlayerInit(player)
    BOLUpdateItems(player)
end

bol:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, bol.onPlayerInit)


function bol:onCache(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_DAMAGE then 
        if player:HasCollectible(BOLItemId.RNAIL) then
            player.Damage = player.Damage + BOLItemBonus.RNAIL_DMG
        end

    if cacheFlag == CacheFlag.CACHE_LUCK then
        if player:HasCollectible(BOLItemId.RNAIL) then
            player.Luck = player.Luck + BOLItemBonus.RNAIL_LCK
        end
    end
end

bol:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, bol.onCache)

-- Updates passive effects
function bol:onUpdate(player)

    BOLUpdateItems(player)
end

bol:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, bol.onUpdate)