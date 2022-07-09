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

local SoyBean = {
    ID = Isaac.GetPillEffectByName("Soy Bean!"),
    BONUS_TEAR_MULT = 5.5,
    NEG_DMG_MULT = 0.2,
    collected = false
}

SoyBean.Color = Isaac.AddPillEffectToPool(SoyBean.ID)

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

        if SoyBean.collected then 
            player.Damage = player.Damage * SoyBean.NEG_DMG_MULT
        end
    end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        if SoyBean.collected then
            local BFR = 30 / (player.MaxFireDelay + 1)
            print(BFR)
            BFR = BFR * SoyBean.BONUS_TEAR_MULT
            print(BFR)
            NFD = (30 - BFR) / BFR
            DFD = player.MaxFireDelay - NFD
            player.MaxFireDelay = player.MaxFireDelay - DFD
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

    end
    
    if SoyBean.Room ~= nil and game:GetLevel():GetCurrentRoomIndex() ~= SoyBean.Room then
        SoyBean.Room = nil
        SoyBean.collected = false
    end

    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
end

bol:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, bol.onUpdate)

function SoyBean.Proc(_PillEffect) 
    local player = game:GetPlayer(0)
    SoyBean.OldDmg = player.Damage
    SoyBean.OldTear = player.MaxFireDelay
    SoyBean.Room = game:GetLevel():GetCurrentRoomIndex()
    SoyBean.collected = true
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
end

bol:AddCallback(ModCallbacks.MC_USE_PILL, SoyBean.Proc, SoyBean.ID)