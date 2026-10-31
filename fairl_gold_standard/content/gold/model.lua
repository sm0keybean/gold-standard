local M = {}
M.presets = {
    {id="greifenvaud", name="Greifenvauder Franken", label="GFr.", rate=0.25},
    {id="usd", name="US dollar (USD)", label="US$", rate=1},
    {id="gbp", name="Pound sterling (GBP)", label="£", rate=1},
    {id="chf", name="Swiss franc (CHF)", label="CHF", rate=1},
    {id="eur", name="Euro (EUR; modern label)", label="€", rate=1},
    {id="jpy", name="Japanese yen (JPY)", label="¥", rate=1},
    {id="cad", name="Canadian dollar (CAD)", label="C$", rate=1},
    {id="aud", name="Australian dollar (AUD)", label="A$", rate=1},
    {id="cny", name="Chinese yuan (CNY)", label="CN¥", rate=1},
    {id="inr", name="Indian rupee (INR)", label="₹", rate=1},
    {id="custom", name="Create your own", label="GFr.", rate=0.25},
}
function M.defaults()
    return {version=1,preset="greifenvaud",label="GFr.",baseRate=0.25,baseYear=1900,
        inflation=2,decimals=0,grouping="comma",position="prefix",compact=false,matchNative=false}
end
function M.copy(c) local r={} for k,v in pairs(c) do r[k]=v end return r end
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
-- The game sandbox does not expose Lua's utf8 library. Validate UTF-8
-- directly, rejecting overlong encodings, surrogates, truncation and >U+10FFFF.
local function labelLength(s)
    if #s>48 then return nil end -- At most twelve four-byte code points.
    local i,count=1,0
    while i<=#s do
        local b=s:byte(i)
        local width
        if b<0x80 then width=1
        elseif b>=0xC2 and b<=0xDF then width=2
        elseif b>=0xE0 and b<=0xEF then width=3
        elseif b>=0xF0 and b<=0xF4 then width=4
        else return nil end
        if i+width-1>#s then return nil end
        for j=1,width-1 do
            local c=s:byte(i+j)
            if c<0x80 or c>0xBF then return nil end
        end
        local second=s:byte(i+1)
        if (b==0xE0 and second<0xA0) or (b==0xED and second>0x9F)
            or (b==0xF0 and second<0x90) or (b==0xF4 and second>0x8F) then return nil end
        count=count+1;i=i+width
    end
    return count
end
function M.validate(input)
    if type(input)~="table" then return nil,"Invalid settings." end
    local c=M.defaults()
    for k in pairs(c) do if input[k]~=nil then c[k]=input[k] end end
    if c.version~=1 then return nil,"Settings were written by an unsupported version." end
    if type(c.label)~="string" then return nil,"Enter a currency label." end
    c.label=c.label:match("^%s*(.-)%s*$")
    local n=labelLength(c.label)
    if not n or n<1 or n>12 or c.label:find("[%z\1-\31\127]") then
        return nil,"Use 1–12 characters without control characters."
    end
    if not finite(c.baseRate) or c.baseRate<0.000001 or c.baseRate>1000000 then return nil,"Conversion must be between 0.000001 and 1,000,000." end
    if not finite(c.baseYear) or c.baseYear%1~=0 or c.baseYear<1 or c.baseYear>9999 then return nil,"Base year must be a whole year from 1 to 9999." end
    if not finite(c.inflation) or c.inflation < -20 or c.inflation > 20 then return nil,"Annual inflation must be between -20% and 20%." end
    if not finite(c.decimals) or c.decimals%1~=0 or c.decimals<0 or c.decimals>4 then return nil,"Choose 0–4 decimal places." end
    if c.grouping~="comma" and c.grouping~="dot" and c.grouping~="space" and c.grouping~="none" then return nil,"Invalid number grouping." end
    if c.position~="prefix" and c.position~="suffix" then return nil,"Invalid label position." end
    if type(c.compact)~="boolean" or type(c.matchNative)~="boolean" then return nil,"Invalid checkbox setting." end
    local known=false for _,p in ipairs(M.presets) do if p.id==c.preset then known=true end end
    if not known then c.preset="custom" end
    return c
end
function M.select(id,current)
    local c=M.copy(current)
    for _,p in ipairs(M.presets) do
        if p.id==id then c.preset=id;c.label=p.label;c.baseRate=p.rate;return c end
    end
    return c
end
function M.rate(c,year)
    assert(finite(year) and year%1==0 and year>=1 and year<=9999,"Invalid game year")
    local r=c.baseRate*(1+c.inflation/100)^(year-c.baseYear)
    assert(finite(r) and r>0,"Currency rate out of range; reduce inflation or year span")
    return r
end
return M
