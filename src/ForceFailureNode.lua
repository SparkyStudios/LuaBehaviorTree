local class = require('src.Utils.MiddleClass');
local DecoratorNode = require('src.DecoratorNode');
local Logger = require "src.Utils.Logger"

--- Forces the result of its child node to be `failure()`.
--- If the child return `running()`, this node returns `running()` too.
---@class ForceFailureNode: DecoratorNode
local ForceFailureNode = class('ForceFailureNode', DecoratorNode);

function ForceFailureNode:success()
    self._parent:failure();
end

function ForceFailureNode:failure()
    self._parent:failure();
end

return ForceFailureNode;