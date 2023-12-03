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

function GetClassTree(classString)
    if classString == "Warrior" then
        return "38";
    elseif classString == "Paladin" then
        return "39";
    elseif classString == "Hunter" then
        return "40";
    elseif classString == "Rogue" then
        return "41";
    elseif classString == "Priest" then
        return "42";
    elseif classString == "Death Knight" then
        return "43";
    elseif classString == "Shaman" then
        return "44";
    elseif classString == "Mage" then
        return "45";
    elseif classString == "Warlock" then
        return "46";
    else
        return 47;
    end
end

function InitializeTalentTree()
    TalentTree.ClassTree = GetClassTree(UnitClass("player"))
    --InitializeGridForForgeSkills();
    FirstRankToolTip = CreateFrame("GameTooltip", "firstRankToolTip", WorldFrame, "GameTooltipTemplate");
    SecondRankToolTip = CreateFrame("GameTooltip", "secondRankToolTip", WorldFrame, "GameTooltipTemplate");
    PushForgeMessage(ForgeTopic.TalentTree_LAYOUT, "-1")
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
    
    table.sort(TalentTree.FORGE_TABS, function(left, right)
        return left.Id < right.Id
    end)

    PushForgeMessage(ForgeTopic.GET_CHARACTER_SPECS, "-1")
    -- UpdateTalentCurrentView();
end

function GetCharacterSpecs(msg)
    local listOfObjects = DeserializeMessage(DeserializerDefinitions.GET_CHARACTER_SPECS, msg);
    for i, spec in ipairs(listOfObjects) do
        if spec.Active == "1" then
            SELECTED_SPEC = spec.CharacterSpecTabId
            FORGE_ACTIVE_SPEC = spec;

            for _, pointStruct in ipairs(spec.TalentPoints) do
                TreeCache.Points[pointStruct.CharacterPointType] = pointStruct.AvailablePoints
                TalentTree.MaxPoints[pointStruct.CharacterPointType] = pointStruct.AvailablePoints
            end
        else
            table.insert(TalentTree.FORGE_SPEC_SLOTS, spec)
        end
    end
                        
    if TalentTree.INITIALIZED == false then

        local firstTab = TalentTree.FORGE_TABS[1];
        if SELECTED_SPEC then
            for i, tab in ipairs(TalentTree.FORGE_TABS) do
                if tab.Id == SELECTED_SPEC then
                    firstTab = tab
                end
            end
        end         
        InitializeTalentLeft();
        InitializeForgePoints();
        SelectTab(firstTab);
    else
        ShowTypeTalentPoint(TalentTree.FORGE_SELECTED_TAB.TalentType, TalentTree.FORGE_SELECTED_TAB.Id)
    end

    TalentTree.INITIALIZED = true;
    PushForgeMessage(ForgeTopic.GET_TALENTS, "-1")
end

SubscribeToForgeTopic(ForgeTopic.LEARN_TALENT_ERROR, function(msg)
    print("Talent Learn Error: " .. msg);
end)

local onUpdateFrame = CreateFrame("Frame")
SubscribeToForgeTopic(ForgeTopic.GET_TALENTS, function(msg)
    local type, _ = string.find(alpha, string.sub(msg, 1, 1))
    local spec, _ = string.find(alpha, string.sub(msg, 2, 2))
    local class, _ = string.find(alpha, string.sub(msg, 3, 3))

    if not TreeCache.PreviousString[type] then
        TreeCache.PreviousString[type] = nil
    end

    if msg ~= TreeCache.PreviousString[type] then
        print(msg)
        if not TalentTree.FORGE_TALENTS then
            TalentTree.FORGE_TALENTS = {};
        end

        local specTreeLen = 0
        if TreeCache.Spells[tostring(spec)] then
            specTreeLen = #TreeCache.Spells[tostring(spec)]
        end

        local classTreeLen = 0
        if TreeCache.Spells[TalentTree.ClassTree] and type-1 == CharacterPointType.TALENT_SKILL_TREE then
            classTreeLen = #TreeCache.Spells[TalentTree.ClassTree]
            print("Class tree size: "..classTreeLen)
        end

        TreeCache.Points[tostring(type-1)] = TalentTree.MaxPoints[tostring(type-1)]
        
        local classBlock = 3 + classTreeLen
        if (4 > classBlock) then
            local classString = string.sub(msg, 4, classBlock)
        end

        local specBlock = classBlock + specTreeLen
        print("starts: "..(classBlock+1).." ends: "..specBlock)
        local nodeInd = 1
        local specString = string.sub(msg, classBlock+1, specBlock)
        for i = 1, specTreeLen, 1 do
            local rank = string.find(alpha, string.sub(specString, i, i)) - 1
            TreeCache.Spells[tostring(spec)][nodeInd] = rank
            TreeCache.Points[tostring(type-1)] = TreeCache.Points[tostring(type-1)] - rank
            nodeInd = nodeInd + 1
        end

        TreeCache.PreviousString[type] = msg
        SelectTab(tostring(spec))
    end
end)

function GetClassId (classString)
    if classString == "Warrior" then
        return 1;
    elseif classString == "Paladin" then
        return 2;
    elseif classString == "Hunter" then
        return 3;
    elseif classString == "Rogue" then
        return 4;
    elseif classString == "Priest" then
        return 5;
    elseif classString == "Death Knight" then
        return 6;
    elseif classString == "Shaman" then
        return 7;
    elseif classString == "Mage" then
        return 8;
    elseif classString == "Warlock" then
        return 9;
    else
        return 11;
    end
end