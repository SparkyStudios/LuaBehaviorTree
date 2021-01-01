--- Effectively stores the list of registered nodes.
local _REGISTERED_NODES = {};

--- Registers and manage registered nodes.
---@class Registry
local Registry = {};

--- Registers a node with the given id.
---@param id string
---@param node Node
function Registry.register(id, node)
    _REGISTERED_NODES[id] = node;
end

--- Unregisters a node with the given id.
---@param id string
function Registry.unregister(id)
    _REGISTERED_NODES[id] = nil;
end

--- Checks if a node with the given id is registered.
---@param id string The node identifier to check.
function Registry.registered(id)
    return _REGISTERED_NODES[id] and true or false;
end

--- Returns the registered node with the given id.
---@param id string|Node
function Registry.getNode(id)
    local Node = require('src.Node');

    if type(id) == 'string' then
        local node = _REGISTERED_NODES[id];
        return Node.static.isSubclassOf(node, Node) and node:new() or node;
    else
        return id;
    end
end

return Registry;
