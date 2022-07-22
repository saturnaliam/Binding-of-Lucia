local bol = RegisterMod("The Binding of Lucia", 1)
local game = Game()
local MAX_TEAR = 5

Card.CARD_TSUN = Isaac.GetCardIdByName("TTheSun")
Card.CARD_THIER = Isaac.GetCardIdByName("THierophant")
local newCardChance = 1
local newCardChance = 0.05
local cardCooldown = 0

local BOLItemId = {
    RNAIL = Isaac.GetItemIdByName("Roofing Nail"),
    WINNING_STREAK = Isaac.GetItemIdByName("Winning Streak"),

    LENS_OF_TRUTH = Isaac.GetTrinketIdByName("Lens of Truth"),
    LED = Isaac.GetTrinketIdByName("LED"),
    EKG = Isaac.GetTrinketIdByName("EKG")
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

local SlowRoll = {
    ID = Isaac.GetPillEffectByName("Slow Roll!"),
    TEAR_MULT_DWN = 0.2,
    DMG_MULT_UP = 25,
    SHTSPD_MULT_UP = 0.2,
    collected = false
}

SoyBean.Color = Isaac.AddPillEffectToPool(SoyBean.ID)
SlowRoll.Color = Isaac.AddPillEffectToPool(SlowRoll.ID)

-- EID Descriptions
if EID then 
    EID:addCollectible(BOLItemId.RNAIL, "↑ +0.5 Damage#↑ +1 Luck")
    EID:addCollectible(BOLItemId.WINNING_STREAK, "↑ +0.5 Damage per point of luck#!!! Cap at +12 luck")

    EID:addPill(SoyBean.ID, "{{Collectible330}} Soy Milk effect for one room#↑ x5.5 Tears rate#↓ 0.2x Damage#")
    EID:addPill(SlowRoll.ID, "↑ x25 Damage#↓ x0.2 Tears#↓ 0.2x Shot Speed#")

    EID:addCard(Card.CARD_TSUN, "Burns every enemy in the current room", "XIX - The Torn Sun")
    EID:addCard(Card.CARD_THIER, "Spawns 3 black hearts", "V - The Torn Hierophant")

    EID:addTrinket(BOLItemId.LED, "{{CurseDarkness}} Removes Curse of Darkness", "LED")
    EID:addTrinket(BOLItemId.LENS_OF_TRUTH, "{{CurseBlind}} Removes Curse of the Blind", "Lens of Truth")
    EID:addTrinket(BOLItemId.EKG, "{{CurseUnknown}} Removes Curse of the Blind", "EKG")
end

function bol:onPostUpdate(player)
    for _, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_TAROTCARD then
            local data = entity:GetData()
            local sprite = entity:GetSprite()

            if sprite:IsPlaying("Collect") and data.Picked == nil then
                data.Picked = true
                cardCooldown = 30
            end

            if Input.IsActionPressed(ButtonAction.ACTION_DROP, 0) and Input.IsActionPressed(ButtonAction.ACTION_DROP, 1) then
                cardCooldown = 30
            end

            if data.Init == nil then
                data.Init = (cardCooldown == 0)

                if data.Init then
                    for _, buddy in pairs(Isaac.GetRoomEntities()) do
                        if buddy.Type == entity.Type and buddy.Variant == entity.Variant and buddy.SubType == entity.SubType and buddy.Position.X ~= entity.Position.X and buddy.Position.Y ~= entity.Position.Y then
                            data.Init = false
                        end
                    end
                end

                if data.Init then
                    local roll = entity:GetDropRNG():RandomFloat() 
                        if roll < newCardChance then 
                            entity.SubType = Card.CARD_THIER
                    end
                end
            end
        end
    end
    cardCooldown = math.max(0, cardCooldown - 1)
end

bol:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, bol.onPostUpdate)

function bol:onCache(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_DAMAGE then 
        if player:HasCollectible(BOLItemId.RNAIL) then
            player.Damage = player.Damage + BOLItemBonus.RNAIL_DMG
        end

       if player:HasCollectible(BOLItemId.WINNING_STREAK) then
            local wsLuck = player.Luck

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

        if SlowRoll.collected then
            player.Damage = player.Damage * SlowRoll.DMG_MULT_UP
        end
    end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        if SoyBean.collected then
            local BFR = 30 / (player.MaxFireDelay + 1)
            BFR = BFR * SoyBean.BONUS_TEAR_MULT
            NFD = (30 - BFR) / BFR
            DFD = player.MaxFireDelay - NFD
            player.MaxFireDelay = player.MaxFireDelay - DFD
        end

        if SlowRoll.collected then
            local BFR = 30 / (player.MaxFireDelay + 1)
            BFR = BFR * SlowRoll.TEAR_MULT_DWN
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

    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        if SlowRoll.collected then
            player.ShotSpeed = player.ShotSpeed * SlowRoll.SHTSPD_MULT_UP
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

    if SlowRoll.Room ~= nil and game:GetLevel():GetCurrentRoomIndex() ~= SlowRoll.Room then
        SlowRoll.Room = nil
        SlowRoll.collected = false
    end

    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()

    if player:GetTrinket(0) == BOLItemId.LENS_OF_TRUTH or player:GetTrinket(1) == BOLItemId.LENS_OF_TRUTH then
        game:GetLevel():RemoveCurses(LevelCurse.CURSE_OF_BLIND)
    end

    if player:GetTrinket(0) == BOLItemId.LED or player:GetTrinket(1) == BOLItemId.LED then
        game:GetLevel():RemoveCurses(LevelCurse.CURSE_OF_DARKNESS)
    end

    if player:GetTrinket(0) == BOLItemId.EKG or player:GetTrinket(1) == BOLItemId.EKG then
        game:GetLevel():RemoveCurses(LevelCurse.CURSE_OF_THE_UNKNOWN)
    end
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

function SlowRoll.Proc(_PillEffect) 
    local player = game:GetPlayer(0)
    SlowRoll.OldDmg = player.Damage
    SlowRoll.OldTear = player.MaxFireDelay
    SlowRoll.OldSS = player.ShotSpeed
    SlowRoll.Room = game:GetLevel():GetCurrentRoomIndex()
    SlowRoll.collected = true
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
end

bol:AddCallback(ModCallbacks.MC_USE_PILL, SlowRoll.Proc, SlowRoll.ID)

function useTSun(...)
    local player = game:GetPlayer(0)

    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:IsVulnerableEnemy() then 
            entity:AddBurn(EntityRef(player), 100, 3.5)
        end
    end
end

bol:AddCallback(ModCallbacks.MC_USE_CARD, useTSun, Card.CARD_TSUN)

function useTHier(...)
    local player = game:GetPlayer(0)

    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 6, Vector(player.Position.X + 35, player.Position.Y), Vector(0, 0), player)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 6, Vector(player.Position.X - 35, player.Position.Y), Vector(0, 0), player)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 6, Vector(player.Position.X, player.Position.Y - 35), Vector(0, 0), player)
end

bol:AddCallback(ModCallbacks.MC_USE_CARD, useTHier, Card.CARD_THIER)
