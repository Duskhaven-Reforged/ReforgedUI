local Forgeframe = CreateFrame("Frame")
Forgeframe:RegisterEvent("PLAYER_LOGIN")
Forgeframe:SetScript("OnEvent", function()
    InitializeTalentTree()
    InitializeTooltips()
    PushForgeMessage(ForgeTopic.COLLECTION_INIT, "-1");
end)
