local PowerTypes = {
    WARRIOR = {
        --["RAGE"] = {texture = "", color = {R = 77, G = 133, B = 230}, name = "Lunar Power"},
    },
}


local function UpdatePowerBar(frame, unit, isAlternateBar)
    local _, class = UnitClass(unit)
    local powerType, powerToken = UnitPowerType(unit)

    if isAlternateBar and PowerTypes[class] and PowerTypes[class]["PlayerFrameAlternateManaBar"] then
        powerType = PowerTypes[class]["PlayerFrameAlternateManaBar"]
    else
        powerType = powerToken
    end

    local classConfig = PowerTypes[class]
    if classConfig and classConfig[powerType] then
        local config = classConfig[powerType]
        if config and frame then
            if config.texture and config.texture ~= "" then
                frame:SetStatusBarTexture(config.texture)
            end

            if config.color and config.color.R and config.color.G and config.color.B then
                frame:SetStatusBarColor(config.color.R / 255, config.color.G / 255, config.color.B / 255)
            end

            frame:SetScript("OnEnter", function(self)
                if config.name and config.name ~= "" then
                    GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", -90, 120)
                    GameTooltip:SetText(config.name)
                    GameTooltip:Show()
                else
                    GameTooltip:Hide()
                end
            end)

            frame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
    end

    if not isAlternateBar and unit == "player" and PlayerFrameAlternateManaBar then
        UpdatePowerBar(PlayerFrameAlternateManaBar, unit, true)
    end
end

local function UpdatePartyMemberFramePowerBar(frame, unit)
    local _, class = UnitClass(unit)
    local config = PowerTypes[class]

    if config and frame and frame:IsVisible() then
        local powerBar = _G[frame:GetName() .. "ManaBar"]
        if powerBar then
            UpdatePowerBar(powerBar, unit)
        end
    end
end

local function UpdateAllPartyMembers()
    for i = 1, 5 do
        UpdatePartyMemberFramePowerBar(_G["PartyMemberFrame" .. i], "party" .. i)
    end
end

local function OnUpdateHandler()
    local playerUnit = "player"
    local targetUnit = "target"
	local focusUnit = "focus"

    UpdatePowerBar(PlayerFrameManaBar, playerUnit)
    if TargetFrameManaBar then
        UpdatePowerBar(TargetFrameManaBar, targetUnit)
    end
	
	if 	FocusFrameManaBar then
	UpdatePowerBar(FocusFrameManaBar, focusUnit)
	end
	

    UpdateAllPartyMembers()
end

local frame = CreateFrame("FRAME")
frame:SetScript("OnUpdate", OnUpdateHandler)

--[[Tooltips]]--
local function ModifyTooltipText(tooltip)
    local _, class = UnitClass("player")
    local classConfig = PowerTypes[class]
    if classConfig then
        for i = 1, tooltip:NumLines() do
            local line = _G[tooltip:GetName() .. "TextLeft" .. i]
            local text = line and line:GetText() or ""
            for powerType, config in pairs(classConfig) do
                if powerType ~= "PlayerFrameAlternateManaBar" then
                    local resourceName = _G[powerType] or powerType
                    text = text:gsub(resourceName, config.name)
                end
            end
            if line then
                line:SetText(text)
            end
        end
    end
end

local function HookTooltip(tooltip)
    tooltip:HookScript("OnTooltipSetSpell", function(self)
        ModifyTooltipText(self)
    end)
end


HookTooltip(GameTooltip)
HookTooltip(ItemRefTooltip)
