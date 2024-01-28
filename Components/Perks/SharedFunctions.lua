function CreateRankedTooltip(id, parent, tt, depth, width, anchor, unique)
    if not GetSpellInfo(id) then
        tt:ClearLines()
        tt:SetSize(0, 0)
        tt:Hide()
        return
    end
    tt:SetOwner(parent, anchor, -2, -1 * depth);
    tt:SetHyperlink('spell:' .. id);
    if unique == 1 then
        tt:AddLine("");
        tt:AddLine("|cff990033Unique\124r");
        tt:SetHeight(tt:GetHeight() + 10);
    end

    if width == 0 then
        tt:SetSize(tt:GetWidth(), tt:GetHeight());
    else
        tt:SetSize(width, tt:GetHeight());
    end
end

function SetUpRankedTooltip(parent, id, anchor)
    CreateRankedTooltip(id, parent, perkTooltip1, 0, 0, anchor, 0);
    CreateRankedTooltip(id + 1000000, parent, perkTooltip2, perkTooltip1:GetHeight(), perkTooltip1:GetWidth(), anchor, 0);
    CreateRankedTooltip(id + 2000000, parent, perkTooltip3, perkTooltip1:GetHeight() + perkTooltip2:GetHeight(),
        perkTooltip1:GetWidth(), anchor, 0);
    perkBG:SetSize(perkTooltip1:GetWidth() + 5,
        perkTooltip1:GetHeight() + perkTooltip2:GetHeight() + perkTooltip3:GetHeight() + 5)
    perkBG:SetPoint("TOP", perkTooltip1, "TOP", 3, 3)
    perkBG:Show()
end

function SetUpSingleTooltip(parent, id, anchor)
    CreateRankedTooltip(id, parent, perkTooltip1, 0, 0, anchor, 1);
    perkBG:SetSize(perkTooltip1:GetWidth() + 5, perkTooltip1:GetHeight() + 5)
    perkBG:SetPoint("TOP", perkTooltip1, "TOP", 3, 3)
    perkBG:Show()
end

function clearTooltips()
    perkTooltip1:ClearLines(0)
    perkTooltip2:ClearLines(0)
    perkTooltip3:ClearLines(0)
    perkTooltip1:SetSize(0, 0)
    perkTooltip2:SetSize(0, 0)
    perkTooltip3:SetSize(0, 0)
    perkTooltip1:Hide();
    perkTooltip2:Hide();
    perkTooltip3:Hide();
    perkBG:Hide()
end

function SetRankTexture(current, rank)
    if not current.Rank then
        current.Rank = current:CreateTexture(nil, "OVERLAY", nil, current:GetFrameLevel() + 3);
    end
    current.Rank:SetSize(current:GetWidth() / 2, current:GetHeight() / 2)
    current.Rank:SetPoint("TOPRIGHT", -2, -2);

    if (rank == 1) then
        current.Rank:SetTexture(assets.rankone)
    elseif (rank == 2) then
        current.Rank:SetTexture(assets.ranktwo)
    elseif (rank == 3) then
        current.Rank:SetTexture(assets.rankthree)
    end
end