function InitWorldTierSelect()
    createWorldTierSelectWindow()
    PushForgeMessage(ForgeTopic.SET_WORLD_TIER, "?")
end