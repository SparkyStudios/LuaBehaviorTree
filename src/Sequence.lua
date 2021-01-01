local class = require('src.Utils.MiddleClass');

local BranchNode = require('src.BranchNode');

--- Executes each child nodes sequentially until one node returns `failure()`,
--- or all nodes returns `success()`. If every child nodes returns `success()`,
--- the `Sequence` node returns `success()` too, otherwise returns `failure()`.
---@class Sequence: BranchNode
local Sequence = class('Sequence', BranchNode);

function Sequence:success()
    self._running = false;
    self._actualTask = self._actualTask + 1;
    if self._actualTask <= #self.children then
        self:_tick();
    else
        BranchNode.success(self);
        self._parent:success();
    end
end

function Sequence:failure()
    BranchNode.failure(self);
    self._parent:failure();
end

return Sequence;