# Changelog

## 1.0.1 (2026-08-22)

- Fixed: buttons never appeared because the addon targeted old Auctionator globals (`Atr_SellControls`, `Atr_Batch_Stacksize`, …), which no longer exist in modern Auctionator v334.x.
- Rewritten against the modern Auctionator selling-tab API (`AuctionatorSellingFrame.SaleItemFrame.Stacks`).
- Clicking a button now reuses Auctionator's own `UpdatePrices()` and `MaxNumStacksClicked()` instead of reimplementing the max-stacks math.
- Buttons are anchored next to Auctionator's own "max: N" control under the stack-size field; install falls back to first auction-house open if frames are not ready at login.

## 1.0.0 (2026-08-22)

- Initial release.
- Adds three tiny buttons (`1`, `5`, `10`) to the left of the stack-size field on Auctionator's selling tab (TBC Classic / Anniversary).
- Clicking a button sets the stack size as if typed, and sets the number of stacks to max (the same value Auctionator shows as `max: N`).
- Hard dependency on Auctionator: the addon does not load at all without it (TOC dependency + runtime guard).
