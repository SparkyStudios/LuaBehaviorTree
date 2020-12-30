local class = require('src.Utils.MiddleClass');
local BranchNode  = require('src.BranchNode');

--- Selects randomly a node from its children and execute it.
---@class Random: BranchNode
local Random = class('Random', BranchNode)

function Random:tick()
  self._actualTask = math.floor(math.random() * #self.children + 1);
  BranchNode.tick(self);
end

function Random:success()
  BranchNode.success(self);
  self._parent:success();
end

function Random:failure()
  BranchNode.failure(self);
  self._parent:failure();
end

return Random;
