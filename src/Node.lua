local class = require('src.Utils.MiddleClass');
local Logger = require('src.Utils.Logger');

local Registry = require('src.NodeRegistry');

--- Represents a basic node without functionalities in a behavior tree.
---@class Node: MiddleClass
---@field id string The node unique identifier.
---@field subject any The subject acting in this node. In game engines, this value can have the game entity.
local Node = class('Node');

---Initializes the Node instance.
---@param config table
function Node:initialize(config)
    config = config or {};
    for k, v in pairs(config) do
        self[k] = v;
    end

    if self.id ~= nil then
        Registry.register(self.id, self);
    end
end

--- Starts the node execution.
--- This function is called just before `tick()`.
--- If `tick()` returns `running()`, then on the next tick `start()` will be skipped.
function Node:start()
    self:onStart();
end

--- Ticks the node execution.
--- This function must return `success()`, `failure()`, or `running()`.
function Node:tick()
    self:onTick();
end

--- Finishes the node execution.
--- This function is called just after `tick()` only when this last returns `success()` or `failure()`.
function Node:finish()
    self:onFinish();
end

--- Executes a callback when the node `start()`.
function Node:onStart()
end

--- Executes a callback when a node `tick()` occurs.
function Node:onTick()
end

--- Executes a callback when the node `finish()`.
function Node:onFinish()
end

--- Returns a running node state.
function Node:running()
    if self._parent then
        self._parent:running();
    end
end

--- Returns a success node state.
function Node:success()
    if self._parent then
        self._parent:success();
    end
end

--- Returns a failure node state.
function Node:failure()
    if self._parent then
        self._parent:failure();
    end
end

--- Move upwards the tree to find and return the nearest behavior tree node.
---@return BehaviorTree
function Node:getNearestBehaviorTreeNode()
    return self._parent and self._parent:getNearestBehaviorTreeNode() or self;
end

--- Move upwards the tree to find and return the top most behavior tree node.
---@return BehaviorTree
function Node:getTopMostBehaviorTreeNode()
    return self._parent and self._parent:getTopMostBehaviorTreeNode() or self;
end

--- Defines the subject of this node.
---@param subject any
function Node:setSubject(subject)
    self.subject = subject;
end

--- Run a node's tick.
function Node:_callTick()
    SUCCESS = function()
        self:success();
    end

    FAILURE = function()
        self:failure();
    end

    RUNNING = function()
        self:running();
    end

    self:tick();

    SUCCESS, FAILURE, RUNNING = nil, nil, nil;
end

--- Sets the active node
---@param parent Node
function Node:_setParent(parent)
    self._parent = parent;
end

--- Parses an XML node to extract required data to build this behavior tree node.
---@param node table The XML node to parse.
---@param context any The XML parser context.
function Node:_parseXmlNode(node, context)
    local BehaviorTree = require('src.BehaviorTree');

    -- Checks if it's a predefined node
    if BehaviorTree[node._name] ~= nil then
        return BehaviorTree[node._name]:new();
    -- Checks if it's a registered node
    elseif Registry.registered(node._name) then
        return Registry.getNode(node._name);
    -- The node is not defined...
    else
        Logger.error("Undefined node encountered: " .. node._name .."."); -- TODO: Create an Nodes/Behaviors nodes ?
    end

    return nil;
end

return Node;
