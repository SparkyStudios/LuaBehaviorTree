local class = require("src.Utils.middleclass");
local Logger = require "src.Utils.Logger";
local DecoratorNode = require("src.DecoratorNode");

--- Tick the child up to N times, as long as the child returns `success()`.
--- Interrupt the loop if the child returns `failure()` and, in that case, return `failure()` too.
--- If the child returns `running()`, this node returns `running()` too.
---@class RepeatNode: DecoratorNode
---@field count number The number of iterations.
local RepeatNode = class('RepeatNode', DecoratorNode);

function RepeatNode:start()
    DecoratorNode.start(self);
    self._countLeft = self.count;
end

function RepeatNode:success()
    if self._countLeft > 1 then
        self._parent:running();
        self._countLeft = self._countLeft - 1;
    else
        self._parent:success();
        self._countLeft = self.count;
    end
end

function RepeatNode:failure()
    self._parent:failure();
    self._countLeft = self.count;
end

--- Updates the `count` value of this node.
---@param count number The number of iterations.
function RepeatNode:setMaxCount(count)
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

    self:setMaxCount(node._attr.count);
end

return RepeatNode;