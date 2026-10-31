from pathlib import Path
import sys
root=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(root/'test-runtime'))
from lupa.lua54 import LuaRuntime
mod=root/'fairl_gold_standard'
for sandbox in (False,True):
    lua=LuaRuntime(unpack_returned_tuples=True)
    if sandbox:
        lua.execute('utf8 = nil')
    for p in mod.rglob('*.lua'):
        result=lua.eval('load')(p.read_text(encoding='utf-8-sig'),str(p))
        if isinstance(result,tuple): raise RuntimeError(result)
    lua.globals().MOD_ROOT=str(mod).replace('\\','/')
    checks,growth=lua.execute((root/'tests/test.lua').read_text(encoding='utf-8-sig'))
    mode='utf8 unavailable' if sandbox else 'standard Lua'
    print(f'PASS ({mode}): {checks} checks; mock window-cycle retained-memory delta {growth:.2f} KiB')
print('Native game rendering, save serialization and long-session memory remain unverified.')
