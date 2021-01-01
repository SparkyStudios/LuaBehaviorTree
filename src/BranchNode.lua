local class = require('src.Utils.MiddleClass');
local Logger = require('src.Utils.Logger');

local Registry = require('src.NodeRegistry');
local Node = require('src.Node');

--- Represents a branch node of a behavior tree.
---@class BranchNode: Node
---@field children table
local BranchNode = class('BranchNode', Node);

function BranchNode:start()
    Node.start(self);
    if not self._running then
        self._actualTask = 1;
    end
end

function BranchNode:tick()
    if self._actualTask <= #self.children then
        Node.tick(self);
        self:_tick();
    end
end

function BranchNode:running()
    self._running = true;
    self._parent:running();
end

function BranchNode:success()
    self._running = false;
    if self._node then
        self._node:finish();
        self._node = nil;
    end
end

function BranchNode:failure()
    self._running = false;
    if self._node then
        self._node:finish();
        self._node = nil;
    end
end

--- Effectively ticks this branch node.
function BranchNode:_tick()
    if not self._running then
        self:_setCurrentNode(self._actualTask);
    end

    self._node:tick();
end

function BranchNode:_setCurrentNode(node)
    self._node = Registry.getNode(self.children[node]);
    self._node:_setParent(self);
    self._node:setSubject(self.subject);
    self._node:start();
end

function BranchNode:_parseXmlNode(node, context)
    if node._name ~= self.class.name then
        Logger.error('Tried to parse an invalid node as a ' .. self.class.name .. ' node.');
    end

    local children = {};

    for i = 1, node._children.n, 1 do
        local current = node._children[i];
        local child = Node._parseXmlNode(self, current, context);
        if child then
            child:_parseXmlNode(current, context);
            table.insert(children, child);
        end
    end

    self.children = children;
end

return BranchNode;