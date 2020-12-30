-- Only works if the search path contains `?\init.lua`
local _PACKAGE = string.gsub(..., "%.", "/") or "";
return require(_PACKAGE .. '/BehaviorTree');
