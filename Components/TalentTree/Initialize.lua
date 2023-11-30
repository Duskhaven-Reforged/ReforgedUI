function ToggleTalentFrame(openPet)
    if openPet and HasPetUI() and PetCanBeAbandoned() then
        TalentFrame_LoadUI();
        if (PlayerTalentFrame_Toggle) then
            PlayerTalentFrame_Toggle(true, 3);
        end
    else
        ToggleMainWindow();
    end
end

local function printTable(t, indent)
    indent = indent or ""
    for key, value in pairs(t) do
        if type(value) == "table" then
            print(indent .. tostring(key) .. ": ")
            printTable(value, indent .. "  ")
        else
            print(indent .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

function InitializeTalentTree()
    InitializeGridForForgeSkills();
    InitializeGridForTalent();
    FirstRankToolTip = CreateFrame("GameTooltip", "firstRankToolTip", WorldFrame, "GameTooltipTemplate");
    SecondRankToolTip = CreateFrame("GameTooltip", "secondRankToolTip", WorldFrame, "GameTooltipTemplate");
    PushForgeMessage(ForgeTopic.TalentTree_LAYOUT, "-1")
    PushForgeMessage(ForgeTopic.GET_TALENTS, "-1");
    PushForgeMessage(ForgeTopic.GET_CHARACTER_SPECS, "-1")
    SubscribeToForgeTopic(ForgeTopic.TalentTree_LAYOUT, function(msg)
        GetTalentTreeLayout(msg)
    end);
	
    SubscribeToForgeTopic(ForgeTopic.GET_CHARACTER_SPECS, function(msg)
        GetCharacterSpecs(msg);
    end);

end


function GetTalentTreeLayout(msg)
    local listOfObjects = DeserializeMessage(DeserializerDefinitions.TalentTree_LAYOUT, msg);
    for i, tab in ipairs(listOfObjects) do
        if tab.TalentType == CharacterPointType.TALENT_SKILL_TREE or tab.TalentType == CharacterPointType.RACIAL_TREE or
            tab.TalentType == CharacterPointType.PRESTIGE_TREE or tab.TalentType == CharacterPointType.SKILL_PAGE then
            table.insert(TalentTree.FORGE_TABS, tab);
        end
        if tab.TalentType == CharacterPointType.FORGE_SKILL_TREE then
            table.insert(TalentTree.FORGE_SPELLS_PAGES, tab);
        end
        if tab.TalentType == CharacterPointType.LEVEL_10_TAB then
            TalentTree.FORGE_SPECS_TAB = tab;
        end
    end
    -- UpdateTalentCurrentView();
end

function GetCharacterSpecs(msg)
    local listOfObjects = DeserializeMessage(DeserializerDefinitions.GET_CHARACTER_SPECS, msg);
    local defaultSpec = nil
    for i, spec in ipairs(listOfObjects) do
        if spec.Active == "1" then
            defaultSpec = spec.CharacterSpecTabId
            FORGE_ACTIVE_SPEC = spec;
        else
            table.insert(TalentTree.FORGE_SPEC_SLOTS, spec)
        end
    end
                        
    if TalentTree.INITIALIZED == false then
        InitializeTalentLeft();
        InitializeForgePoints();
        InitializeTabForSpellsToForge(TalentTree.FORGE_SPELLS_PAGES);

        local firstTab = TalentTree.FORGE_TABS[1];
        if defaultSpec then
            print (defaultSpec)
            for i, tab in ipairs(TalentTree.FORGE_TABS) do
                if tab.Id == defaultSpec then
                    firstTab = tab
                end
            end
        end         

        SelectTab(firstTab);
    else
        local strTalentType = GetStrByCharacterPointType(TalentTree.FORGE_SELECTED_TAB.TalentType);
        ShowTypeTalentPoint(TalentTree.FORGE_SELECTED_TAB.TalentType, strTalentType)
    end

    TalentTree.INITIALIZED = true;
end

SubscribeToForgeTopic(ForgeTopic.LEARN_TALENT_ERROR, function(msg)
    print("Talent Learn Error: " .. msg);
end)


local onUpdateFrame = CreateFrame("Frame")
SubscribeToForgeTopic(ForgeTopic.GET_TALENTS, function(msg)
    if not TalentTree.FORGE_TALENTS then
        TalentTree.FORGE_TALENTS = {};
    end
    local talents = DeserializeMessage(DeserializerDefinitions.GET_TALENTS, msg);

    for tabId, talent in ipairs(talents) do
        if talent.Talents then
            for spellId, rank in pairs(talent.Talents) do
                if not TalentTree.FORGE_TALENTS[talent.TabId] then
                    TalentTree.FORGE_TALENTS[talent.TabId] = {};
                end
                TalentTree.FORGE_TALENTS[talent.TabId][spellId] = rank;
            end
			
            UpdateTalent(talent.TabId, talent.Talents)
        end
    end

    if #talents > 0 and talents[1].TabId then
        onUpdateFrame:SetScript("OnUpdate", function(self, elapsed)
             if TalentTreeWindow and TalentTreeWindow.TabsLeft and TalentTreeWindow.TabsLeft.Spec and talents[1].TabId and TalentTreeWindow.TabsLeft.Spec[talents[1].TabId] and not oneTime then
                SelectTab(talents[1].TabId)
	            TalentTreeWindow.Container:Show()
	            TalentTreeWindow.GridTalent:Show()
                self:SetScript("OnUpdate", nil)
            else
                return
            end
        end)
    else
    end
end)

