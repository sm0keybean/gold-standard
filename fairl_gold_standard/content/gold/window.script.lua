local react=ug_require "::/gui/main/react.lua"
local builtin=ug_require "::/gui/main/builtin.lua"
local globals=ug_require "::/gui/main/game_react_globals.tl"
local buttonArea=ug_require "::/gui/main/main_mod_button_area.tl"
local model=ug_require "fairl_gold_standard::/gold/model.lua"
local format=ug_require "fairl_gold_standard::/gold/format.lua"
local prefs=ug_require "fairl_gold_standard::/gold/preferences.lua"
local runtime=ug_require "fairl_gold_standard::/gold/runtime.lua"
local function text(s) return builtin.TextView{text=s} end
local SettingsWindow=react.RegisterWrapperRecipe("GoldStandardWindow",builtin.Window,function(params)
    local draft=react.useState(prefs.current())
    local status=react.useState("Changes are a preview until you press Apply.")
    local c=draft:old()
    local function change(key,value)
        local nextValue=model.copy(draft:old());nextValue[key]=value
        if key=="label" or key=="baseRate" then nextValue.preset="custom" end
        draft:set(nextValue);status:set("Preview only — press Apply to use these settings.")
    end
    local function combo(key,choices)
        local items={}
        for _,v in ipairs(choices) do items[#items+1]=builtin.ComboBoxItem{value=v[1],content=text(v[2])} end
        return builtin.ComboBox{value=c[key],items=items,onValueChange=function(v) change(key,v) end}
    end
    local function numeric(key,min,max,step)
        return builtin.DoubleSpinBox{value=c[key],min=min,max=max,step=step,onValueChange=function(v) change(key,v) end}
    end
    local presetItems={}
    for _,p in ipairs(model.presets) do presetItems[#presetItems+1]=builtin.ComboBoxItem{value=p.id,content=text(p.name)} end
    local children={
        builtin.BoxLayout{orientation=builtin.type.Orientation.Horizontal,meta={class="goldstandard-brand-header"},children={
            builtin.ImageView{path="fairl_gold_standard::/gold/seal-panel.tga",scaling=builtin.type.ImageViewScaling.AutoFit,meta={class="goldstandard-brand-seal"}},
            builtin.BoxLayout{orientation=builtin.type.Orientation.Vertical,children={
                builtin.TextView{text="GOLD STANDARD",meta={class="goldstandard-brand-title, font-scale-heading"}},
                builtin.TextView{text="Your world. Your currency.",meta={class="goldstandard-brand-tagline"}},
            }},
        }},
        text("Currency preset"),
        builtin.ComboBox{value=c.preset,items=presetItems,onValueChange=function(id)
            draft:set(model.select(id,draft:old()));status:set("Formatting preset selected. Check the editable conversion rate.")
        end},
        text("Presets supply labels, not historical exchange rates. Non-fictional labels start at 1:1."),
        text("Custom label (1–12 characters)"),
        builtin.TextInputField{value=c.label,maxLength=12,acceptOnFocusLoss=true,placeholderText="GFr., GVF, ₣…",
            onTyping=function(v) change("label",v) end,onValueChange=function(v) change("label",v) end},
        text("Chosen currency units per 1 game dollar in the base year"),numeric("baseRate",0.000001,1000000,0.01),
        text("Base year"),numeric("baseYear",1,9999,1),
        text("Annual fictional inflation / deflation (%)"),numeric("inflation",-20,20,0.25),
        text("Decimal places"),combo("decimals",{{0,"0 — whole units"},{1,"1"},{2,"2"},{3,"3"},{4,"4"}}),
        text("Number grouping"),combo("grouping",{{"comma","12,450.25"},{"dot","12.450,25"},{"space","12 450.25"},{"none","12450.25"}}),
        text("Currency label position"),combo("position",{{"prefix","Before amount"},{"suffix","After amount"}}),
        builtin.CheckBox{label="Compact amounts (K / M / B)",value=c.compact and 1 or 0,onValueChange=function(v) change("compact",v==1) end},
        builtin.CheckBox{label="Match native pop-up LABELS only (experimental)",value=c.matchNative and 1 or 0,
            meta={tooltip="Does not convert native construction/floating numbers. Off keeps these explicitly labeled game $."},
            onValueChange=function(v) change("matchNative",v==1) end},
        text("Native construction/floating NUMBERS are not converted. Game price adjustments remain."),
    }
    local valid,why=model.validate(c)
    local y=runtime.currentYear()
    if valid then
        local ok,preview=pcall(function()
            return "Preview · game $1,000 → "..format.money(1000,valid,y)
                .."   |   game $1,000,000 → "..format.money(1000000,valid,y)
                .."   |   Year "..y
        end)
        table.insert(children,2,text(ok and preview or ("Preview unavailable: "..tostring(preview))))
        table.insert(children,3,text("Base-year preview · game $1 → "..format.money(1,valid,valid.baseYear)))
    else table.insert(children,2,text("Check settings: "..why)) end
    children[#children+1]=text(status:old())
    children[#children+1]=builtin.BoxLayout{orientation=builtin.type.Orientation.Horizontal,children={
        builtin.Button{content=text("Apply to this save"),onClick=function()
            local ok,err=runtime.apply(draft:old(),true)
            status:set(ok and "Applied. Save your game to retain settings; reopen panels if a label is cached." or ("Not applied: "..tostring(err)))
        end},
        builtin.Button{content=text("Reset preview"),onClick=function() draft:set(model.defaults());status:set("Defaults previewed; Apply to commit.") end},
        builtin.Button{content=text("Cancel / Close"),onClick=params.onClose},
    }}
    return builtin.Window{title="Gold Standard: Currency Studio",id="fairl.goldstandard.settings",closable=true,movable=true,
        initialVisible=true,onClose=params.onClose,meta={class="goldstandard-window"},
        content=builtin.ScrollArea{meta={class="goldstandard-scroll"},content=builtin.Component{layout=builtin.BoxLayout{
            orientation=builtin.type.Orientation.Vertical,children=children}}}}
end)
local SettingsButton=react.RegisterPluginRecipe(buttonArea.MainModButtonAreaExtension,"GoldStandardSettingsButton",function()
    -- MainModButtonArea inserts plugin results into a BoxLayout: return a layout.
    return builtin.BoxLayout{orientation=builtin.type.Orientation.Vertical,children={
        builtin.Button{content=builtin.ImageView{path="fairl_gold_standard::/gold/seal-small.tga",scaling=builtin.type.ImageViewScaling.AutoFit,meta={class="goldstandard-launcher-image"}},
            meta={class="goldstandard-launcher",tooltip="Gold Standard: Currency Studio"},onClick=function()
            local windows=globals.getDefaultWindowApi()
            if windows then windows.addSingletonWindow(SettingsWindow,{onClose=function() windows.removeAllWindows(SettingsWindow) end}) end
        end},
    }}
end)
function data() return {SettingsButton=SettingsButton} end
