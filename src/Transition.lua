local class = require "src.utils.MiddleClass"
local Logger = require "src.Utils.Logger"
local Node = require "src.Node"

--- The transition node is used in the State node to define the set of transitions from/to
--- other states in the same StateMachine node.
---@class Transition: Node
---@field onEvent string The behavior tree event which triggers the transition.
---@field to string The name of the State node to transition to.
local Transition = class('Transition', Node);

function Transition:_parseXmlNode(node, context)
    if node._name ~= self.class.name then
        Logger.error('Tried to parse an invalid node as a ' .. self.class.name .. ' node.');
    end

    if node._children.n ~= 0 then
        Logger.error('The Transition node cannot have children.');
    end

    if not node._attr or not node._attr.onEvent then
        Logger.error('The Transition node must have a onEvent attribute.');
    end

    if not node._attr or not node._attr.to then
        Logger.error('The Transition node must have a to attribute.');
    end

    self.onEvent = node._attr.onEvent;
    self.to = node._attr.to;
end

return Transition;