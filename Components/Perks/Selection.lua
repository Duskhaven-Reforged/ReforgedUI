local xPositions = {{0}, -- 1 option
{-settings.selectionIconSize, settings.selectionIconSize}, -- 2 options
{-settings.selectionIconSize * 1.85, 0, settings.selectionIconSize * 1.85}, -- 3 options
{-2.3 * settings.selectionIconSize, -settings.selectionIconSize * 0.8, settings.selectionIconSize * 0.8,
 2.3 * settings.selectionIconSize}, -- 4 options
{-2.3 * settings.selectionIconSize, -settings.selectionIconSize * 0.8, 0, settings.selectionIconSize * 0.8,
 2.3 * settings.selectionIconSize} -- 5 options
}

function InitializeSelectionWindow()
    PerkSelectionWindow = CreateFrame("FRAME", "PerkSelectionWindow", UIParent);
    PerkSelectionWindow:SetSize(10, 10);
    PerkSelectionWindow:SetPoint("CENTER", 0, 0);
    PerkSelectionWindow:SetFrameLevel(1);
    PerkSelectionWindow:SetFrameStrata("HIGH");

    PerkSelectionWindow.Title = PerkSelectionWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    PerkSelectionWindow.Title:SetPoint("CENTER", nil, "CENTER", 0, (GetScreenHeight() / 2) - 100);
    PerkSelectionWindow.Title:SetFont("Fonts\\FRIZQT__.TTF", 72);
    PerkSelectionWindow.Title:SetShadowOffset(1, -1);
    PerkSelectionWindow.Title:SetText("Select A Perk");

    PerkSelectionWindow.background = CreateFrame("Frame", nil, PerkSelectionWindow)
    PerkSelectionWindow.background:SetPoint("CENTER", PerkSelectionWindow.Title, "CENTER", 0, -50)
    PerkSelectionWindow.background:SetSize(365, 150)
    PerkSelectionWindow.background:SetBackdrop({
        bgFile = "Interface/TutorialFrame/TutorialFrameBackground",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        edgeSize = 22,
        tileSize = 22,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    })
    PerkSelectionWindow.background:SetFrameStrata("LOW");

    PerkSelectionWindow.SelectionPool = CreateFrame("FRAME", PerkSelectionWindow.SelectionPool, PerkSelectionWindow);
    PerkSelectionWindow.SelectionPool:SetPoint("TOP", 0, (GetScreenHeight() / 2) - 150);
    PerkSelectionWindow.SelectionPool.Pool = {};
    PerkSelectionWindow.SelectionPool:SetSize(7 * settings.selectionIconSize, settings.selectionIconSize);

    for i = 1, #xPositions, 1 do
        PerkSelectionWindow.SelectionPool.Pool[i] = CreateFrame("Button", PerkSelectionWindow.SelectionPool.Pool[i],
            PerkSelectionWindow.SelectionPool);
        local cur = PerkSelectionWindow.SelectionPool.Pool[i]
        cur:SetFrameLevel(1);
        cur:SetSize(settings.selectionIconSize, settings.selectionIconSize);

        cur.Icon = CreateFrame("FRAME", cur.Icon, cur);
        cur.Icon:SetPoint("CENTER", 0, 0)
        cur.Icon:SetFrameLevel(2);
        cur.Icon:SetSize(settings.selectionIconSize, settings.selectionIconSize);

        cur.Icon.Texture = cur.Icon:CreateTexture(nil, "ARTWORK");
        cur.Icon.Texture:SetAllPoints();
        -- cur.Icon.Texture:SetTexCoord(.08, .92, .08, .92);

        cur.Icon.Carried = cur.Icon:CreateTexture(nil, "OVERLAY");
        cur.Icon.Carried:SetSize(settings.selectionIconSize / 2, settings.selectionIconSize / 2);
        cur.Icon.Carried:SetPoint("BOTTOM", 0, -settings.selectionIconSize / 4);
        cur.Icon.Carried:SetTexture(assets.hourglass);
        cur.Icon.Carried:Hide();
    end
    PerkSelectionWindow:Hide();
end

function TogglePerkSelectionFrame(on)
    if (on) then
        PerkSelectionWindow:Show()
        PlaySound("TalentScreenOpen");
    else
        PerkSelectionWindow:Hide()
        PlaySound("TalentScreenClose");
    end
end

function showPerkSelections(perks)
    -- if(archtype) then
    --     PerkSelectionWindow.Title:SetText("Select A Archtype");
    -- else
    --     PerkSelectionWindow.Title:SetText("Select A Perk");
    -- end

    for index, perk in ipairs(perks) do
        print(index .. " " .. perk.SpellId)
        AddSelectCard(perk.SpellId, index, perk.carryover, xPositions[#perks][index]);
    end
    TogglePerkSelectionFrame(true);
end

function AddSelectCard(spellID, index, isFromLastPrestige, xPos)
    local _, _, icon = GetSpellInfo(spellID);
    local curPool = PerkSelectionWindow.SelectionPool.Pool[index]
    curPool:Show()
    curPool:SetPoint("CENTER", xPos, 0);
    curPool.Icon.Texture:SetTexture(icon);
    if (isFromLastPrestige > 0) then
        curPool.Icon.Carried:Show();
    else
        curPool.Icon.Carried:Hide();
    end

    curPool:HookScript("OnEnter", function()
        SetUpRankedTooltip(curPool, spellID, "ANCHOR_BOTTOM");
    end);
    curPool:SetScript("OnLeave", function()
        clearTooltips()
    end);
    curPool:SetScript("OnClick", function()
        for i = 1, #PerkSelectionWindow.SelectionPool.Pool, 1 do
            PerkSelectionWindow.SelectionPool.Pool[i]:Hide()
        end
        PushForgeMessage(ForgeTopic.LEARN_PERK, GetSpecID() .. ";" .. spellID);
        PerkSelectionWindow:Hide();
    end);
end
