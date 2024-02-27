SoulShard = {
    Shards = {},
    ActiveShards = {},
    ActiveBonuses = {},
    clicked = nil,
    BinShown = false,
    ShardToFrame = {},
}

local iconsize = 40
function InitializeSoulShardWindow()
    ActiveShardWindow = CreateFrame("FRAME", "ActiveShardWindow", CharacterModelFrame);
    ActiveShardWindow:SetSize(CharacterModelFrame:GetWidth(), 40);
    ActiveShardWindow:SetPoint("BOTTOM", CharacterModelFrame, "BOTTOM", 0, 0);
    ActiveShardWindow:SetFrameLevel(1);
    ActiveShardWindow:SetFrameStrata("HIGH");
    local maxShards = 5
    local padding = (CharacterModelFrame:GetWidth()-(maxShards*iconsize))/maxShards;
    ActiveShardWindow.Shards = {}

    local baseX = padding/2
    for i = 1, maxShards, 1 do
        local iconFrame = CreateFrame("BUTTON", "iconFrame" .. i, ActiveShardWindow)
        iconFrame:SetHighlightTexture("Interface\\Buttons\\CheckButtonHilight")
        iconFrame:SetFrameLevel(ActiveShardWindow:GetFrameLevel() + 2)
        iconFrame:SetSize(iconsize, iconsize)

        iconFrame:SetPoint("TOPLEFT", baseX + padding * (i-1) + (i - 1) * iconsize, -padding)

        local texture = iconFrame:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints(iconFrame)
        texture:SetPoint("CENTER")

        local backdrop = {
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tileEdge = false,
            edgeSize = 2
        }
        iconFrame:SetBackdrop(backdrop);
        iconFrame:SetBackdropColor(0,0,0,1)
        RankToQualityColor(1, iconFrame)

        iconFrame:SetScript("OnClick", function() 
            SoulShard.clicked = i
            if not SoulShard.BinShown then
                SoulShard.BinShown = true
                ShardBin:Show()
            else
                ShardBin:Hide()
                SoulShard.BinShown = false
                SoulShard.clicked = nil
            end
        end)

        iconFrame.Texture = texture
        ActiveShardWindow.Shards[i] = iconFrame
    end

    ShardBin = CreateFrame("FRAME", "ShardBin", ActiveShardWindow)
    ShardBin:SetPoint("top", 0, -(ActiveShardWindow:GetHeight() + padding))
    ShardBin:SetSize(CharacterModelFrame:GetWidth(), CharacterModelFrame:GetHeight())
    ShardBin:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        insets = {top = 0, left = 0, bottom = 0, right = 0},
    });
    ShardBin:SetBackdropColor(0,0,0,.5)
    ShardBin:Hide()
    ShardBin.Shards = {}

    shardtt = CreateFrame("GameTooltip", "shardtt", UIParent, "GameTooltipTemplate");
    shardtt:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        insets = {top = 0, left = 0, bottom = 0, right = 0},
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1,
        tile = false,
    });
    shardtt:SetBackdropColor(0,0,0,.6)

    PushForgeMessage(ForgeTopic.GET_SOULSHARDS, "collection")
end

SubscribeToForgeTopic(ForgeTopic.ACTIVE_SOULSHARDS, function(msg)
    local listOfObjects = DeserializeMessage(DeserializerDefinitions.ACTIVE_SOULSHARDS, msg);
    for i, shard in ipairs(listOfObjects) do
        local s = SoulShard.Shards[tonumber(shard)]
        SoulShard.ActiveShards[i] = tonumber(shard)
        if s then
            local icon = GroupToIcon(tonumber(s.groups[1]))
            ActiveShardWindow.Shards[i]:SetBackdrop({
                bgFile = icon,
                insets = {top = -1, left = -1, bottom = -1, right = -1},
                edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
                tileEdge = false,
                edgeSize = 2
            })
            ActiveShardWindow.Shards[i]:SetBackdropBorderColor(RankToQualityColor(s.rank))

            SoulShard.ShardToFrame[s.source]:SetBackdropBorderColor(GetLockedColor())

            ActiveShardWindow.Shards[i]:SetScript("OnEnter", function() 
                shardtt:SetOwner(ActiveShardWindow.Shards[i], "ANCHOR_RIGHT", 0, 0)
                shardtt:SetBackdropBorderColor(RankToQualityColor(s.rank))
                shardtt:SetSize(200, 600)
                shardtt:AddDoubleLine(s.name, "Rank "..s.rank, RankToQualityColor(s.rank))
                for _, g in ipairs(s.groups) do
                    if g then
                        shardtt:AddLine(NameForGroup(tonumber(g)), RankToQualityColor(s.rank))
                        shardtt:AddLine(BonusForGroup(tonumber(g), s.rank), RankToQualityColor(s.rank))
                    end
                end
                shardtt:Show()
            end)

            ActiveShardWindow.Shards[i]:SetScript("OnLeave", function() 
                shardtt:ClearLines(0)
                shardtt:Hide()
            end)
        end
    end
    --print(dump(SoulShard.ActiveShards))
end);

SubscribeToForgeTopic(ForgeTopic.GET_SOULSHARDS, function(msg)
    local listOfObjects = DeserializeMessage(DeserializerDefinitions.GET_SOULSHARDS, msg);
    local shardCount = 1
    local maxShardsPerRow = 5
    local padding = (CharacterModelFrame:GetWidth()-(maxShardsPerRow*iconsize))/maxShardsPerRow
    local baseX = padding/2
    local row = 1
    local itt = 1

    for _, shard in ipairs(listOfObjects) do
        local icon = GroupToIcon(tonumber(shard.groups[1]))
        if itt > 5 then
            itt = 1
            row = row + 1
        end
        SoulShard.Shards[shard.source] = shard
        local shardFrame = CreateFrame("BUTTON", "shardIcon" .. shardCount, ShardBin)
        shardFrame:SetHighlightTexture("Interface\\Buttons\\CheckButtonHilight")
        shardFrame:SetFrameLevel(ActiveShardWindow:GetFrameLevel() + 2)
        shardFrame:SetSize(iconsize, iconsize)

        local backdrop = {
            bgFile = icon,
            insets = {top = -1, left = -1, bottom = -1, right = -1},
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tileEdge = false,
            edgeSize = 2
        }
        shardFrame:SetBackdrop(backdrop)
        shardFrame:SetBackdropBorderColor(RankToQualityColor(shard.rank))
        shardFrame:SetPoint("TOPLEFT", baseX + padding * (itt-1) + (itt - 1) * iconsize,-baseX - 1*(padding*(row-1) + (row-1)*iconsize))

        shardFrame:SetScript("OnEnter", function()
            shardtt:SetOwner(shardFrame, "ANCHOR_RIGHT", 0, 0)
            shardtt:SetBackdropBorderColor(RankToQualityColor(shard.rank))
            shardtt:SetSize(200, 600)
            shardtt:AddDoubleLine(shard.name, "Rank "..shard.rank, RankToQualityColor(shard.rank))
            for _, g in ipairs(shard.groups) do
                if g then
                    shardtt:AddLine(NameForGroup(tonumber(g)), RankToQualityColor(shard.rank))
                    shardtt:AddLine(BonusForGroup(tonumber(g), shard.rank), RankToQualityColor(shard.rank))
                end
            end
            shardtt:Show()
        end)
        shardFrame:SetScript("OnLeave", function()
            shardtt:ClearLines(0)
            shardtt:Hide()
        end)
        shardFrame:SetScript("OnClick", function()
            if SoulShard.clicked then
                local prevShard = SoulShard.ActiveShards[SoulShard.clicked]
                if prevShard > 0 then
                    SoulShard.ShardToFrame[prevShard]:SetBackdropBorderColor(RankToQualityColor(SoulShard.Shards[prevShard].rank))
                end
                PushForgeMessage(ForgeTopic.SET_SOULSHARDS, (SoulShard.clicked-1)..";"..shard.source)
                SoulShard.BinShown = false
                ShardBin:Hide()
            end
        end)

        SoulShard.ShardToFrame[shard.source] = shardFrame
        itt = itt + 1
        shardCount = shardCount + 1
    end

    ShardBin:SetSize(ShardBin:GetWidth(), (row+1)*padding + row*iconsize);
    PushForgeMessage(ForgeTopic.GET_SOULSHARDS, "active")
end);

function RankToQualityColor(rank)
    if rank == 1 then
        return 157/255, 157/255, 157/255
    elseif rank == 2 then
        return 255/255, 255/255, 255/255
    elseif rank == 3 then
        return 30/255, 255/255, 0/255
    elseif rank == 4 then
        return 0/255, 112/255, 221/255
    elseif rank == 5 then
        return 163/255, 53/255, 238/255
    elseif rank == 6 then
        return 255/255, 128/255, 0/255
    end
end

function GetLockedColor()
    return 245/255, 54/255, 54/255
end

function GroupToIcon(group)
    if group > 0 then
        if group == 1 then
            -- beast
            return "Interface\\Icons\\Ability_Hunter_BeastMastery"
        elseif group == 2 then
            -- dragonkin
            return "Interface\\Icons\\INV_Misc_Heav_Dragon_Black"
        elseif group == 3 then
            -- demon
            return "Interface\\Icons\\Achievement_Boss_Magtheridon"
        elseif group == 4 then
            -- elemental
            return "Interface\\Icons\\Achievement_Boss_Murmur"
        elseif group == 5 then
            -- giant
            return "Interface\\Icons\\Achievement_Boss_GruulTheDragonkiller"
        elseif group == 6 then
            -- undead
            return "Interface\\Icons\\Spell_Holy_SenseUndead"
        elseif group == 7 then
            -- humanoid
            return "Interface\\Icons\\Achievement_Boss_EdwinVancleef"
        elseif group == 9 then
            -- mechanical
            return "Interface\\Icons\\Achievement_Boss_Mimiron_01"
        end
    end
end

function BonusForGroup(group, rank)
    if group > 0 then
        if group == 1 then
            local base = 5
            return "+ "..tostring(base*rank).." Attack Power"
        elseif group == 2 then
            local base = 5
            return "+ "..tostring(base*rank).." Spell Power"
        elseif group == 3 then
            local base = 1
            return "+ "..tostring(base*rank).."% Minion Damage"
        elseif group == 4 then
            local base = 1
            return "+ "..tostring(base*rank).."% Spell Resistance"
        elseif group == 5 then
            local base = 100
            return "+ "..tostring(base*rank).." Max Health"
        elseif group == 6 then
            local base = 1
            return "+ "..tostring(base*rank).."% Movement Speed"
        elseif group == 7 then
            local base = 8
            return "+ "..tostring(base*rank).." Critical Strike Rating"
        elseif group == 9 then
            local base = 12
            return "+ "..tostring(base*rank).." Haste Rating"
        end
    end
end

function NameForGroup(group)
    if group > 0 then
        if group == 1 then
            return "Beast"
        elseif group == 2 then
            return "Dragonkin"
        elseif group == 3 then
            return "Demon"
        elseif group == 4 then
            return "Elemental"
        elseif group == 5 then
            return "Giant"
        elseif group == 6 then
            return "Undead"
        elseif group == 7 then
            return "Humanoid"
        elseif group == 9 then
            return "Mechanical"
        end
    end
end