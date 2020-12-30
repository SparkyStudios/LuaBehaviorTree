local class = require('src.Utils.MiddleClass');
local DecoratorNode = require('src.DecoratorNode');

--- Forces the result of its child node to be `success()`.
--- If the child return `running()`, this node returns `running()` too.
---@class ForceSuccessNode: DecoratorNode
local ForceSuccessNode = class('ForceSuccessNode', DecoratorNode);

function ForceSuccessNode:success()
    self._parent:success();
end

function ForceSuccessNode:failure()
    self._parent:success();
end

return ForceSuccessNode;