local bol = RegisterMod("The Binding of Lucia", 1)
local game = Game()
local MAX_TEAR = 5

local BOLItemId = {
    RNAIL = Isaac.GetItemIdByName("Roofing Nail"),
    WINNING_STREAK = Isaac.GetItemIdByName("Winning Streak")
}

local BOLHasItem = {
    RNail = false,
    winningStreak = false
}

local BOLItemBonus = {
    RNAIL_DMG = 0.5,
    RNAIL_LCK = 1,
    WIN_STREAK_DMG = {
        0.25,
        0.5,
        0.75,
        1,
        1.25,
        1.5,
        1.75,
        2,
        2.25,
        2.5,
        2.75,
        3
    }
}

-- EID Descriptions
if EID then 
    EID:addCollectible(BOLItemId.RNAIL, "↑ +0.5 Damage#↑ +1 Luck")
    EID:addCollectible(BOLItemId.WINNING_STREAK, "↑ +0.5 Damage per point of luck#!!! Cap at +12 luck")
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