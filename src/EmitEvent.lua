local class = require("src.Utils.MiddleClass");
local Logger = require('src.Utils.Logger');

local Action = require("src.Action");

--- Emit an event registered to the behavior tree.
---@class EmitEvent: Action
---@field name string The name of the event.
local EmitEvent = class('EmitEvent', Action);

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
    if not node._attr or not node._attr.name then
        Logger.error('The EmitEvent node must have a name attribute.');
    end

    Action._parseXmlNode(self, node, context);
end

return EmitEvent;