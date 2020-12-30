local class = require("src.utils.MiddleClass");
local Node = require("src.Node");
local Logger = require "src.Utils.Logger"

--- Emit an event registered to the behavior tree.
---@class EmitEvent: Node
---@field name string The name of the event.
local EmitEvent = class('EmitEvent', Node);

function EmitEvent:tick()
    if self.name == nil then
        self:failure();
    else
        local tree = self:getNearestBehaviorTreeNode();
        for _, value in ipairs(tree._emitter._events) do
            if value == self.name then
                tree:emitEvent(self.name);
                self:success();
                return;
            end
        end
        self:failure();
    end
end

function EmitEvent:_parseXmlNode(node, context)
    if node._name ~= self.class.name then
        Logger.error('Tried to parse an invalid node as a ' .. self.class.name .. ' node.');
    end

    if node._children.n ~= 0 then
        Logger.error('The EmitEvent node cannot have children.');
    end

    if not node._attr or not node._attr.name then
        Logger.error('The EmitEvent node must have a name attribute.');
    end

    self.name = node._attr.name;
end

return EmitEvent;