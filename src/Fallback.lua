local class = require('src.Utils.MiddleClass');

local BranchNode = require('src.BranchNode');

--- Executes each child nodes sequentially until one node returns `success()`,
--- then, iteself returns `success()`. If every child nodes returns `failure()`,
--- the `Fallback` node returns `failure()`.
---@class Fallback: BranchNode
local Fallback = class('Fallback', BranchNode);

function Fallback:success()
    BranchNode.success(self);
    self._parent:success();
end

function Fallback:failure()
    BranchNode.failure(self);
    self._actualTask = self._actualTask + 1;
    if self._actualTask <= #self.children then
        self:_tick();
    else
        self._parent:failure();
    end
end

return Fallback;