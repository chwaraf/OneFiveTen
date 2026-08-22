# OneFiveTen

**Tiny `1` `5` `10` quick-stack buttons for Auctionator's selling tab — made for TBC Classic (Anniversary realms).**

![TBC Classic](https://img.shields.io/badge/TBC%20Classic-2.5.x-0e7ec5) ![Requires Auctionator](https://img.shields.io/badge/requires-Auctionator-orange)

OneFiveTen is a small **companion addon for [Auctionator](https://www.curseforge.com/wow/addons/auctionator)** (the TBC / Burning Crusade Classic flavour). It places three tiny buttons — `1`, `5`, `10` — to the left of the **stack size** field (items per stack) on Auctionator's *Selling* tab.

Clicking a button:

1. **types that number into the stack-size field** — exactly as if you had typed it yourself (Auctionator's own price/label/deposit updates run, nothing is faked);
2. **sets the number of stacks to max** — exactly the value Auctionator shows as `max: N` under the field (bags total ÷ stack size), as if you had pressed Max.

No more clicking into the stack-size box, typing `5`, then clicking Max every time you post a stackable item.

## Layout

```
[number of stacks]  "stacks of"   [1] [5] [10]   [stack size]
```

## Installation

1. Install [Auctionator](https://www.curseforge.com/wow/addons/auctionator) (the **Classic TBC** version).
2. Copy the `OneFiveTen` folder into `World of Warcraft\_classic_tbc_\Interface\AddOns\`.
3. Restart the game (or reload the UI) and open the Auction House → *Auctionator* tab → *Sell*.

> **Important:** OneFiveTen is a companion to Auctionator, not a replacement. It deliberately does **not load at all** if Auctionator is missing or disabled (`## Dependencies: Auctionator` in the TOC, plus a runtime guard).

## Compatibility

| | |
|---|---|
| Game | World of Warcraft: Burning Crusade Classic — Anniversary realms (client 2.5.5 / 2.5.6) |
| Addon | Auctionator TBC flavour (BCC builds, e.g. `2.5.6`, `9.x-bcc` and later) |
| TOC interface | `20506` (2.5.6) — on 2.5.5 the addon loads fine, just shows as "out of date" |

It targets Auctionator's TBC sell tab frames (`Atr_Batch_Stacksize`, `Atr_Batch_NumAuctions`, …). If Auctionator's TBC UI ever changes, OneFiveTen detects it and simply stops without errors.

## How it works

- **"As if I typed"** — `Atr_Batch_Stacksize:SetText(n)` plus a direct call to Auctionator's own `Atr_StackSizeChangedFunc()` — the exact handler Auctionator binds to the field's `OnTextChanged`.
- **"As if I pressed Max"** — TBC Auctionator has no clickable Max button; its `max: N` hint under the number-of-stacks field is computed as `floor(gCurrentPane.totalItems / stackSize)`. OneFiveTen applies that same formula from the same source data, then calls Auctionator's `Atr_NumAuctionsChangedFunc()`.
- **Loading** — `## Dependencies: Auctionator` in the `.toc` means the game will not load OneFiveTen unless Auctionator is loaded; the Lua file additionally bails out if Auctionator's frames are absent.

## Fine-tuning the layout

All coordinates live in one table at the top of [`OneFiveTen.lua`](OneFiveTen/OneFiveTen.lua) (`OneFiveTen.LAYOUT`) — button size, gaps, and every X/Y offset are tunable there.

## Development

```
publish.sh     # one-command helper to create + push the public GitHub repo
```

Pushes to `main` are auto-packaged by the BigWigs packager GitHub Action (see `.github/workflows/package.yml`) — set `CF_API_KEY` / `WAGO_API_TOKEN` secrets if you want CurseForge / Wago publishing.

## License

MIT — see [LICENSE](LICENSE).

## Credits

OneFiveTen is an independent companion addon and is **not** affiliated with the Auctionator team. Auctionator is maintained by [plusmouse](https://www.curseforge.com/members/plusmouse) and contributors (source: [Auctionator/BCC-Auctionator](https://github.com/Auctionator/BCC-Auctionator)).
