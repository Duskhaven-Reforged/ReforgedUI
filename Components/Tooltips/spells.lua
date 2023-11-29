function InitializeTooltips()
    PushForgeMessage(ForgeTopic.GET_TOOLTIPS, "1")
end

Tooltips = {}
ToolTipFrames = {}

SubscribeToForgeTopic(ForgeTopic.GET_TOOLTIPS, function(msg)
    local tt = DeserializeMessage(DeserializerDefinitions.GET_TOOLTIPS, msg);
    for index, tooltip in pairs(tt) do
        Tooltips[tooltip.Id] = tooltip.AddedTooltipEffects;
    end
end)

local function GetTooltipText(tooltip, id, type)
    for i = 1, 15 do
        local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
        local frameRight = _G[tooltip:GetName() .. "TextRight" .. i]
        local text
        local textRight
        if frame then
            text = frame:GetText()
        end
        if frameRight then
            textRight = frameRight:GetText()
        end
        if text then
            print(i, text)
        end

        if textRight then
            print(i, textRight)
        end
    end
end

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
    local idStr = tostring(select(3, self:GetSpell()))
    if Tooltips[idStr] then
        local i = 1;
        local height = 0;

        for k, v in pairs(Tooltips[idStr]) do
            local name = "FORGEToolTip" .. tostring(i);
            if ToolTipFrames[i] == nil then
                ToolTipFrames[i] = CreateFrame("GameTooltip", name, WorldFrame, "GameTooltipTemplate");
            end
            -- ToolTipFrames[i]:Show();
            self:AddLine(" ")
            ToolTipFrames[i]:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -227, height * -1);
            ToolTipFrames[i]:SetHyperlink('spell:' .. v);
            ToolTipFrames[i]:SetSize(228, ToolTipFrames[i]:GetHeight())
            local first = true;

            for i = 1, 15 do
                local frame = _G[name .. "TextLeft" .. i]
                local text
                if frame then
                    text = frame:GetText()
                end

                if text then
                    if first then
                        self:AddLine("|cffFFFFFF" .. text .. "\124r")
                        first = false;
                    else
                        self:AddLine("|cffffd200" .. text .. "\124r", 0, 0, 0, true)
                    end

                end
            end
            ToolTipFrames[i]:Hide()
            i = i + 1;
        end
        -- self:SetPoint("TOP", 0, height * -1);
    end
end)

GameTooltip:HookScript("OnTooltipCleared", function(self)
    for k, v in pairs(ToolTipFrames) do
        v:Hide()
    end
end)

