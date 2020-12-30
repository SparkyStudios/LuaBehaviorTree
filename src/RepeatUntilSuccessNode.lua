local class = require("src.Utils.MiddleClass");
local DecoratorNode = require("src.DecoratorNode");

--- Repeats the execution of the given child node until it returns `success()`
---@class RepeatUntilSuccessNode: DecoratorNode
---@field maxCount number The maximum allowed number of iterations.
local RepeatUntilSuccessNode = class('RepeatUntilSuccessNode', DecoratorNode);

function RepeatUntilSuccessNode:start()
    DecoratorNode.start(self);
    self._count = 0;
end

function RepeatUntilSuccessNode:failure()
    if self.maxCount > -1 and self._count == self.maxCount then
        self._parent:failure();
        self._count = 0;
    else
        self._parent:running();
        self._count = self._count + 1;
    end
end

function RepeatUntilSuccessNode:success()
    self._count = 0;
    self._parent:success();
end

--- Updates the `maxCount` value of this node.
---@param maxCount number The maximum number of iterations.
function RepeatUntilSuccessNode:setMaxCount(maxCount)
    self.maxCount = maxCount;
end

return RepeatUntilSuccessNode;