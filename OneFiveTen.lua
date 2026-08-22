--[[----------------------------------------------------------------------------
    OneFiveTen
    Tiny 1/5/10 quick-stack buttons for Auctionator's selling tab.
    World of Warcraft: TBC Anniversary (client 2.5.x)

    What it does
      * Places three small buttons (1, 5, 10) in the stacks row of
        Auctionator's selling tab, left of the number-of-stacks field.
      * Clicking a button:
          1. Sets the stack-size field, then calls Auctionator's own
             SaleItem:UpdatePrices(), so per-stack prices, labels and deposit
             all update through Auctionator's code.
          2. Clicks Auctionator's own "max" logic
             (Stacks:MaxNumStacksClicked()), exactly as if the player had
             pressed the Max control under the number-of-stacks field.

    Compatibility
      * Written for the MODERN Auctionator (v334.x, plusmouse/Borjamacare),
        which drives the Legacy AH on Classic Anniversary clients through
        _G.AuctionatorSellingFrame -> .SaleItemFrame -> .Stacks.
      * The .toc declares "## Dependencies: Auctionator": if Auctionator is
        not installed, not enabled, or fails to load, the game does NOT load
        this addon at all. The runtime guards below are a second line of
        defence for the case where Auctionator is present but its UI failed.

    License: MIT (see LICENSE)
----------------------------------------------------------------------------]]--

local ADDON_NAME = "OneFiveTen"

-------------------------------------------------------------------------------
-- Frame lookup
-- Modern Auctionator creates the selling tab frame as the global
-- AuctionatorSellingFrame, with the posting form under .SaleItemFrame.
-- These frames exist at addon-load time; we still probe lazily so the addon
-- tolerates any load-order surprises.
-------------------------------------------------------------------------------

local function GetSaleItem()
    local selling = _G.AuctionatorSellingFrame
    if selling and selling.SaleItemFrame and selling.SaleItemFrame.Stacks then
        return selling.SaleItemFrame
    end
    return nil
end

-------------------------------------------------------------------------------
-- Button click: behave as if the player typed the value and pressed Max.
-- All arithmetic stays inside Auctionator:
--   * SetNumber on the stack-size EditBox + UpdatePrices() makes Auctionator
--     recompute stack price, bid price and the "max: N" hint itself
--     (UpdatePrices -> DisplayMaxNumStacks -> Stacks:SetMaxNumStacks).
--   * MaxNumStacksClicked() is the exact handler behind Auctionator's own
--     clickable Max control under the number-of-stacks field.
-------------------------------------------------------------------------------

local function OnQuickStackClick(self)
    local saleItem = GetSaleItem()
    if not saleItem then
        return
    end

    if not saleItem.itemInfo then
        print(("|cff71d5ff%s|r: select an item to sell first."):format(ADDON_NAME))
        return
    end

    -- 1) As if typed into the stack-size field, then let Auctionator sync
    --    every derived value (this also refreshes the "max: N" hint).
    saleItem.Stacks.StackSize:SetNumber(self.quickValue)
    saleItem:UpdatePrices()

    -- 2) As if pressed Max under the number-of-stacks field.
    saleItem.Stacks:MaxNumStacksClicked()
end

-------------------------------------------------------------------------------
-- Button creation
-- Anchored in the stacks row, immediately LEFT of the number-of-stacks
-- EditBox, so the row reads:  [1] [5] [10] [N stacks of] [stack size]
-------------------------------------------------------------------------------

local BUTTON_VALUES = { 1, 5, 10 }

local function CreateQuickButton(parent)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(22, 18)
    if button.SetNormalFontObject and GameFontNormalSmall then
        button:SetNormalFontObject(GameFontNormalSmall)
    end
    button:RegisterForClicks("LeftButtonUp")
    button:SetScript("OnClick", OnQuickStackClick)
    button:SetScript("OnEnter", function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Quick stack", 1, 1, 1)
        GameTooltip:AddLine(("Stack size %d, number of stacks = max"):format(self.quickValue), 1, 0.82, 0)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)
    return button
end

local function InstallButtons()
    if _G.OneFiveTenInstalled then
        return true
    end

    local saleItem = GetSaleItem()
    if not saleItem then
        return false
    end

    -- Chain the buttons leftwards, ending just before the number-of-stacks
    -- EditBox. Buttons are 18 tall vs the 20 tall EditBox: y=-1 centers them.
    local previous, gap = nil, 4
    for index = #BUTTON_VALUES, 1, -1 do
        local value = BUTTON_VALUES[index]
        local button = CreateQuickButton(saleItem.Stacks)
        if index == #BUTTON_VALUES then
            button:SetPoint("TOPRIGHT", saleItem.Stacks.NumStacks, "TOPLEFT", -8, -1)
        else
            button:SetPoint("TOPRIGHT", previous, "TOPLEFT", -gap, 0)
        end
        button.quickValue = value
        button:SetText(tostring(value))
        previous = button
    end

    _G.OneFiveTenInstalled = true
    return true
end

-------------------------------------------------------------------------------
-- Init
-- Modern Auctionator does NOT build its selling tab at load time: it creates
-- its tab container (and thus AuctionatorSellingFrame and every child) from
-- its OWN AUCTION_HOUSE_SHOW handler, i.e. when the auction house is first
-- opened. That means:
--   * PLAYER_LOGIN  -> frames do not exist yet
--   * first AH open -> our event may fire before Auctionator's does
-- So we try immediately whenever the AH opens, and keep polling for a short
-- while until the frames appear. As soon as they exist we also hook the
-- selling frame's OnShow, which guarantees installation the very first time
-- the Selling tab is displayed - no second visit required.
-------------------------------------------------------------------------------

local ticker

local function FramesReady()
    local selling = _G.AuctionatorSellingFrame
    if selling and selling.SaleItemFrame and selling.SaleItemFrame.Stacks then
        return selling
    end
    return nil
end

local function StopTicker()
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
end

local function TryInstall()
    local selling = FramesReady()
    if not selling then
        return false
    end

    -- Install as soon as the tab becomes visible (covers the very first open).
    if not selling.OneFiveTenShowHooked then
        selling.OneFiveTenShowHooked = true
        selling:HookScript("OnShow", function()
            InstallButtons()
            if _G.OneFiveTenInstalled then
                StopTicker()
            end
        end)
    end

    -- Already visible right now? Install directly.
    InstallButtons()

    if _G.OneFiveTenInstalled then
        StopTicker()
        return true
    end
    return false
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
eventFrame:SetScript("OnEvent", function(self)
    TryInstall()
    if not _G.OneFiveTenInstalled and not ticker then
        -- Poll to win the race against Auctionator's own AUCTION_HOUSE_SHOW
        -- handler that creates the frames; gives up after ~8 seconds.
        local attempts = 0
        ticker = C_Timer.NewTicker(0.25, function()
            attempts = attempts + 1
            TryInstall()
            if _G.OneFiveTenInstalled or attempts >= 32 then
                StopTicker()
            end
        end)
    end
end)