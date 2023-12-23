TalentTree = {
    FORGE_TABS = {},
    FORGE_ACTIVE_SPEC = {},
    FORGE_SPECS_TAB = {},
    FORGE_SPEC_SLOTS = {},
    FORGE_SELECTED_TAB = nil,
    FORGE_SPELLS_PAGES = {},
    FORGE_CURRENT_PAGE = 0,
    FORGE_MAX_PAGE = nil,
    FORGE_TALENTS = nil,
    INITIALIZED = false,
    SELECTED_SPEC = nil,
    MaxPoints = {},
    ClassTree = nil,
    CLASS_TAB = nil
}

TreeCache = {
    Spells = {},
    PointsSpent = {},
    Investments = {},
    TotalInvests = {},
    PrereqUnlocks = {},
    PrereqRev = {},
    Points = {},
    PreviousString = {},
    IndexToFrame = {}
}

local Backdrop = {
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",  -- Arquivo de textura do fundo
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",  -- Arquivo de textura da borda
    tile = true, tileSize = 16, edgeSize = 16, 
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

TalentTreeWindow = CreateFrame("Frame", "TalentFrame", UIParent);
TalentTreeWindow:SetSize(1000, 800)
TalentTreeWindow:SetPoint("CENTER", 0, 50) --- LEFT/RIGHT -- --UP/DOWN --
TalentTreeWindow:SetFrameLevel(1);
TalentTreeWindow:SetFrameStrata("FULLSCREEN")
TalentTreeWindow:Hide()


ClassSpecWindow = CreateFrame("Frame", "ClassSpecWindow", UIParent);
ClassSpecWindow:SetSize(1000, 800)
ClassSpecWindow:SetPoint("CENTER", 0, 50) --- LEFT/RIGHT -- --UP/DOWN --
ClassSpecWindow:SetFrameLevel(1);
ClassSpecWindow:SetFrameStrata("FULLSCREEN")
ClassSpecWindow:Hide()

ClassSpecWindow:RegisterEvent("UNIT_SPELLCAST_START")
ClassSpecWindow:RegisterEvent("UNIT_SPELLCAST_STOP")
ClassSpecWindow:SetScript("OnEvent", function(self, event, unit)
    if unit == "player" then
        local spellName = UnitCastingInfo(unit)
        if event == "UNIT_SPELLCAST_START" and spellName == "Activate Primary Spec" then
            CastingBarFrame:SetBackdrop({bgFile = "path/to/your/background/texture"})
            CastingBarFrame:SetStatusBarTexture("path/to/your/statusbar/texture")
            CastingBarFrame:SetFrameStrata("TOOLTIP")
            CastingBarFrame:ClearAllPoints()
            CastingBarFrame:SetPoint("CENTER", ClassSpecWindow, "CENTER", 0, 0)
        elseif event == "UNIT_SPELLCAST_STOP" then
                CastingBarFrame:SetStatusBarTexture("Interface\TargetingFrame\UI-StatusBar")
                CastingBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 115)
        end
    end
end)



ClassSpecWindow:SetScript("OnShow", function(self)
    SetOverrideBindingClick(self, true, "N", "ClassSpecWindowClose")
end)

ClassSpecWindow:SetScript("OnHide", function(self)
    ClearOverrideBindings(self)
end)

tinsert(UISpecialFrames, "ClassSpecWindow")

local windows = {TalentTreeWindow, ClassSpecWindow}
for i, window in ipairs(windows) do

    local SpecTabButton = CreateFrame("Button", "SpecButton" .. i, window) -- Identificador único
    SpecTabButton:SetSize(150, 60)
    SpecTabButton:SetFrameStrata("LOW")
    SpecTabButton:SetScript("OnClick", function()
         if TalentTreeWindow:IsVisible() then
	     TalentTreeWindow:Hide()
		 ClassSpecWindow:Show()
		 end
    end)
	
	--[[Textures]]

	local normalTexture = SpecTabButton:CreateTexture()
    normalTexture:SetTexture("Interface\\AddOns\\ForgedWoWCommunication\\UI\\uiframestab")
    normalTexture:SetAllPoints(SpecTabButton)
	
	local highlightTexture = SpecTabButton:CreateTexture()
    highlightTexture:SetTexture("Interface\\AddOns\\ForgedWoWCommunication\\UI\\uiframestab-Highlight")
    highlightTexture:SetAllPoints(SpecTabButton)
	
    SpecTabButton:SetNormalTexture(normalTexture)
    SpecTabButton:SetHighlightTexture(highlightTexture)
	
	local SpecTabButtonText = SpecTabButton:CreateFontString()
    SpecTabButtonText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    SpecTabButtonText:SetPoint("CENTER", 0, 0)
    SpecTabButtonText:SetTextColor(1, 1, 0)
	SpecTabButtonText:SetText("Specializations")

    -- Botão Talentos
    local TalentTabButton = CreateFrame("Button", "TalentTabButton" .. i, window) -- Identificador único
    TalentTabButton:SetSize(100, 60)
	TalentTabButton:SetFrameStrata("LOW")
   -- TalentTabButton:SetPoint("LEFT", SpecTabButton, "RIGHT", 50, 0) -- Posicionado ao lado do botão Especializações
    TalentTabButton:SetScript("OnClick", function()
      if ClassSpecWindow:IsVisible() then
	     ClassSpecWindow:Hide()
		 TalentTreeWindow:Show()
         SelectTab(TalentTree.FORGE_SELECTED_TAB)
		 end
    end)

	local normalTexture2 = TalentTabButton:CreateTexture()
    normalTexture2:SetTexture("Interface\\AddOns\\ForgedWoWCommunication\\UI\\uiframestab")
    normalTexture2:SetAllPoints(TalentTabButton)
	
    local highlightTexture2 = TalentTabButton:CreateTexture()
    highlightTexture2:SetTexture("Interface\\AddOns\\ForgedWoWCommunication\\UI\\uiframestab-Highlight")
    highlightTexture2:SetAllPoints(TalentTabButton)
	
    TalentTabButton:SetNormalTexture(normalTexture2)
    TalentTabButton:SetHighlightTexture(highlightTexture2)
	
	local TalentTabText = TalentTabButton:CreateFontString()
    TalentTabText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    TalentTabText:SetPoint("CENTER", 0, 0)
    TalentTabText:SetTextColor(1, 1, 0)
	TalentTabText:SetText("Talents")
	
	    if window == TalentTreeWindow then
        SpecTabButton:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", -200, -35)
        TalentTabButton:SetPoint("LEFT", SpecTabButton, "RIGHT", 50, 0)
    elseif window == ClassSpecWindow then
        SpecTabButton:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", -200, -35)
        TalentTabButton:SetPoint("LEFT", SpecTabButton, "RIGHT", 50, 0)
    end
end

local function AdjustFrameScale(frame)
    local maxScale = 0.85
    local minScale = 0.3

    -- Obtendo as dimensões da tela e a escala da interface do usuário
    local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
    local windowWidth, windowHeight = frame:GetWidth(), frame:GetHeight()
    
    -- Calculando a escala necessária para ajustar o frame na tela
    local scaleWidth = screenWidth / windowWidth
    local scaleHeight = screenHeight / windowHeight
    local newScale = math.min(scaleWidth, scaleHeight, maxScale)
    newScale = math.max(newScale, minScale)

    -- Ajustando a escala do frame
    frame:SetScale(newScale)
end


-- Evento acionado quando a tela é redimensionada
UIParent:SetScript("OnSizeChanged", function(self, width, height)
    AdjustFrameScale(TalentTreeWindow)
end)


AdjustFrameScale(TalentTreeWindow)
AdjustFrameScale(ClassSpecWindow)


Bordertexture = TalentTreeWindow:CreateTexture(nil, "OVERLAY")
Bordertexture:SetTexture(CONSTANTS.UI.MAIN_BG)
Bordertexture:SetPoint("CENTER", 0, -100)
Bordertexture:SetTexCoord(0, 1, 0, 0.57)
Bordertexture:SetSize(TalentTreeWindow:GetWidth() * 1.8, TalentTreeWindow:GetHeight() * 1.3)

BorderSpec = ClassSpecWindow:CreateTexture(nil, "OVERLAY")
BorderSpec:SetTexture(CONSTANTS.UI.MAIN_BG_SPEC)
BorderSpec:SetPoint("CENTER", 0, -100)
BorderSpec:SetTexCoord(0, 1, 0, 0.57)
BorderSpec:SetSize(TalentTreeWindow:GetWidth() * 1.8, TalentTreeWindow:GetHeight() * 1.3)

ClassSpecWindow.Lockout = CreateFrame("Frame", "ClassSpecWindow.Lockout", ClassSpecWindow)
ClassSpecWindow.Lockout:SetSize(ClassSpecWindow:GetWidth() * 1.433, ClassSpecWindow:GetHeight() * 0.96)
ClassSpecWindow.Lockout:SetFrameLevel(100)
ClassSpecWindow.Lockout:EnableMouse(true)
ClassSpecWindow.Lockout:SetPoint("CENTER", -25, -5)
ClassSpecWindow.Lockout:Hide()


BackgroundSpec = ClassSpecWindow:CreateTexture(nil, "BACKGROUND")
BackgroundSpec:SetTexture(CONSTANTS.UI.BG_SPEC)
BackgroundSpec:SetPoint("CENTER", 0, -117)
BackgroundSpec:SetDrawLayer("BACKGROUND", -1)
BackgroundSpec:SetTexCoord(0, 1, 0, 0.57)
BackgroundSpec:SetSize(TalentTreeWindow:GetWidth() * 1.8, TalentTreeWindow:GetHeight() * 1.4)

SpecTitleText = ClassSpecWindow:CreateFontString()
SpecTitleText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
SpecTitleText:SetPoint("TOP", BackgroundSpec, "TOP", -20, -45)
SpecTitleText:SetTextColor(1, 1, 0)
SpecTitleText:SetText("Specializations")

local windows = {TalentTreeWindow, ClassSpecWindow}

for i, window in ipairs(windows) do
local closeButton = CreateFrame("Button", "CloseTalentUI" .. i, window, "UIPanelCloseButton")
closeButton:SetSize(40, 40) 
closeButton:SetFrameLevel(100)

closeButton:SetScript("OnClick", function()
    window:Hide()
end)

ClassIconTexture = window:CreateTexture(nil, "ARTWORK")
ClassIconTexture:SetTexture(CONSTANTS.UI.MAIN_BG)
ClassIconTexture:SetSize(67, 67)
ClassIconTexture:SetDrawLayer("ARTWORK", 1)
SetPortraitToTexture(ClassIconTexture, CONSTANTS.classIcon[string.upper(CONSTANTS.CLASS)])	

LockoutTexture = ClassSpecWindow.Lockout:CreateTexture(nil, "BACKGROUND") 
LockoutTexture:SetAllPoints()
LockoutTexture:SetTexture("Interface\\AddOns\\ForgedWoWCommunication\\UI\\Background_DragonflightSpec.blp")
LockoutTexture:SetTexCoord(0.083007813, 0.880859375, 0.576660156, 1)
LockoutTexture:SetVertexColor(0, 0, 0, 0.7)
LockoutTexture:SetDrawLayer("BACKGROUND", -1)

ClassSpecWindow.Lockout.texture = texture

	    if window == TalentTreeWindow then
        closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", 190, 8) 
		ClassIconTexture:SetPoint("TOPLEFT", window, "TOPLEFT", -241, 12) 
    elseif window == ClassSpecWindow then
         closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", 190, 8)
		 ClassIconTexture:SetPoint("TOPLEFT", window, "TOPLEFT", -241, 12)
    end
	
end


TalentTreeWindow.Container = CreateFrame("Frame", "Talent.Background", TalentTreeWindow);
TalentTreeWindow.Container:SetSize(TalentTreeWindow:GetWidth() * 1.42, TalentTreeWindow:GetHeight() * 0.925); -- Talent Tree Window's Background --
TalentTreeWindow.Container:SetPoint("CENTER", -20, 0)
TalentTreeWindow.Container:SetFrameStrata("MEDIUM");


TalentTreeWindow.Container.Background = TalentTreeWindow.Container:CreateTexture(nil, "ARTWORK")
TalentTreeWindow.Container.Background:SetTexCoord(0.16, 1, 0.0625, 0.5625)
TalentTreeWindow.Container.Background:SetPoint("CENTER", -12, 20)
TalentTreeWindow.Container.Background:SetSize(TalentTreeWindow:GetWidth() * 1.47, TalentTreeWindow:GetHeight() * 0.945)

TalentTreeWindow.Container.CloseButtonForgeSkills = CreateFrame("Button",
    TalentTreeWindow.Container.CloseButtonForgeSkills, TalentTreeWindow.Container)

TalentTreeWindow.Container.CloseButtonForgeSkills:SetScript("OnClick", function()
    HideForgeSkills();
end)
TalentTreeWindow.Container.CloseButtonForgeSkills:SetSize(25, 25);
TalentTreeWindow.Container.CloseButtonForgeSkills:SetPoint("TOPRIGHT", -15, -75);
TalentTreeWindow.Container.CloseButtonForgeSkills.Circle = CreateFrame("Frame", TalentTreeWindow.Container
    .CloseButtonForgeSkills.Circle, TalentTreeWindow.Container.CloseButtonForgeSkills)
TalentTreeWindow.Container.CloseButtonForgeSkills.Circle:SetSize(25, 25);
TalentTreeWindow.Container.CloseButtonForgeSkills.Circle:SetPoint("CENTER", -1.5, -1);
TalentTreeWindow.Container.CloseButtonForgeSkills.Circle:SetBackdrop({
    bgFile = CONSTANTS.UI.BORDER_CLOSE_BTN
})
TalentTreeWindow.Container.CloseButtonForgeSkills:Hide();

TalentTreeWindow.ChoiceSpecs = CreateFrame("Frame", "TalentTreeWindow.ChoiceSpecs", TalentTreeWindow.Container);
TalentTreeWindow.ChoiceSpecs:SetSize(100, 100);
TalentTreeWindow.ChoiceSpecs:SetPoint("TOP", 30, -100);
TalentTreeWindow.ChoiceSpecs:SetFrameLevel(15)
TalentTreeWindow.ChoiceSpecs:SetBackdrop({
    edgeSize = 24,
    bgFile = CONSTANTS.UI.BACKGROUND_SPECS
})
TalentTreeWindow.ChoiceSpecs.Spec = {};
TalentTreeWindow.ChoiceSpecs:Show();

_G["TalentTreeWindow"] = TalentTreeWindow
table.insert(UISpecialFrames, "TalentTreeWindow")

-- Define your popup dialog
StaticPopupDialogs["CONFIRM_TALENT_WIPE"] = {
    text = "Are you sure you want to reset all of your talents?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        local playerLevel = UnitLevel("player") -- Get the player's level
        if playerLevel >= 10 then
            RevertAllTalents()
            DEFAULT_CHAT_FRAME:AddMessage("Your talents have been reset.", 1, 1, 0) -- Sends a yellow message
        else
            DEFAULT_CHAT_FRAME:AddMessage("You must be at least level 10 to reset talents.", 1, 0, 0) -- Sends a red error message
        end
        StaticPopup_Hide("CONFIRM_TALENT_WIPE")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3, -- prevent taint from Blizzard UI
    OnShow = function(self)
        self:ClearAllPoints()
        self:SetPoint("CENTER", 50, 250) -- position it to center
        self:SetSize(800, 800) -- adjust the size as necessary
    end

}


local AcceptTalentsButton = CreateFrame("Button", "AcceptTalentsButton", TalentTreeWindow, "UIPanelButtonTemplate")
AcceptTalentsButton:SetSize(200, 25)
AcceptTalentsButton:SetPoint("BOTTOM", 0, 35) -- Position the button at the top right of the TalentTreeWindow
AcceptTalentsButton:SetText("Apply Changes")
AcceptTalentsButton:Show()

local resetButton = CreateFrame("Button", "ResetTalentsButton", TalentTreeWindow, "UIPanelButtonTemplate")
resetButton:SetSize(115, 40)
resetButton:SetPoint("RIGHT", AcceptTalentsButton, "RIGHT", 150, 0) -- Position the button at the top right of the TalentTreeWindow
resetButton:SetText("Reset Talents")
resetButton:Show()

resetButton:SetScript("OnClick", function()
    StaticPopup_Show("CONFIRM_TALENT_WIPE")
end)




--Testing--
TalentLoadoutCache = TalentLoadoutCache or {}
currentLoadout = nil

local function BuildLoadoutString()
    local out = ""

    out = out..string.sub(alpha, TalentTree.FORGE_SELECTED_TAB.TalentType + 1, TalentTree.FORGE_SELECTED_TAB.TalentType + 1)
    out = out..string.sub(alpha, TalentTree.FORGE_SELECTED_TAB.Id, TalentTree.FORGE_SELECTED_TAB.Id)
    out = out..string.sub(alpha, GetClassId(UnitClass("player")), GetClassId(UnitClass("player")))

    -- TODO: CLASS TREE
    for _, rank in ipairs(TreeCache.Spells[TalentTree.ClassTree]) do
        out = out..string.sub(alpha, rank + 1, rank + 1)
    end

    -- Spec tree last
    for _, rank in ipairs(TreeCache.Spells[TalentTree.FORGE_SELECTED_TAB.Id]) do
        out = out..string.sub(alpha, rank + 1, rank + 1)
    end

    return out
end

local function SetLoadoutButtonText(name)
    buttonText:SetText(name)
end

local function SaveLoadout(name)
    local loadoutString = BuildLoadoutString()
    TalentLoadoutCache[name] = loadoutString
    SetLoadoutButtonText(name)
end

local function ApplyLoadoutAndUpdateCurrent(name)
    local loadoutString = TalentLoadoutCache[name]
    if loadoutString then
        PushForgeMessage(ForgeTopic.LEARN_TALENT, loadoutString)
        SetLoadoutButtonText(name)
        currentLoadout = name
    end
end

AcceptTalentsButton:SetScript("OnClick", function()
    local out = ""

    -- tree metadata: type spec class
    out = out..string.sub(alpha, TalentTree.FORGE_SELECTED_TAB.TalentType + 1, TalentTree.FORGE_SELECTED_TAB.TalentType + 1)
    out = out..string.sub(alpha, TalentTree.FORGE_SELECTED_TAB.Id, TalentTree.FORGE_SELECTED_TAB.Id)
    out = out..string.sub(alpha, GetClassId(UnitClass("player")), GetClassId(UnitClass("player")))

    -- TODO: CLASS TREE
    for _, rank in ipairs(TreeCache.Spells[TalentTree.ClassTree]) do
        out = out..string.sub(alpha, rank + 1, rank + 1)
    end

    -- Spec tree last
    for _, rank in ipairs(TreeCache.Spells[TalentTree.FORGE_SELECTED_TAB.Id]) do
        out = out..string.sub(alpha, rank + 1, rank + 1)
    end

    if TreeCache.PreviousString[TalentTree.FORGE_SELECTED_TAB.TalentType + 1] ~= out then
        print("Talent string to send: "..out.." length: "..string.len(out))
        PushForgeMessage(ForgeTopic.LEARN_TALENT, out)

        -- Após enviar a mensagem, atualize o loadout atual
        ApplyLoadoutAndUpdateCurrent(currentLoadout)
    end
end)

local LoadoutDropButton = CreateFrame("Button", "LoadoutDropButton", TalentTreeWindow)
LoadoutDropButton:SetPoint("BOTTOMLEFT", TalentTreeWindow, "BOTTOMLEFT", -200, 35)
LoadoutDropButton:SetSize(180, 32)
LoadoutDropButton:SetFrameStrata("TOOLTIP")

LoadoutDropButton.bgTexture = LoadoutDropButton:CreateTexture(nil, "BACKGROUND")
LoadoutDropButton.bgTexture:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
LoadoutDropButton.bgTexture:SetPoint("CENTER")
LoadoutDropButton.bgTexture:SetWidth(250)
LoadoutDropButton.bgTexture:SetHeight(70)

buttonText = LoadoutDropButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
buttonText:SetText("Saved Loadouts")
buttonText:SetPoint("CENTER", LoadoutDropButton, "CENTER")

local arrowButton = CreateFrame("Button", nil, LoadoutDropButton)
arrowButton:SetSize(25, 25)
arrowButton:SetPoint("RIGHT", LoadoutDropButton, "RIGHT", 0, 1)

local arrowTexture = arrowButton:CreateTexture(nil, "OVERLAY")
arrowTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
arrowTexture:SetAllPoints(arrowButton)
arrowButton:SetNormalTexture(arrowTexture)

local function UpdateLoadoutMenu()
    local menuItems = {
        {
            text = "Create Loadout",
            colorCode = "|cff00ff00",
            func = function() StaticPopup_Show("CREATE_LOADOUT_POPUP") end,
            notCheckable = true
        },
    }

    for name, _ in pairs(TalentLoadoutCache) do
        table.insert(menuItems, {
            text = name,
            colorCode = "|cff0000ff",
            func = function()
                ApplyLoadoutAndUpdateCurrent(name)
                CloseDropDownMenus()
            end,
            notCheckable = true
        })
    end

    return menuItems
end

local function UpdateLoadoutButtonText(name, isDefault)
    if isDefault then
        buttonText:SetText(name)
        buttonText:SetTextColor(0, 0, 1)
    else
        buttonText:SetText(name)
        buttonText:SetTextColor(0, 0.5, 1)
    end
end


local function ShowLoadoutMenu()
    local menuItems = {
        {
            text = "Create Loadout",
            colorCode = "|cff00ff00",
            func = function() StaticPopup_Show("CREATE_LOADOUT_POPUP") end,
            notCheckable = true
        }
    }

    for name, _ in pairs(TalentLoadoutCache) do
        local submenu = {
            {
                text = "Delete Loadout",
                colorCode = "|cffFF0000",
                func = function()
                    TalentLoadoutCache[name] = nil
                    DropDownList1:Hide()
                    buttonText:SetText("Saved Loadouts")
					RevertAllTalents()
                end,
                notCheckable = true
            }
        }
        table.insert(menuItems, {
            text = name,
            colorCode = "|cffffffff",
            func = function()
                ApplyLoadoutAndUpdateCurrent(name)
            end,
            notCheckable = true,
            hasArrow = true,
            menuList = submenu
        })
    end

    local menuFrame = CreateFrame("Frame", "LoadoutMenuFrame", UIParent, "UIDropDownMenuTemplate")

    UIDropDownMenu_Initialize(menuFrame, function(self, level, menuList)
        if level == 1 then
            for i, menuItem in ipairs(menuItems) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = menuItem.text
                info.colorCode = menuItem.colorCode
                info.notCheckable = menuItem.notCheckable
                info.func = menuItem.func
                info.hasArrow = menuItem.hasArrow
                info.menuList = menuItem.menuList
                UIDropDownMenu_AddButton(info)
            end
        elseif level == 2 and menuList then
            for i, menuItem in ipairs(menuList) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = menuItem.text
                info.colorCode = menuItem.colorCode
                info.notCheckable = menuItem.notCheckable
                info.func = menuItem.func
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end, "MENU")

    ToggleDropDownMenu(1, nil, menuFrame, arrowButton, 0, 0)
end

arrowButton:SetScript("OnClick", function(self, button, down)
    ShowLoadoutMenu()
end)

StaticPopupDialogs["CREATE_LOADOUT_POPUP"] = {
    text = "Enter the name of your new loadout:",
    button1 = "OK",
    button2 = "Cancel",
    OnAccept = function(self)
        local text = self.editBox:GetText()
        SaveLoadout(text)
        buttonText:SetText(text)
    end,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function UpdateButtonDisplay(loadoutName)
    if loadoutName then
        buttonText:SetText(loadoutName)
    else
        buttonText:SetText("Saved Loadouts")
    end
end

UpdateButtonDisplay()