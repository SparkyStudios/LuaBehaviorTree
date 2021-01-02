local class = require('src.Utils.MiddleClass');

local Fallback = require('src.Fallback');

--- Executes each child nodes sequentially until one node returns `success()`,
--- then, itself returns `success()`. If every child nodes returns `failure()`,
--- the `Fallback` node returns `failure()`. If a node returns `running()`,
--- the whole sequence is restarted.
---@class ReactiveFallback: Fallback
local ReactiveFallback = class('ReactiveFallback', Fallback);

function ReactiveFallback:running()
    self._running = false;
    self._actualTask = 1;
    self._parent:running();
end

return ReactiveFallback;