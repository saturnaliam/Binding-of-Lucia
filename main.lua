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

function bol:onCache(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_DAMAGE then 
        if player:HasCollectible(BOLItemId.RNAIL) then
            player.Damage = player.Damage + BOLItemBonus.RNAIL_DMG
        end

       if player:HasCollectible(BOLItemId.WINNING_STREAK) then
                wsLuck = player.Luck

                if wsLuck >= 1 then
                    if wsLuck >= 12 then
                        wsLuck = 12
                    end

                    player.Damage = player.Damage + BOLItemBonus.WIN_STREAK_DMG[math.floor(wsLuck)]
                end
            end
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
    if game:GetFrameCount() == 1 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, BOLItemId.WINNING_STREAK, Vector(320,280), Vector(0,0), nil)
    end
    
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
end

bol:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, bol.onUpdate)