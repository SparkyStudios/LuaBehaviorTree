local class = require "src.utils.MiddleClass";
local DecoratorNode = require "src.DecoratorNode";

--- The State node is the basic block of a StateMachine node. Each State node must have a BehaviorTree node and may
--- also have a Transitions block.
--- A State node runs the content of its BehaviorTree node and can transition to another state (or itself) as
--- specified in the Transitions block.
--- If a State node transitions into itself while running, it will first be terminated, re-initialized, and then
--- updated again.
---@class State: DecoratorNode
---@field name string The name of the state. It must be unique for the scope of the StateMachine node.
---@field transitions Transition[] The array of Transition nodes.
---@field child BehaviorTree The sub behaviour tree that this state executes.
local State = class('State', DecoratorNode);

function State:failure()
    self._parent:failure();
end

function State:success()
    self._parent:success();
end

return State;