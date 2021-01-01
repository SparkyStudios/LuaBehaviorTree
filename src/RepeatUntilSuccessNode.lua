local class = require("src.Utils.MiddleClass");

local DecoratorNode = require("src.DecoratorNode");

--- Repeats the execution of the given child node until it returns `success()`
---@class RepeatUntilSuccessNode: DecoratorNode
---@field maxCount number The maximum allowed number of iterations.
local RepeatUntilSuccessNode = class('RepeatUntilSuccessNode', DecoratorNode);

function RepeatUntilSuccessNode:initialize(config)
    DecoratorNode.initialize(self, config);
    -- The maxCount defaults to an infinite loop.
    self.maxCount = -1;
end

function RepeatUntilSuccessNode:start()
    DecoratorNode.start(self);
    self._count = 1;
end

function RepeatUntilSuccessNode:failure()
    if self.maxCount > -1 and self._count == self.maxCount then
        self._count = 1;
        self._parent:failure();
    else
        self._count = self._count + 1;
        self._parent:running();
    end
end

function RepeatUntilSuccessNode:success()
    self._count = 1;
    self._parent:success();
end

--- Updates the `maxCount` value of this node.
---@param maxCount number The maximum number of iterations.
function RepeatUntilSuccessNode:setMaxCount(maxCount)
    if type(maxCount) == "string" then
        self.maxCount = tonumber(maxCount);
    elseif type(maxCount) == "number" then
        self.maxCount = maxCount;
    end
end

return RepeatUntilSuccessNode;