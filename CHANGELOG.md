# Changelog

## 1.0.0 (2026-08-22)

- Initial release.
- Adds three tiny buttons (`1`, `5`, `10`) to the left of the stack-size field on Auctionator's selling tab (TBC Classic / Anniversary).
- Clicking a button sets the stack size as if typed, and sets the number of stacks to max (the same value Auctionator shows as `max: N`).
- Hard dependency on Auctionator: the addon does not load at all without it (TOC dependency + runtime guard).
