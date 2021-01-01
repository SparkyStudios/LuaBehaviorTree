local class = require("src.Utils.middleclass");

local DecoratorNode = require("src.DecoratorNode");

--- Tick the child up to N times, as long as the child returns `failure()`.
--- Interrupt the loop if the child returns `success()` and, in that case, return `success()` too.
--- If the child returns `running()`, this node returns `running()` too.
---@class RetryNode: DecoratorNode
---@field count number The number of tries.
local RetryNode = class('RetryNode', DecoratorNode);

function RetryNode:start()
    DecoratorNode.start(self);
    self._countLeft = self.count;
end

function RetryNode:failure()
    if self._countLeft > 1 then
        self._parent:running();
        self._countLeft = self._countLeft - 1;
    else
        self._parent:failure();
        self._countLeft = self.count;
    end
end

function RetryNode:success()
    self._parent:success();
    self._countLeft = self.count;
end

--- Updates the `count` value of this node.
---@param count number The number of tries.
function RetryNode:setMaxCount(count)
    self.count = count;
end

return RetryNode;