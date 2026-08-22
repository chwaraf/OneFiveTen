--[[----------------------------------------------------------------------------
    OneFiveTen
    Tiny 1/5/10 quick-stack buttons for Auctionator's selling tab.
    World of Warcraft: Burning Crusade Classic (TBC Anniversary, client 2.5.x)

    What it does
      * Places three small buttons (1, 5, 10) to the LEFT of the "stack size"
        (items per stack) field on Auctionator's selling tab.
      * Clicking a button:
          1. Types that number into the stack-size field, exactly as if the
             player had typed it - Auctionator's own OnTextChanged handler
             (Atr_StackSizeChangedFunc) is invoked, so per-stack prices,
             labels and deposit all update through Auctionator's code.
          2. Sets the "number of stacks" field to max, exactly as if the
             player had pressed the Max control under that field. TBC
             Auctionator has no clickable Max button; its "max: N" hint text
             is computed as floor(bagsTotal / stackSize). This addon applies
             that same value, computed the same way from the same data.

    Loading behaviour
      * The .toc declares "## Dependencies: Auctionator": if Auctionator is
        not installed, not enabled, or fails to load, the game does NOT load
        this addon at all. The runtime guard below is a second line of
        defence for the case where Auctionator is present but its UI failed.

    License: MIT (see LICENSE)
----------------------------------------------------------------------------]]--

-- Hard runtime guard: without Auctionator's selling-tab frames, do nothing.
if not Atr_SellControls or not Atr_Batch_Stacksize or not Atr_Batch_NumAuctions then
    return
end

local OneFiveTen = {}

-------------------------------------------------------------------------------
-- Layout
-- Auctionator's row on the selling tab (X offsets inside Atr_SellControls):
--     [number of stacks]  "stacks of"  [stack size]
--          18..58           55..137      139..179
--
-- OneFiveTen shifts the row apart a little and inserts three 15x16 buttons
-- between the "stacks of" label and the stack-size field:
--     [number of stacks]  "stacks of"  [1][5][10]  [stack size]
--          6..46           22..104      92..141     151..191
-- The invisible controls column is widened to fit. All numbers below can be
-- tweaked; the editbox rows sit at y=-208, the "max: N" hints at y=-229.
-------------------------------------------------------------------------------

OneFiveTen.LAYOUT = {
    controlsWidth = 193,            -- Atr_SellControls was 170 wide
    numAuctionsX  = 6,              -- was 18
    labelX        = 22,             -- was 55
    stackSizeX    = 151,            -- was 139
    buttonY       = -204,           -- 16px tall vs 20px fields (vertically centered)
    buttonWidth   = 15,
    buttonGap     = 2,
    firstButtonX  = 92,             -- rightmost button ends at 141
    rowY          = -208,
    hintsY        = -229,
}

local function RelayoutRow()
    local layout = OneFiveTen.LAYOUT
    local controls = Atr_SellControls

    controls:SetWidth(layout.controlsWidth)

    local label = Atr_Batch_Stacksize_Text
    if label then
        label:ClearAllPoints()
        label:SetPoint("TOPLEFT", controls, "TOPLEFT", layout.labelX, layout.rowY)
    end

    Atr_Batch_NumAuctions:ClearAllPoints()
    Atr_Batch_NumAuctions:SetPoint("TOPLEFT", controls, "TOPLEFT", layout.numAuctionsX, layout.rowY)

    Atr_Batch_Stacksize:ClearAllPoints()
    Atr_Batch_Stacksize:SetPoint("TOPLEFT", controls, "TOPLEFT", layout.stackSizeX, layout.rowY)

    -- Keep the "max: N" hints under their respective fields.
    if Atr_Batch_MaxAuctions_Text then
        Atr_Batch_MaxAuctions_Text:ClearAllPoints()
        Atr_Batch_MaxAuctions_Text:SetPoint("TOPLEFT", controls, "TOPLEFT", layout.numAuctionsX, layout.hintsY)
    end
    if Atr_Batch_MaxStacksize_Text then
        Atr_Batch_MaxStacksize_Text:ClearAllPoints()
        Atr_Batch_MaxStacksize_Text:SetPoint("TOPLEFT", controls, "TOPLEFT", layout.stackSizeX, layout.hintsY)
    end
end

-------------------------------------------------------------------------------
-- "Max" behaviour
-- Sets the number-of-stacks field to the same value Auctionator displays as
-- "max: N" under the field: max = floor(totalItemsInBags / stackSize).
-------------------------------------------------------------------------------

local function SetMaxStacks()
    if not gCurrentPane or type(gCurrentPane.totalItems) ~= "number" then
        return
    end

    local stackSize
    if Atr_StackSize then                      -- Auctionator's own getter
        stackSize = Atr_StackSize()
    else
        stackSize = math.max(Atr_Batch_Stacksize:GetNumber(), 1)
    end

    local maxStacks = math.floor(gCurrentPane.totalItems / stackSize)
    if maxStacks < 1 then
        return
    end

    Atr_Batch_NumAuctions:SetText(maxStacks)
    if Atr_NumAuctionsChangedFunc then         -- same path as typing
        Atr_NumAuctionsChangedFunc()
    end
end

-------------------------------------------------------------------------------
-- Button click: behave as if the player typed the value and pressed Max.
-------------------------------------------------------------------------------

local function OnQuickStackClick(self)
    local size = self.quickValue
    if not size then
        return
    end

    -- 1) As if typed into the stack-size field.
    Atr_Batch_Stacksize:SetText(size)
    if Atr_StackSizeChangedFunc then
        Atr_StackSizeChangedFunc()
    end

    -- 2) As if pressed Max under the number-of-stacks field.
    SetMaxStacks()
end

-------------------------------------------------------------------------------
-- Button creation
-------------------------------------------------------------------------------

local function CreateQuickButton(parent, value, x)
    local layout = OneFiveTen.LAYOUT
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(layout.buttonWidth, 16)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, layout.buttonY)
    button:SetText(tostring(value))
    if button.SetNormalFontObject and GameFontNormalSmall then
        button:SetNormalFontObject(GameFontNormalSmall)
    end
    button.quickValue = value
    button:SetScript("OnClick", OnQuickStackClick)
    button:SetScript("OnEnter", function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Quick stack", 1, 1, 1)
        GameTooltip:AddLine(("Stack size %d, number of stacks = max"):format(value), 1, 0.82, 0)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)
    return button
end

local function InstallButtons()
    if OneFiveTen.buttonsInstalled then
        return
    end
    if not Atr_SellControls or not Atr_Batch_Stacksize then
        return
    end

    RelayoutRow()

    local layout = OneFiveTen.LAYOUT
    local x = layout.firstButtonX
    for _, value in ipairs({ 1, 5, 10 }) do
        CreateQuickButton(Atr_SellControls, value, x)
        x = x + layout.buttonWidth + layout.buttonGap
    end

    OneFiveTen.buttonsInstalled = true
end

-------------------------------------------------------------------------------
-- Init
-- Auctionator creates its selling pane at addon load (Atr_Main_Panel is
-- parented to AuctionFrame), so all Atr_Batch_* frames exist by login.
-------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    InstallButtons()
end)
