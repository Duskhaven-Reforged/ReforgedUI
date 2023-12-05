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


ClassSpecWindow = CreateFrame("Frame", "ClassSpecWindow", UIParent);
ClassSpecWindow:SetSize(1000, 800)
ClassSpecWindow:SetPoint("CENTER", 0, 50) --- LEFT/RIGHT -- --UP/DOWN --
ClassSpecWindow:SetFrameLevel(1);
ClassSpecWindow:SetFrameStrata("FULLSCREEN")
ClassSpecWindow:Hide()

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
local closeButton = CreateFrame("Button", "ClosePanel" .. i, window, "UIPanelCloseButton")
closeButton:SetSize(40, 40)  -- Tamanho do botão

-- Configurando o script de clique para fechar o frame
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
TalentTreeWindow.Container.Background:SetSize(TalentTreeWindow:GetWidth() * 1.47, TalentTreeWindow:GetHeight() * 0.925)

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
            PushForgeMessage(ForgeTopic.UNLEARN_TALENT, "-1;0")
            -- TalentTree.FORGE_SELECTED_TAB.Id;-1
            DEFAULT_CHAT_FRAME:AddMessage("Your talents have been reset.", 1, 1, 0) -- Sends a yellow message
            local talent = GetPointByCharacterPointType(tostring(CharacterPointType.TALENT_SKILL_TREE), true)
            TalentTreeWindow.PointsBottomLeft.Points:SetText(talent.AvailablePoints .. " talent points")
        else
            DEFAULT_CHAT_FRAME:AddMessage("You must be at least level 10 to reset talents.", 1, 0, 0) -- Sends a red error message
        end
        --SelectTab(TalentTree.FORGE_TABS[3]);
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

local resetButton = CreateFrame("Button", "ResetTalentsButton", TalentTreeWindow, "UIPanelButtonTemplate")
resetButton:SetSize(115, 40)
resetButton:SetPoint("BOTTOM", 0, 30) -- Position the button at the top right of the TalentTreeWindow
resetButton:SetText("Reset Talents")
resetButton:Show()

resetButton:SetScript("OnClick", function()
    StaticPopup_Show("CONFIRM_TALENT_WIPE")
end)

local AcceptTalentsButton = CreateFrame("Button", "AcceptTalentsButton", TalentTreeWindow, "UIPanelButtonTemplate")
AcceptTalentsButton:SetSize(115, 40)
AcceptTalentsButton:SetPoint("BOTTOM", 0, 0) -- Position the button at the top right of the TalentTreeWindow
AcceptTalentsButton:SetText("a")
AcceptTalentsButton:Show()

AcceptTalentsButton:RegisterForClicks("AnyDown");
AcceptTalentsButton:SetScript("OnMouseDown" , function()
    local out = ""

    -- tree metadata: type spec class
    out = out..string.sub(alpha,TalentTree.FORGE_SELECTED_TAB.TalentType+1,TalentTree.FORGE_SELECTED_TAB.TalentType+1)
    out = out..string.sub(alpha,TalentTree.FORGE_SELECTED_TAB.Id,TalentTree.FORGE_SELECTED_TAB.Id)
    out = out..string.sub(alpha,GetClassId(UnitClass("player")),GetClassId(UnitClass("player")))

    -- TODO: CLASS TREE
    for _, rank in ipairs(TreeCache.Spells[TalentTree.ClassTree]) do
        out = out..string.sub(alpha,rank+1,rank+1)
    end 

    print(out)

    -- Spec tree last
    for _, rank in ipairs(TreeCache.Spells[TalentTree.FORGE_SELECTED_TAB.Id]) do
        out = out..string.sub(alpha,rank+1,rank+1)
    end    
    
    print("Talent string to send: "..out)
    PushForgeMessage(ForgeTopic.LEARN_TALENT, out);
end)
