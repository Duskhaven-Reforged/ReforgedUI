BASE = {
    UNLOCKED_MAX = 1,
    PRESTIGE = 0
}

WorldTierSettings = {
    width = GetScreenWidth() / 4,
    height = GetScreenHeight() / 4,
    pad = GetScreenWidth() / 120
}

WorldTierState = {
    clicked = 1
}

function createWorldTierSelectWindow()

    WorldTier = CreateFrame("Frame", nil, WorldTier);
    WorldTier:SetSize(WorldTierSettings.width, WorldTierSettings.height); --- LEFT/RIGHT -- --UP/DOWN --
    WorldTier:SetPoint("TOPLEFT", GetScreenWidth() / 5, -GetScreenHeight() / 6); --- LEFT/RIGHT -- --UP/DOWN --
    WorldTier:SetFrameStrata("DIALOG")
    WorldTier:EnableMouse(true)
    WorldTier:SetMovable(true)
    WorldTier:SetFrameLevel(1)
    WorldTier:SetClampedToScreen(true)
    WorldTier:SetScale(1)
    WorldTier:RegisterEvent("VARIABLES_LOADED")
    WorldTier:RegisterEvent("UI_SCALE_CHANGED")
    WorldTier:SetScript("OnEvent", function(self)
        self:SetScale(1)
    end)
    WorldTier:Hide()

    WorldTier.header = CreateFrame("BUTTON", nil, WorldTier)
    WorldTier.header:SetSize(WorldTierSettings.width, tmogsettings.headerheight)
    WorldTier.header:SetPoint("TOP", 0, 0);
    WorldTier.header:SetFrameLevel(4)
    WorldTier.header:EnableMouse(true)
    WorldTier.header:RegisterForClicks("AnyUp", "AnyDown")
    WorldTier.header:SetScript("OnMouseDown", function()
        WorldTier:StartMoving()
    end)
    WorldTier.header:SetScript("OnMouseUp", function()
        WorldTier:StopMovingOrSizing()
    end)
    SetTemplate(WorldTier.header);

    WorldTier.header.close = CreateFrame("BUTTON", "InstallCloseButton", WorldTier.header,
        "UIPanelCloseButton")
    WorldTier.header.close:SetSize(tmogsettings.headerheight, tmogsettings.headerheight)
    WorldTier.header.close:SetPoint("TOPRIGHT", WorldTier.header, "TOPRIGHT")
    WorldTier.header.close:SetScript("OnClick", function()
        WorldTier:Hide()
    end)
    WorldTier.header.close:SetFrameLevel(WorldTier.header:GetFrameLevel() + 1)

    WorldTier.header.title = WorldTier.header:CreateFontString("OVERLAY");
    WorldTier.header.title:SetPoint("CENTER", WorldTier.header, "CENTER");
    WorldTier.header.title:SetFont("Fonts\\FRIZQT__.TTF", 10);
    WorldTier.header.title:SetText("Prestige");
    WorldTier.header.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1);

    WorldTier.body = CreateFrame("Frame", WorldTier.body, WorldTier);
    WorldTier.body:SetPoint("TOP", 0, -tmogsettings.headerheight);
    WorldTier.body:SetSize(WorldTierSettings.width, WorldTierSettings.height)
    WorldTier.body:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        insets = {top = 0, left = 0, bottom = 0, right = 0},
    });
    WorldTier.body:SetBackdropColor(0,0,0,.6)

    WorldTier.body.buttonBox = CreateFrame("Frame", WorldTier.body.buttonBox, WorldTier.body);
    WorldTier.body.buttonBox:SetSize(WorldTierSettings.width/3, WorldTierSettings.height)
    WorldTier.body.buttonBox:SetPoint("TOPLEFT", 0, 0);
    WorldTier.body.buttonBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        insets = {top = 0, left = 0, bottom = 0, right = 0},
    });
    WorldTier.body.buttonBox:SetBackdropColor(0,0,0,.35)
    WorldTier.body.buttonBox.buttons = {}

    local DescriptionSplit = (WorldTierSettings.height-10)/2
    WorldTier.body.Prestige = CreateFrame("Frame", WorldTier.body.Prestige, WorldTier.body);
    WorldTier.body.Prestige:SetSize((WorldTierSettings.width*2/3)-10, DescriptionSplit)
    WorldTier.body.Prestige:SetPoint("TOPLEFT", (WorldTierSettings.width/3)+5, -5);
    WorldTier.body.Prestige.text = WorldTier.body.Prestige:CreateFontString()

    WorldTier.body.Prestige.text:SetAllPoints(WorldTier.body.Prestige)
    WorldTier.body.Prestige.text:SetFont("Fonts\\FRIZQT__.TTF", 7)
    WorldTier.body.Prestige.text:SetTextColor(255 / 255, 255 / 255, 255 / 255, 1);
    WorldTier.body.Prestige.text:SetJustifyH("CENTER")
    WorldTier.body.Prestige.text:SetJustifyV("CENTER")
    WorldTier.body.Prestige.text:SetText("\124cffBC961CYou have waived prestiging for this run.\124r")

    WorldTier.body.WorldTier = CreateFrame("Frame", WorldTier.body.Description, WorldTier.body);
    WorldTier.body.WorldTier:SetSize((WorldTierSettings.width*2/3)-10, DescriptionSplit)
    WorldTier.body.WorldTier:SetPoint("BOTTOMLEFT", (WorldTierSettings.width/3)+5, -5);
    WorldTier.body.WorldTier.text = WorldTier.body.WorldTier:CreateFontString()

    WorldTier.body.WorldTier.text:SetAllPoints(WorldTier.body.WorldTier)
    WorldTier.body.WorldTier.text:SetFont("Fonts\\FRIZQT__.TTF", 7)
    WorldTier.body.WorldTier.text:SetTextColor(255 / 255, 255 / 255, 255 / 255, 1);
    WorldTier.body.WorldTier.text:SetJustifyH("CENTER")
    WorldTier.body.WorldTier.text:SetJustifyV("TOP")

    WorldTier.body.buttonBox.Start = CreateEchosButton(WorldTier.body.buttonBox.Start, WorldTier.body.buttonBox, WorldTier.body.buttonBox:GetWidth(), WorldTier.body.buttonBox:GetHeight()/7, "Begin", 12)
    WorldTier.body.buttonBox.Start:SetScript("OnLeave", function() 
        WorldTier.body.buttonBox.Start.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
    end)
    WorldTier.body.buttonBox.Start:SetPoint("Bottom", 0, 0);
    WorldTier.body.buttonBox.Start:SetScript("OnClick", function () 
        local out = WorldTier.body.buttonBox.buttons[WorldTierState.clicked].level
        PushForgeMessage(ForgeTopic.SET_WORLD_TIER, out..";"..1)
    end)
    WorldTier.body.Prestige.text:SetText("\124cffBC961CPrestiging\124r now will reset your character back to level 1 and send you back to your starting zone. If you had a complete set of perks from a previous run they will be retained and shown back to you randomly when receiving a perk roll.\n\nShould you wish to abandon your prestige run you may do so by teleporting back to the hub and prestiging again, however \124cffFF0000YOU WILL LOSE YOUR SAVED PERKS\124r.\n\n\124cffBC961CTo unlock higher world tiers you must complete a prestige within the preceding world tier.\124r")

    SubscribeToForgeTopic(ForgeTopic.SHOW_WORLD_TIER_SELECT, function(msg)
        if msg == "0" then
            WorldTier:Hide()
        else
            WorldTier:Show()
        end
    end);

    SubscribeToForgeTopic(ForgeTopic.SEND_MAX_WORLD_TIER, function(msg)
        BASE.UNLOCKED_MAX = tonumber(msg)
        drawButtons()
        WorldTier.body.buttonBox.buttons[1]:GetScript("OnClick")(WorldTier.body.buttonBox.buttons[1], 'LeftButton');
    end);
end

function drawButtons()
    local buttonHeight = WorldTier.body.buttonBox:GetHeight()/5
    for i = 1, BASE.UNLOCKED_MAX, 1 do
        if not WorldTier.body.buttonBox.buttons[i] then
            WorldTier.body.buttonBox.buttons[i] = CreateEchosButton(WorldTier.body.buttonBox.buttons[i], WorldTier.body.buttonBox, WorldTier.body.buttonBox:GetWidth(), buttonHeight, "World Tier "..i, 8)
            WorldTier.body.buttonBox.buttons[i]:SetPoint("TOP", 0, -(i-1)*buttonHeight);
            WorldTier.body.buttonBox.buttons[i].level = i

            WorldTier.body.buttonBox.buttons[i]:SetScript("OnClick", function() 
                WorldTierState.clicked = i
                local out = WorldTier.body.buttonBox.buttons[i].level
                local scaling = math.round(((1.53^(i+1.2)-.64)*100)-100, 2)
                WorldTier.body.WorldTier.text:SetText("\124cffBC961CWorld Tier: "..out.."\124r\n\n+"..scaling.."% increased creature damage and health.\n\n\n\124cffBC961CEventually, we will add affixes to the world tiers similar to BFA Corruption affixes to supplement the difficulty. All numbers are subject to tuning and all feedback should be directed to the discord.\124r");
                drawButtons()
            end)

            WorldTier.body.buttonBox.buttons[i]:SetScript("OnLeave", function()
                if WorldTier.body.buttonBox.buttons[i].level ~= WorldTierState.clicked then
                    WorldTier.body.buttonBox.buttons[i].title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
                end
            end)
        end

        if WorldTierState.clicked == i then
            WorldTier.body.buttonBox.buttons[i].title:SetTextColor(255 / 255, 255 / 255, 255 / 255, 1)
            WorldTier.body.buttonBox.buttons[i]:SetBackdropColor(0,0,0,1)
        else
            WorldTier.body.buttonBox.buttons[i].title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
            WorldTier.body.buttonBox.buttons[i]:SetBackdropColor(0,0,0,0)
        end
    end
end