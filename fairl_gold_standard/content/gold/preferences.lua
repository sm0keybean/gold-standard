local model=ug_require "fairl_gold_standard::/gold/model.lua"
local M={id="fairl_gold_standard"}
local current=model.defaults()
function M.current() return model.copy(current) end
function M.load()
    local saved=api.gui.game.getGuiSaveData(M.id)
    if saved and saved.currency then
        local c,err=model.validate(saved.currency)
        if c then current=c else current=model.defaults();log.warning("Gold Standard: "..err) end
    else current=model.defaults() end
    return M.current()
end
function M.commit(c)
    local validated,err=model.validate(c)
    if not validated then return nil,err end
    local saved=api.gui.game.getGuiSaveData(M.id) or {}
    saved.currency=validated
    api.gui.game.setGuiSaveData(M.id,saved)
    current=validated
    return M.current()
end
return M

