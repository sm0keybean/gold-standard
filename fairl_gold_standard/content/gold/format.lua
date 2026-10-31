local model=ug_require "fairl_gold_standard::/gold/model.lua"
local M={}
function M.number(amount,c,year)
    if amount==nil then return "∞" end
    assert(type(amount)=="number" and amount==amount and math.abs(amount)<math.huge,"Invalid money amount")
    local value=math.abs(amount)*model.rate(c,year)
    local suffix=""
    if c.compact then
        if value>=1e9 then value=value/1e9;suffix=" B"
        elseif value>=1e6 then value=value/1e6;suffix=" M"
        elseif value>=1e3 then value=value/1e3;suffix=" K" end
    end
    local scale=10^c.decimals
    local rounded=math.floor(value*scale+0.5)
    assert(rounded<math.huge,"Displayed amount out of range")
    local digits=string.format("%."..c.decimals.."f",rounded/scale)
    local integer,fraction=digits:match("^(%d+)(.*)$")
    local sep=({comma=",",dot=".",space=" ",none=""})[c.grouping]
    if sep~="" then integer=integer:reverse():gsub("(%d%d%d)","%1"..sep):reverse():gsub("^"..(sep=="." and "%." or sep),"") end
    if c.grouping=="dot" then fraction=fraction:gsub("%.",",") end
    return (amount<0 and rounded~=0 and "-" or "")..integer..fraction..suffix
end
function M.money(amount,c,year)
    local n=M.number(amount,c,year)
    return c.position=="suffix" and (n.." "..c.label) or (c.label.." "..n)
end
return M
