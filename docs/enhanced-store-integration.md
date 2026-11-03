# Enhanced Vehicle Store: optional Gold Standard integration

## Status

The creator verified this change in-game on November 2, 2026, with TF3 build 40425 and Enhanced Vehicle Store v1.3 (mod ID `ethan_vehicle_helper_next`, revision 4). This is a proposal for the store's maintainer, not a released store update or an automatically applied Gold Standard feature.

## Problem

The store's table `shortMoney(v)` builds an abbreviated number from the original game-dollar value, while obtaining the currency label from `money(v)`. With Gold Standard active, that label belongs to a converted amount. Above the store's abbreviation threshold, the table can therefore show a different price from the detail panel.

Observed example: the table showed approximately `ƒ 307k`, while the selected wagon's detail price was `ƒ 114.164,22`. After integration the compact table value agrees with the converted detail value. Purchase calculations are unaffected.

## Minimal change

In `content/vehicle_helper_next/vh_buyer.lua`, add this optional bridge at module scope:

```lua
local gsOk, gsRuntime = pcall(ug_require, "fairl_gold_standard::/gold/runtime.lua")
local function gsNarrow(n)
    if gsOk and type(gsRuntime) == "table"
        and type(gsRuntime.narrowMoney) == "function" then
        local ok, short, full = pcall(gsRuntime.narrowMoney, n)
        if ok and type(short) == "string" and type(full) == "string" then
            return short, full
        end
    end
end
```

At the beginning of the store's existing `shortMoney(v)`, before its current formatting logic, add:

```lua
local gsShort, gsFull = gsNarrow(v)
if gsShort then return gsShort, gsFull end
```

Keep the store's remaining function body as the fallback. No dependency on Gold Standard is required. The module must not load the bridge in the simulation environment; this belongs in the existing GUI buyer module.

The helper receives raw game dollars and returns compact text plus a full-value tooltip from the same conversion/settings/year snapshot. It respects the selected label, prefix/suffix position, precision, separators, base rate and annual display inflation. It does not change the user's global compact setting. Ordinary detail views continue using the shared money formatter.

## Validation

- With Gold Standard disabled or its helper unavailable, confirm the store retains its existing formatting and opens normally.
- With Gold Standard enabled, compare table, full tooltip, detail price and purchase total for the same wagon and variation, including prices above and below 100,000 game dollars.
- Repeat with a non-1:1 conversion, a nonzero annual rate in a later year, both decimal separators, and prefix/suffix labels.
- Apply changed Gold Standard settings, reopen the store and confirm both compact and full values refresh.
- Keep affordability, purchase totals used for charging, sorting and simulation values in raw game dollars. Convert only the displayed strings.

## Distribution

Including this bridge in an official Enhanced Vehicle Store release would make the fix available to that mod's subscribers. Gold Standard alone cannot alter this private formatter through its existing public API. Manual edits are temporary and may be overwritten by a store update.

This document supplies only the proposed bridge; it does not redistribute the store's source. The proposal has not been submitted to or accepted by the store's maintainer.
