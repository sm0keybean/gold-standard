local root=MOD_ROOT
local modules={}
local builtin
local native={moneyPrefix="$"}
local saved={}
local failSave=false
local logs={}
local function copy(c)
    if type(c)~="table" then return c end
    local r={} for k,v in pairs(c) do r[k]=copy(v) end return r
end
local states,stateIndex={},0
local windows={}
local react={}
function react.useState(initial)
    stateIndex=stateIndex+1
    if not states[stateIndex] then
        local s={value=initial}
        function s:old() return self.value end
        function s:set(v) self.value=v end
        states[stateIndex]=s
    end
    return states[stateIndex]
end
function react.RegisterWrapperRecipe(name,wrapped,fn) return fn end
function react.RegisterPluginRecipe(extension,name,fn) return fn end
builtin=setmetatable({type={Orientation={Vertical=1,Horizontal=2}}},{__index=function(t,key)
    local f=function(params) return {kind=key,p=params} end
    rawset(t,key,f);return f
end})
local windowApi={}
function windowApi.addSingletonWindow(recipe,params) windows[recipe]=params end
function windowApi.removeAllWindows(recipe) windows[recipe]=nil end
function ug_require(path)
    if path=="::/gui/main/react.lua" then return react end
    if path=="::/gui/main/builtin.lua" then return builtin end
    if path=="::/gui/main/game_react_globals.tl" then return {getDefaultWindowApi=function() return windowApi end} end
    if path=="::/gui/main/main_mod_button_area.tl" then return {MainModButtonAreaExtension={}} end
    if path=="::/gui/main/stylesheetutil.lua" then return {makeAdder=function(result) return function(selector,style) result[#result+1]={selector=selector,style=style} end end} end
    local relative=assert(path:match("^fairl_gold_standard::/(.+)$"),path)
    if modules[path]==nil then modules[path]=assert(loadfile(root.."/content/"..relative))() end
    return modules[path]
end
require=ug_require
api={
    engine={util={getYear=function() return 1920 end}},
    type={AppConfig={new=function(c) return copy(c) end}},
    util={
        getAppConfig=function() return copy(native) end,
        setAppConfig=function(c) native=copy(c) end,
        formatMoney=function(a) return "$"..tostring(a) end,
        formatMoneyAlt=function(a) return "$"..tostring(a) end,
        formatMoneyNumber=function(a) return tostring(a) end,
    },
    gui={game={
        getGuiSaveData=function(id) return copy(saved[id]) end,
        setGuiSaveData=function(id,c) if failSave then error("simulated save failure") end saved[id]=copy(c) end,
    }},
}
log={warning=function(s) logs[#logs+1]=s end,message=function(s) end}
local model=ug_require "fairl_gold_standard::/gold/model.lua"
local format=ug_require "fairl_gold_standard::/gold/format.lua"
local prefs=ug_require "fairl_gold_standard::/gold/preferences.lua"
local runtime=ug_require "fairl_gold_standard::/gold/runtime.lua"
local count=0
local function check(v) assert(v);count=count+1 end
local c=model.defaults()
check(format.money(1000,c,1900)=="GFr. 250")
check(format.money(1000,c,1919)=="GFr. 364")
check(format.money(1000,c,2000)=="GFr. 1,811")
c.inflation=0;c.decimals=2;c.label="₣"
check(format.money(1,c,1900)=="₣ 0.25")
check(format.money(-1,c,1900)=="₣ -0.25")
check(format.money(nil,c,1900)=="₣ ∞")
c.grouping="dot";check(format.money(10000,c,1900)=="₣ 2.500,00")
c.grouping="space";check(format.money(10000,c,1900)=="₣ 2 500.00")
c.grouping="none";c.position="suffix";check(format.money(10000,c,1900)=="2500.00 ₣")
c.compact=true;check(format.money(10000000,c,1900)=="2.50 M ₣")
c=model.defaults();c.inflation=-10;check(math.abs(model.rate(c,1901)-0.225)<1e-12)
c=model.defaults();check(math.abs(model.rate(c,1899)*1.02-0.25)<1e-12)
for _,bad in ipairs({"",string.rep("a",13),"bad\nlabel",string.char(255)}) do
    c=model.defaults();c.label=bad;check(model.validate(c)==nil)
end
-- Sandbox regression: validation must work even when _G.utf8 is absent.
for _,good in ipairs({"GFr.","₣","£","€","₹","漢字",string.rep("₣",12),"💰"}) do
    c=model.defaults();c.label=good;check(model.validate(c)~=nil)
end
for _,bad in ipairs({string.rep("₣",13),string.char(0x80),string.char(0xC0,0xAF),
    string.char(0xE0,0x80,0x80),string.char(0xED,0xA0,0x80),
    string.char(0xF0,0x80,0x80,0x80),string.char(0xF4,0x90,0x80,0x80),
    string.char(0xF5,0x80,0x80,0x80),string.char(0xE2,0x82),string.char(0xC2,0x41)}) do
    c=model.defaults();c.label=bad;check(model.validate(c)==nil)
end
for key,value in pairs({baseRate=0,baseYear=1900.5,inflation=-100,decimals=8,grouping="bad",position="bad",matchNative="yes"}) do
    c=model.defaults();c[key]=value;check(model.validate(c)==nil)
end
c=model.defaults();c.baseRate=0/0;check(model.validate(c)==nil)
for _,p in ipairs(model.presets) do
 for _,group in ipairs({"comma","dot","space","none"}) do
  for _,pos in ipairs({"prefix","suffix"}) do
   for decimals=0,4 do
    c=model.select(p.id,model.defaults());c.grouping=group;c.position=pos;c.decimals=decimals
    local normalized=assert(model.validate(c))
    check(type(format.money(1000000,normalized,1920))=="string")
   end
  end
 end
end
check(prefs.load().label=="GFr.")
runtime.bootstrap()
local getter=api.util.getAppConfig
local money=api.util.formatMoney
check(native.moneyPrefix=="game $ ")
c=model.defaults();c.label="Galactic";c.baseRate=4;c.inflation=0;c.position="suffix";c.decimals=2
check(runtime.apply(c,true))
check(api.util.formatMoney(10)=="40.00 Galactic")
check(api.util.formatMoneyNumber(10)=="40.00 Galactic")
check(api.util.getAppConfig().moneyPrefix=="")
check(saved[prefs.id].currency.label=="Galactic")
for i=1,1000 do check(runtime.apply(c,false)) end
check(api.util.getAppConfig==getter and api.util.formatMoney==money)
check(prefs.load().label=="Galactic")
failSave=true
local failed=model.defaults();failed.matchNative=true;failed.label="WRONG"
check(runtime.apply(failed,true)==nil)
check(native.moneyPrefix=="game $ ")
check(api.util.formatMoney(10)=="40.00 Galactic")
failSave=false
saved[prefs.id].currency.version=999
check(prefs.load().label=="GFr.")
saved[prefs.id]=nil
check(prefs.load().label=="GFr.")
-- Evaluate the supplied UI code and exercise callbacks, not native rendering.
assert(loadfile(root.."/content/gold/window.script.lua"))()
local toolbar=data().SettingsButton()
check(toolbar.kind=="BoxLayout")
local button=toolbar.p.children[1]
check(button.kind=="Button")
check(button.p.content.p.text=="GS")
check(button.p.meta.class=="goldstandard-launcher")
check(button.p.meta.tooltip=="Gold Standard — Currency Studio")
button.p.onClick()
local window,params=next(windows)
check(window~=nil)
local function render()
    stateIndex=0
    return window(params)
end
local function find(node,kind,label)
    if type(node)~="table" then return end
    if node.kind==kind and (not label or node.p.content and node.p.content.p and node.p.content.p.text==label) then return node end
    for _,v in pairs(node) do
        if type(v)=="table" then
            local found=find(v,kind,label)
            if found then return found end
        end
    end
end
local tree=render()
check(tree.kind=="Window")
find(tree,"TextInputField").p.onTyping("MyFr.")
tree=render()
check(find(tree,"TextInputField").p.value=="MyFr.")
find(tree,"Button","Apply to this save").p.onClick()
check(prefs.current().label=="MyFr.")
tree=render();find(tree,"TextInputField").p.onTyping("NotApplied")
tree=render();find(tree,"Button","Cancel / Close").p.onClick()
check(next(windows)==nil)
check(prefs.current().label=="MyFr.")
collectgarbage("collect")
local startMemory=collectgarbage("count")
for i=1,1000 do
    states={};button.p.onClick();window,params=next(windows);tree=render()
    find(tree,"Button","Cancel / Close").p.onClick()
end
tree=nil;states={};collectgarbage("collect")
local growth=collectgarbage("count")-startMemory
check(next(windows)==nil and growth<64)
assert(loadfile(root.."/content/gold/window.css.lua"))()
local styles=data()
check(type(styles)=="table")
local launcherStyle
for _,rule in ipairs(styles) do
    if rule.selector=="Button!goldstandard-launcher" then launcherStyle=rule.style end
end
check(launcherStyle and launcherStyle.size[1]==44 and launcherStyle.size[2]==32)
check(launcherStyle.maxSize[1]==44 and launcherStyle.maxSize[2]==32)
return count,growth
