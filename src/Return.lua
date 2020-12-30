local class = require "src.Utils.MiddleClass"
local Action = require "src.Action"
local Logger = require "src.Utils.Logger"

--- Returns a specific result.
---@class Return: Action
---@field value '"success"'|'"failure"'|'"running"' The result to return.
local Return = class('Return', Action);

function Return:tick()
    if self.value == "success" then
        return self._parent:success();
    elseif self.value == "failure" then
        return self._parent:failure();
    elseif self.value == "running" then
        return self._parent:running();
    else
        return self._parent:success();
    end
end

function Return:_parseXmlNode(node, context)
    if node._name ~= self.class.name then
        Logger.error('Tried to parse an invalid node as a ' .. self.class.name .. ' node.');
    end

    if node._children.n ~= 0 then
        Logger.error('The Return node cannot have children.');
    end

    if not node._attr or not node._attr.value then
        Logger.error('The Return node must have a value attribute.');
    end

    self.value = node._attr.value;
end

return Return;