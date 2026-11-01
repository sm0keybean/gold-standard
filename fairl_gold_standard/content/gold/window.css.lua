local ssu=require "::/gui/main/stylesheetutil.lua"
function data()
    local result={}
    local add=ssu.makeAdder(result)
    local window="Window#fairl.goldstandard.settings"
    -- Shared Gold Standard palette. Native nine-patch surfaces keep rounded edges.
    local navy={0.055,0.080,0.110,1.0}
    local hover={0.100,0.135,0.165,1.0}
    local pressed={0.160,0.185,0.200,1.0}
    local gold={0.86,0.69,0.36,1.0}
    local lightGold={1.0,0.84,0.52,1.0}
    local muted={0.65,0.69,0.72,1.0}
    local surface={fileName="::/gui/builtin/button/default_surface.tga",horizontal={0,9,21,30},vertical={0,9,21,30}}
    local contour={fileName="::/gui/builtin/button/default_contour.tga",horizontal={0,9,21,30},vertical={0,9,21,30}}
    add("Button!goldstandard-launcher",{
        size={44,32},minSize={44,32},maxSize={44,32},padding={0,6,0,6},
        backgroundImage1=surface,borderImage=contour,backgroundColor1=navy,borderColor=gold})
    add("Button!goldstandard-launcher:hover",{backgroundColor1=hover,borderColor=lightGold})
    add("Button!goldstandard-launcher:active",{backgroundColor1=pressed,borderColor=lightGold})
    -- ImageView recipe size is native Vec2i; size images through styles instead.
    add("ImageView!goldstandard-launcher-image",{size={32,32},minSize={32,32},maxSize={32,32}})
    add("TextView!goldstandard-launcher-label",{color=gold,textAlignment={0.5,0.5},textAutoWrap=false})
    add("Button!goldstandard-launcher:hover TextView",{color=lightGold})
    add(window.." Window::Content",{size={740,-1},padding={12,12,12,12}})
    add(window.." ScrollArea!goldstandard-scroll",{size={710,590}})
    add(window.." BoxLayout",{innerSpacing={0,6}})
    add(window.." TextView",{textAutoWrap=true,maxSize={680,-1}})
    add(window.." TextInputField",{minSize={500,30}})
    add(window.." ComboBox",{minSize={500,30}})
    add(window.." BoxLayout!goldstandard-brand-header",{innerSpacing={12,0},padding={4,4,10,4}})
    add(window.." ImageView!goldstandard-brand-seal",{
        size={46,46},minSize={46,46},maxSize={46,46}})
    add(window.." TextView!goldstandard-brand-title",{color=gold,textAutoWrap=false})
    add(window.." TextView!goldstandard-brand-tagline",{color=muted})
    return result
end
