PORTALMASTER = {
    width = GetScreenWidth() / 10,
    height = tmogsettings.headerheight*4,
    pad = GetScreenWidth() / 120
}

PORTALMASTER_STATE = {
    activeNpc = 0,
    clicked = 1,
    redraw = false,
    selections = {
        [1] = {
            name = "Where",
            frame = nil,
            value = 0,
            entries = {},
            index = {}
        },
        [2] = {
            name = "Tier",
            frame = nil,
            value = 0,
            entries = {}
        },
    },
}

function createPortalmasterSelectWindow()
    Portalmaster = CreateFrame("Frame", nil, Portalmaster);
    Portalmaster:SetSize(PORTALMASTER.width, PORTALMASTER.height); --- LEFT/RIGHT -- --UP/DOWN --
    Portalmaster:SetPoint("TOPLEFT", GetScreenWidth() / 5, -GetScreenHeight() / 6); --- LEFT/RIGHT -- --UP/DOWN --
    Portalmaster:SetFrameStrata("DIALOG")
    Portalmaster:EnableMouse(true)
    Portalmaster:SetMovable(true)
    Portalmaster:SetFrameLevel(1)
    Portalmaster:SetClampedToScreen(true)
    Portalmaster:SetScale(1)
    Portalmaster:RegisterEvent("VARIABLES_LOADED")
    Portalmaster:RegisterEvent("UI_SCALE_CHANGED")
    Portalmaster:SetScript("OnEvent", function(self)
        self:SetScale(1)
    end)
    Portalmaster:Hide()

    Portalmaster.header = CreateFrame("BUTTON", nil, Portalmaster)
    Portalmaster.header:SetSize(PORTALMASTER.width, tmogsettings.headerheight)
    Portalmaster.header:SetPoint("TOP", 0, 0);
    Portalmaster.header:SetFrameLevel(4)
    Portalmaster.header:EnableMouse(true)
    Portalmaster.header:RegisterForClicks("AnyUp", "AnyDown")
    Portalmaster.header:SetScript("OnMouseDown", function()
        Portalmaster:StartMoving()
    end)
    Portalmaster.header:SetScript("OnMouseUp", function()
        Portalmaster:StopMovingOrSizing()
    end)
    SetTemplate(Portalmaster.header);

    Portalmaster.header.close = CreateFrame("BUTTON", "InstallCloseButton", Portalmaster.header,
        "UIPanelCloseButton")
    Portalmaster.header.close:SetSize(tmogsettings.headerheight, tmogsettings.headerheight)
    Portalmaster.header.close:SetPoint("TOPRIGHT", Portalmaster.header, "TOPRIGHT")
    Portalmaster.header.close:SetScript("OnClick", function()
        Portalmaster:Hide()
    end)
    Portalmaster.header.close:SetFrameLevel(Portalmaster.header:GetFrameLevel() + 1)

    Portalmaster.header.title = Portalmaster.header:CreateFontString("OVERLAY");
    Portalmaster.header.title:SetPoint("CENTER", Portalmaster.header, "CENTER");
    Portalmaster.header.title:SetFont("Fonts\\FRIZQT__.TTF", 10);
    Portalmaster.header.title:SetText("Teleport");
    Portalmaster.header.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1);

    Portalmaster.body = CreateFrame("Frame", Portalmaster.body, Portalmaster);
    Portalmaster.body:SetPoint("TOP", 0, -tmogsettings.headerheight);
    Portalmaster.body:SetSize(PORTALMASTER.width, PORTALMASTER.height)
    Portalmaster.body:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        insets = {top = 0, left = 0, bottom = 0, right = 0},
    });
    Portalmaster.body:SetBackdropColor(0,0,0,.75)

    Portalmaster.body.Go = CreateEchosButton(Portalmaster.body.Go, Portalmaster.body, Portalmaster.body:GetWidth(), tmogsettings.headerheight, "Go", 8)
    Portalmaster.body.Go:SetPoint("BOTTOM", 0, 0)
    Portalmaster.body.Go:SetScript("OnLeave", function() 
        Portalmaster.body.Go.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
    end)
    Portalmaster.body.Go:SetScript("OnClick", function()
        PushForgeMessage(ForgeTopic.SET_WORLD_TIER, PORTALMASTER_STATE.selections[2].value..";"..0)
        local struct = PORTALMASTER_STATE.selections[1].index[PORTALMASTER_STATE.selections[1].value]
        local msg = struct.id..";"..struct.map
        PushForgeMessage(ForgeTopic.TAKE_PORTAL_TO, msg)
    end)

    Portalmaster.body.zonedd = CreateFrame("Frame", Portalmaster.body.zonedd, Portalmaster.body);
    Portalmaster.body.zonedd:SetPoint("TOP", 0, 0);
    Portalmaster.body.zonedd:SetSize(PORTALMASTER.width, tmogsettings.headerheight*1.33)
    Portalmaster.body.zonedd.Id = 1

    Portalmaster.body.tierdd = CreateFrame("Frame", Portalmaster.body.tierdd, Portalmaster.body);
    Portalmaster.body.tierdd:SetPoint("TOP", 0, -1.33*tmogsettings.headerheight);
    Portalmaster.body.tierdd:SetSize(PORTALMASTER.width, tmogsettings.headerheight*1.33)
    Portalmaster.body.tierdd.Id = 2

    PORTALMASTER_STATE.redraw = false

    SubscribeToForgeTopic(ForgeTopic.SHOW_PORTAL_MASTER_SELECT, function(msg)
        if msg == "0" then
            Portalmaster:Hide()
        else
            PORTALMASTER_STATE.activeNpc = msg
            PushForgeMessage(ForgeTopic.SEND_PORTALS, msg)
        end
    end);

    SubscribeToForgeTopic(ForgeTopic.SEND_PORTALS, function(msg) 
        local listOfObjects = DeserializeMessage(DeserializerDefinitions.GET_PORTALS, msg);
        PORTALMASTER_STATE.selections[1].entries = {}
        for i, obj in ipairs(listOfObjects) do
            PORTALMASTER_STATE.selections[1].entries[i] = obj.mapName;
            PORTALMASTER_STATE.selections[1].index[i] = {
                id = obj.id,
                map = obj.map,
                mapName = obj.mapName,
            }
        end
        if Portalmaster.body.zonedd.dd then
            Portalmaster.body.zonedd.dd:Hide()
            Portalmaster.body.zonedd.dd = nil
        end
        Portalmaster.body.zonedd.dd = CreateEchosDropDown("typedd", Portalmaster.body.zonedd, "Where", Portalmaster.body.zonedd.Id)
        Portalmaster:Show()
        PORTALMASTER_STATE.redraw = true
    end)

    Portalmaster:SetScript("OnUpdate", function() 
        if PORTALMASTER_STATE.redraw then
            for i, val in ipairs(PORTALMASTER_STATE.selections) do
                if val.frame then
                    if PORTALMASTER_STATE.clicked ~= i then
                        val.frame.bin:Hide();
                    end
                    if val.value == 0 then
                        val.frame.text:SetText(val.name)
                    else
                        val.frame.text:SetText(val.entries[val.value])
                    end
                end
            end
            PORTALMASTER_STATE.redraw = false
        end
    end)


end

function CreateEchosDropDown(name, parent, textstr, id)
    local backdrop = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        insets = {top = -1, left = -1, bottom = -1, right = -1},
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tileEdge = false,
        edgeSize = .5
    }
    local frame = CreateFrame("Button", name, parent)
    frame:SetPoint("CENTER")
    frame:SetSize(parent:GetWidth()*.8, parent:GetHeight()*2/3)
    frame:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]], "ADD")
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0,0,0,.75)
    frame:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255,.6)
    local text = frame:CreateFontString(frame,"OVERLAY","GameFontWhite")
    text:SetPoint("CENTER")
    text:SetJustifyH("CENTER")
    text:SetFont("Fonts\\FRIZQT__.TTF", 6);
    text:SetText(textstr)
    frame.text = text

    local bin = CreateFrame("Frame", name.."bin", frame)
    bin:SetSize(frame:GetWidth(), frame:GetHeight())
    bin:SetPoint("TOPRIGHT", frame:GetWidth(), 0)
    bin:SetBackdrop(backdrop)
    bin:SetBackdropColor(0,0,0,.75)
    bin:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255,.6)

    bin.buttons = {}
    bin:SetHeight(#PORTALMASTER_STATE.selections[id].entries*frame:GetHeight())
    for i, name in ipairs(PORTALMASTER_STATE.selections[id].entries) do
        local binbtnbd = {
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            insets = {top = 0, left = 0, bottom = 0, right = 0},
        }
        local button = CreateFrame("Button", textstr..i, bin)
        button:SetSize(parent:GetWidth(), frame:GetHeight())
        button:SetBackdrop(binbtnbd)
        button:SetBackdropColor(0,0,0,0)
        button:SetPoint("TOP",0,-(i-1)*button:GetHeight())
        button.index = id
        button.id = i
        local text = button:CreateFontString(button)
        text:SetPoint("CENTER")
        text:SetFont("Fonts\\FRIZQT__.TTF", 6);
        text:SetText(name)
        text:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
        button.text = text
        button:SetScript("OnEnter", function()
            button.text:SetTextColor(1,1,1.6)
        end)
        button:SetScript("OnLeave", function()
            text:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
        end)
        button:SetScript("OnClick", function()
            if (button.index) then
                PORTALMASTER_STATE.selections[button.index].value = button.id
                PORTALMASTER_STATE.clicked = 0
                PORTALMASTER_STATE.redraw = true
            end
        end)
        bin.buttons[i] = button
    end

    bin:Hide()
    frame.bin = bin
    frame:SetScript("OnClick", function()
        if bin:IsVisible() then
            PORTALMASTER_STATE.clicked = 0
            bin:Hide()
        else
            PORTALMASTER_STATE.clicked = id
            bin:Show()
        end
        PORTALMASTER_STATE.redraw = true
    end)
    PORTALMASTER_STATE.selections[id].frame = frame
    return frame;
end