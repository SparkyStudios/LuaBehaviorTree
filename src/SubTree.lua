local class = require('src.Utils.MiddleClass');
local Logger = require('src.Utils.Logger');

local Node = require('src.Node');

--- Adds a reference to a subtree in the behavior tree, to execute a same behavior
--- in many different parts of the tree.
---@class SubTree: Node
---@field ref string The id of the referenced subtree.
local SubTree = class('SubTree', Node);

function SubTree:start()
    if self._referencedNode == nil then
        self:_findReferencedNode();
    end

    self._referencedNode:start();
end

function SubTree:tick()
    if self._referencedNode == nil then
        self:_findReferencedNode();
    end

    self._referencedNode:tick();
end

function SubTree:finish()
    if self._referencedNode == nil then
        self:_findReferencedNode();
    end

    self._referencedNode:finish();
end

function SubTree:failure()
    if self._referencedNode == nil then
        self:_findReferencedNode();
    end

    self._referencedNode:failure()
end

function SubTree:running()
    if self._referencedNode == nil then
        self:_findReferencedNode();
    end

    self._referencedNode:running();
end

function SubTree:success()
    if self._referencedNode == nil then
        self:_findReferencedNode();
    end

    self._referencedNode:success();
end

function SubTree:setSubject(subject)
    if self._referencedNode == nil then
        self:_findReferencedNode();
    end

    self._referencedNode:setSubject(subject);
end

function SubTree:_setParent(parent)
    Node._setParent(self, parent);

    if self._referencedNode == nil then
        self:_findReferencedNode();
    end

    self._referencedNode:_setParent(parent);
end

function SubTree:_parseXmlNode(node, context)
    if node._name ~= self.class.name then
        Logger.error('Tried to parse an invalid node as a ' .. self.class.name .. ' node.');
    end

    if node._children.n ~= 0 then
        Logger.error('The ' .. self.class.name .. ' node cannot have children.');
    end

    if not node._attr or not node._attr.ref then
        Logger.error('The ' .. self.class.name .. ' node must have a name attribute.');
    end

    self.ref = node._attr.ref;
end

function SubTree:_findReferencedNode()
    local tree = self:getNearestBehaviorTreeNode();
    for key, value in pairs(tree.subtrees) do
        if key == self.ref then
            self._referencedNode = value;
            break;
        end
    end

    return self._referencedNode;
end

return SubTree;