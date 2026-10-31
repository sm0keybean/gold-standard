# Contributing to Gold Standard

Bug reports, improvements and translations are welcome. Original project code and documentation use the MIT license; retain its copyright and permission notice when redistributing.

Describe a proposed change and its effect on players. Keep currency formatting separate from simulation balances and costs. Major-currency presets are editable formatting presets, not verified historical exchange rates.

Preserve the mod ID and compatibility with saved preferences. Avoid polling, repeated function wrapping and retained window state. Do not introduce dependencies on globals unavailable in the game's Lua sandbox, including utf8.

Run tests/run_tests.py with Python and Lupa installed. The test-runtime directory is an optional local dependency location and is excluded from version control. Also test changed UI behavior in-game on a duplicate save: mocks do not validate the native renderer or save serialization.

Include the game build, mod revision, steps to reproduce and relevant settings in bug reports. Share only necessary error excerpts with private information removed. Do not commit game files, saves, logs, credentials, dependency runtimes or generated archives.

Donations through https://ko-fi.com/smokeybean are voluntary and do not unlock features.
