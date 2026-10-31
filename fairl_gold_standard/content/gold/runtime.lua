local model=ug_require "fairl_gold_standard::/gold/model.lua"
local format=ug_require "fairl_gold_standard::/gold/format.lua"
local prefs=ug_require "fairl_gold_standard::/gold/preferences.lua"
local M={}
local active=model.defaults()
local originals
local warned=false
local function year() return api.engine.util.getYear() end
local function safeNumber(amount,withLabel)
    local ok,result=pcall(function()
        return withLabel and format.money(amount,active,year()) or format.number(amount,active,year())
    end)
    if ok then return result end
    if not warned then log.warning("Gold Standard display fallback: "..tostring(result));warned=true end
    if amount==nil then return "∞" end
    -- Never relabel an unconverted fallback amount as the custom currency.
    return "game $ "..tostring(amount)
end
local function install()
    if originals then return end
    local u=api.util
    local old={money=u.formatMoney,alt=u.formatMoneyAlt,number=u.formatMoneyNumber,config=u.getAppConfig}
    local ok,err=pcall(function()
        u.formatMoney=function(a) return safeNumber(a,true) end
        u.formatMoneyAlt=function(a) return safeNumber(a,true) end
        u.formatMoneyNumber=function(a) return safeNumber(a,active.position=="suffix") end
        u.getAppConfig=function()
            local c=api.type.AppConfig.new(old.config())
            c.moneyPrefix=active.position=="prefix" and active.label or ""
            return c
        end
    end)
    if not ok then
        u.formatMoney,u.formatMoneyAlt=old.money,old.alt
        u.formatMoneyNumber,u.getAppConfig=old.number,old.config
        error(err)
    end
    originals=old
end
local function nativePrefix(c)
    local get=originals and originals.config or api.util.getAppConfig
    local before=api.type.AppConfig.new(get())
    local nextConfig=api.type.AppConfig.new(before)
    nextConfig.moneyPrefix=c.matchNative and (c.label.." ") or "game $ "
    api.util.setAppConfig(nextConfig,false)
    assert(get().moneyPrefix==nextConfig.moneyPrefix,"Native prefix readback failed")
    return before
end
function M.currentYear()
    local ok,y=pcall(year)
    return ok and y or active.baseYear
end
function M.apply(input,persist)
    local c,err=model.validate(input)
    if not c then return nil,err end
    local rateOk,rateError=pcall(model.rate,c,M.currentYear())
    if not rateOk then return nil,tostring(rateError) end
    local previous=model.copy(active)
    local nativeBefore
    local ok,failure=pcall(function()
        install()
        nativeBefore=nativePrefix(c)
        if persist then
            local saved,saveError=prefs.commit(c)
            assert(saved,saveError)
        end
        active=c;warned=false
    end)
    if not ok then
        active=previous
        if nativeBefore then pcall(api.util.setAppConfig,nativeBefore,false) end
        return nil,tostring(failure)
    end
    return true
end
function M.bootstrap()
    local ok,err=pcall(function()
        local c=prefs.load()
        local applied,why=M.apply(c,false)
        assert(applied,why)
    end)
    if not ok then log.warning("Gold Standard initialization warning: "..tostring(err))
    else log.message("Gold Standard ready; open its mod-area button to configure") end
end
return M
