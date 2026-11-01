# Gold Standard: Currency Studio

![Gold Standard — Your world. Your currency.](branding/concepts/banknote-2x.png)

Create a currency for your Transport Fever 3 world: choose a familiar label or invent your own, set a conversion rate and monetary base year, and preview an annual inflation or deflation rate in the in-game settings panel.

By [sm0keybean](https://github.com/sm0keybean). Original project code and documentation use the [MIT license](LICENSE). [Voluntary support on Ko-fi](https://ko-fi.com/smokeybean) does not unlock features.

## Preview status

This repository contains Preview 8 (revision 8), developed for Steam / Windows 64-bit, build 40425. The coin-seal interface and colon-separated title have been verified visually in-game by the creator. Full persistence, compatibility and long-session validation remain on the release checklist. This is a community development preview; it has not been submitted to mod.io or officially curated.

## Features

- Editable currency presets and custom labels up to 12 Unicode characters.
- Conversion rate, monetary base year and annual fictional inflation/deflation.
- Decimal precision, grouping, prefix/suffix and compact K/M/B amounts.
- Live previews, Apply, Cancel and preview defaults.
- Save-specific preferences, retained when you save the game.
- Compact GS toolbar button and Currency Studio window.

Major-currency presets are formatting presets with editable 1:1 defaults, not historical gold parity or contemporary exchange rates. Greifenvauder Franken defaults to 0.25 per game dollar, base year 1900 and 2% annual fictional inflation.

## Use any currency

Japanese yen is available as a preset. For Korean won, Russian ruble or another denomination, choose **Create your own**, enter a label of 1–12 Unicode characters, and set your conversion rate. Examples include `¥` or `JPY`, `₩` or `KRW`, and `₽` or `RUB`.

Choose decimal places (including 0 for whole units), number grouping, and whether the label appears before or after the amount. Your base year and annual display inflation/deflation apply to custom currencies just as they do to presets. Select **Apply to this save**, then save your game to retain the settings.

Rates are user-defined, not live exchange rates or verified historical conversions. Symbol rendering depends on the game's font; use a letter code such as JPY, KRW or RUB if a symbol does not render correctly.

## How the calendar affects money

Converted display amount = game amount × base rate × (1 + annual percent / 100)^(current game year − base year).

At a 0.25 base rate and 2% annual rate, 1,000 game dollars display as 250 currency units in 1900 and approximately 305 in 1910. This follows the in-game calendar, not time spent playing.

The mod changes displays, not simulation balances, charges or prices. Its annual rate is an additional display index. The game's independent price changes, company-level fare multipliers and subsidy scaling still apply. This is not a central-bank, purchasing-power or gold-reserve simulation. Historical finance rows use the current year's conversion, not the transaction year's rate.

## Known limitations

Native construction previews and floating numbers bypass Lua numerical conversion. They default to an honest `game $` label. The experimental native-label option changes only their label: it does not convert their values or apply inflation, precision or suffix placement. Sandbox/account inputs remain in game dollars. Cached labels may need a panel reopen or underlying state change to refresh.

Disabling the mod does not restore the native prefix during unload. Restart the game; persisted application prefix preferences may also need restoration. Do not enable Gold Standard alongside GF-001 Greifenvauder Franken.

## Install for testing

1. Back up your saves and fully exit the game.
2. Copy `fairl_gold_standard` into your Transport Fever 3 user-data `local/mods` folder. The copied folder must directly contain `mod.json`.
3. Restart, select a duplicate test save, disable GF-001 and enable Gold Standard (Preview).
4. Open the GS button, adjust settings and select Apply.
5. Save the duplicate, fully restart and reload to check persistence.

Do not copy tests, development tools or the whole repository into the mods folder.

## Bugs and contributions

[Report a bug](https://github.com/sm0keybean/gold-standard/issues/new?template=bug_report.md) with the game build, mod revision, settings and reproduction steps. Remove personal information from screenshots and error excerpts. Please do not upload full saves unless requested.

Community improvements and translations are welcome; see [CONTRIBUTING.md](CONTRIBUTING.md). Donations are optional; the mod's features remain free.

## Development and validation

With Python and Lupa installed, run `python tests/run_tests.py`. The runner can also use a local `test-runtime` dependency directory, which is excluded from version control.

The current suite passes 1,528 checks in standard Lua and again with global `utf8` unavailable. It covers validation, formatting, mocked persistence and failure rollback, stable wrapper identities and repeated window opening/closing. Mock checks do not prove native rendering, serialization or leak-free operation. No per-frame polling, timers, subscriptions, network access or telemetry are used by the mod.

Game API/resource references include Urban Games' shipped bootstrap, GUI component and mod-specific GuiSaveData definitions. Third-party game resources and trademarks retain their respective ownership; MIT covers this project's original work. The game is required and is not included.

## Preview 6 image sizing fix

Preview 5 failed at startup because ImageView recipe size requires a native Vec2i, not a Lua table. Both seal images now use stylesheet sizing and AutoFit, following shipped GUI patterns. The mock rejects direct ImageView sizes to catch this regression. Currency logic and preferences are unchanged; native visual verification remains pending.

## Preview 8 integration helper

An explicit narrowMoney helper returns compact and full converted amounts from the same settings and year. It preserves the configured label, position, separators and precision without changing ordinary formatting. Third-party panels must opt in. Private local patches used during development are not included in this repository; Preview 8 alone does not retrofit those panels.
