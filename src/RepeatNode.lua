local class = require("src.Utils.middleclass");
local Logger = require('src.Utils.Logger');

local DecoratorNode = require("src.DecoratorNode");

--- Tick the child up to N times, whatever the child returns `success()` or `failure()` on each iteration.
--- If the child returns `running()`, this node returns `running()` too.
---@class RepeatNode: DecoratorNode
---@field count number The number of iterations.
local RepeatNode = class('RepeatNode', DecoratorNode);

function RepeatNode:start()
    DecoratorNode.start(self);
    self._count = 1;
end

function RepeatNode:success()
    self:_iterate()
end

function RepeatNode:failure()
    self:_iterate()
end

--- Updates the `count` value of this node.
---@param count number The number of iterations.
function RepeatNode:setCount(count)
    if type(count) == "string" then
        self.count = tonumber(count);
    elseif type(count) == "number" then
        self.count = count;
    end
end

function RepeatNode:_parseXmlNode(node, context)
    DecoratorNode._parseXmlNode(self, node, context);

    if not node._attr or not node._attr.count then
        Logger.error('The RepeatNode node must have a count attribute.');
    end

    self:setCount(node._attr.count);
end

function RepeatNode:_iterate()
    if self._count < self.count then
        self._count = self._count + 1;
        self._parent:running();
    else
        self._count = 0;
        self._parent:success();
    end
end

return RepeatNode;