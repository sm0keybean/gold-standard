local runtime=ug_require "fairl_gold_standard::/gold/runtime.lua"
function data() return {install=function() runtime.bootstrap() end} end
