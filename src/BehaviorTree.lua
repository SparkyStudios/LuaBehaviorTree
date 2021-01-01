local class = require('src.Utils.MiddleClass');
local Rx = require('src.Utils.Rx');
local EventEmitter = require('src.Utils.Events');
local XmlDomHandler = require 'src.Utils.XML.Dom'
local Xml2Lua = require 'src.Utils.XML.Xml2Lua'
local Logger = require "src.Utils.Logger"

local Registry = require('src.NodeRegistry');
local Node = require('src.Node');
local Action = require('src.Action');
local BranchNode = require "src.BranchNode"
local DecoratorNode = require "src.DecoratorNode"
local EmitEvent = require "src.EmitEvent"
local Fallback = require "src.Fallback"
local ForceSuccessNode = require "src.ForceSuccessNode"
local ForceFailureNode = require "src.ForceFailureNode"
local InvertorNode = require "src.InvertorNode"
local Random = require "src.Random"
local ReactiveFallback = require "src.ReactiveFallback"
local ReactiveSequence = require "src.ReactiveSequence"
local RepeatNode = require "src.RepeatNode"
local RepeatUntilFailureNode = require "src.RepeatUntilFailureNode"
local RepeatUntilSuccessNode = require "src.RepeatUntilSuccessNode"
local RetryNode = require "src.RetryNode"
local Sequence = require "src.Sequence"
local SequenceStar = require "src.SequenceStar"
local StateMachine = require "src.StateMachine"
local SubTree = require "src.SubTree"

--- Creates a new behavior tree.
---@class BehaviorTree: Node
---@field root Node The root node of the tree.
---@field properties table The table of mutable properties of this tree.
---@field events table The table of events registered to this tree.
---@field subtrees table The table of subtrees on this tree.
local BehaviorTree = class('BehaviorTree', Node);

BehaviorTree.Action = Action;
BehaviorTree.BranchNode = BranchNode;
BehaviorTree.DecoratorNode = DecoratorNode;
BehaviorTree.EmitEvent = EmitEvent;
BehaviorTree.Fallback = Fallback;
BehaviorTree.ForceFailureNode = ForceFailureNode;
BehaviorTree.ForceSuccessNode = ForceSuccessNode;
BehaviorTree.InvertorNode = InvertorNode;
BehaviorTree.Node = Node;
BehaviorTree.Registry = Registry;
BehaviorTree.Random = Random;
BehaviorTree.ReactiveFallback = ReactiveFallback;
BehaviorTree.ReactiveSequence = ReactiveSequence;
BehaviorTree.RepeatNode = RepeatNode;
BehaviorTree.RepeatUntilFailureNode = RepeatUntilFailureNode;
BehaviorTree.RepeatUntilSuccessNode = RepeatUntilSuccessNode;
BehaviorTree.RetryNode = RetryNode;
BehaviorTree.Sequence = Sequence;
BehaviorTree.SequenceStar = SequenceStar;
BehaviorTree.StateMachine = StateMachine;
BehaviorTree.SubTree = SubTree;

--- Parses an XML string to a valid behavior tree.
---@param xml string The XML string to parse.
function BehaviorTree.parseXMLString(xml)
    -- Parse the XML
    local handler = XmlDomHandler:new();
    handler.options = {};
    local parser = Xml2Lua.parser(handler);
    parser:parse(xml);

    -- Traverses the tree
    ---@type BehaviorTree
    local tree = BehaviorTree();
    tree:_parseXmlNode(handler.root, handler);

    return tree;
end

function BehaviorTree:initialize(config)
    Node.initialize(self, config);

    -- Ensures that properties field always have a value.
    if self.properties == nil then
        self.properties = {};
    end

    -- Ensures that events field always have a value.
    if self.events == nil then
        self.events = {};
    end

    -- Ensures that subtrees field always have a value.
    if self.subtrees == nil then
        self.subtrees = {};
    end

    self._propsSubject = Rx.BehaviorSubject.create();
    self._emitter = EventEmitter:new({
        _listeners = {},
        _events = {},
    });
end

function BehaviorTree:start()
    for _, value in ipairs(self.events) do
        if type(value) == "table" and value.name ~= nil then
            table.insert(self._emitter._events, value.name);
            if value.mode ~= nil then
                if value.mode == "once" then
                    self._emitter:once(value.name, function (...)
                        self:_onEventReceived(value.name, ...);
                    end);
                elseif value.mode == "on" then
                    self._emitter:on(value.name, function (...)
                        self:_onEventReceived(value.name, ...);
                    end);
                end
            else
                self._emitter:on(value.name, function (...)
                    self:_onEventReceived(value.name, ...);
                end);
            end
        elseif type(value) == "string"  then
            table.insert(self._emitter._events, value);
            self._emitter:on(value, function (...)
                self:_onEventReceived(value, ...);
            end);
        end
    end
    Node.start(self);
end

function BehaviorTree:tick(subject)
    Node.tick(self);

    if self._running then
        Node.running(self);
    elseif self.root ~= nil then
        self._running = true;
        self:setSubject(subject or self.subject);
        self._rootNode = Registry.getNode(self.root);
        self._rootNode:setSubject(self.subject);
        self._rootNode:_setParent(self);
        self._rootNode:start();
        self._rootNode:_callTick();
    end
end

function BehaviorTree:running()
    Node.running(self);
    self._running = false;
end

function BehaviorTree:success()
    self._rootNode:finish();
    self._running = false;
    Node.success(self);
end

function BehaviorTree:failure()
    self._rootNode:finish();
    self._running = false;
    Node.failure(self);
end

function BehaviorTree:finish()
    Node.finish(self);
    self._emitter:removeAllListeners();
end

function BehaviorTree:getNearestBehaviorTreeNode()
    return self;
end

--- Subcribes to changes on this behavior tree properties.
---@param onNext function The function called when the properties has been updated.
---@param onError function The function called when an error occurs while updateing the properties.
---@param onCompleted function The function called when the behavior tree is stopped, and no properties will be updated again.
function BehaviorTree:onPropertiesChange(onNext, onError, onCompleted)
    return self._propsSubject:subscribe(onNext, onError, onCompleted);
end

--- Defines the value of a behavior tree mutable property.
---@param name string The name of the property to update.
---@param value any The value of the property.
function BehaviorTree:setProperty(name, value)
    self.properties[name] = value;
    self._propsSubject:onNext(self.properties);
end

--- Returns the value of a behavior tree mutable property.
---@param name string The name of the property to retrieve.
---@return any The property value.
function BehaviorTree:getProperty(name)
    return self.properties[name];
end

--- Emits an event in this behavior tree.
---@param name string The name of the event to emit.
function BehaviorTree:emitEvent(name, ...)
    self._emitter:emit(name, ...);
end

--- Registers a callack executed when an event with the given name
--- is emitted during the execution of this behavior tree.
---@param name string The name of the event.
---@param callback function The function to execute each time the event is emitted.
---@param runFirst boolean Determines if the callback must be executed before others. Note that the callback with the highest priority is the last one registered with runFirst.
function BehaviorTree:onEventEmitted(name, callback, runFirst)
    if runFirst == nil then
        runFirst = false;
    end

    if self._emitter._listeners[name] == nil then
        self._emitter._listeners[name] = {};
    end

    if runFirst and #(self._emitter._listeners[name]) > 0 then
        table.insert(self._emitter._listeners[name], 1, callback);
    else
        table.insert(self._emitter._listeners[name], callback);
    end
end

function BehaviorTree:_parseXmlNode(node, context)
    if node._name == "BehaviorTree" then
        if node._children.n == 0 then
            Logger.error("Got an empty BehaviorTree node in XML.");
        end

        for i = 1, node._children.n, 1 do
            local current = node._children[i];

            -- If it's the list of properties
            if current._name == "Properties" then
                self:_parsePropertiesXmlNode(current, context);
            -- If it's the list of events
            elseif current._name == "Events" then
                self:_parseEventsXmlNode(current, context);
            -- If it's the list of subtrees
            elseif current._name == "SubTrees" then
                self:_parseSubTreesXmlNode(current, context);
            -- If it's the root node
            elseif current._name == "Root" then
                self:_parseRootXmlNode(current, context);
            -- No other node allowed
            else
                Logger.error("Unexpected node found as child of the BehaviorTree.");
            end
        end
    end
end

function BehaviorTree:_parsePropertiesXmlNode(node, context)
    for i = 1, node._children.n, 1 do
        local current = node._children[i];

        if current._name ~= "Property" then
            Logger.error("Invalid Properties node child. Only use Property nodes in the Properties node.");
        end

        if not current._attr or not current._attr.name then
            Logger.error("Invalid Property node encountered. Missing the name attribute.");
        end

        -- Register the property with a value of 0.
        self.properties[current._attr.name] = 0;
    end
end

function BehaviorTree:_parseEventsXmlNode(node, context)
    for i = 1, node._children.n, 1 do
        local current = node._children[i];
        local event = { mode = "on" };

        if current._name ~= "Event" then
            Logger.error("Invalid Events node child. Only use Event nodes in the Events node.");
        end

        if not current._attr or not current._attr.name then
            Logger.error("Invalid Event node encountered. Missing the name attribute.");
        end

        event.name = current._attr.name;

        if current._attr.mode ~= nil then
            event.mode = current._attr.mode;
        end

        -- Register the property with a nil value.
        table.insert(self.events, event);
    end
end

function BehaviorTree:_parseSubTreesXmlNode(node, context)
    local subTrees = {};

    for i = 1, node._children.n, 1 do
        local current = node._children[i];

        if current._name ~= "SubTree" then
            Logger.error("Encountered an unexpected node inside of a SubTrees list. Only SubTree nodes are allowed.");
        end

        if current._children.n ~= 1 then
            Logger.error("A SubTree node must contain only one child node.");
        end

        if not current._attr or not current._attr.id then
            Logger.error("A SubTree node must have an id attribute.");
        end

        local subTreeNode = current._children[1];
        local subTree = Node._parseXmlNode(self, subTreeNode, context);

        if subTree then
            subTree:_parseXmlNode(subTreeNode, context);
        end

        subTrees[current._attr.id] = subTree;
    end

    -- Register subtrees
    self.subtrees = subTrees;
end

function BehaviorTree:_parseRootXmlNode(node, context)
    if node._children.n > 1 then
        Logger.error("The Root node of a BehaviorTree must contain only one element.");
    end

    local current = node._children[1];
    local root = Node._parseXmlNode(self, current, context);

    if root then
        root:_parseXmlNode(current, context);
    end

    -- Register the root node
    self.root = root;
end

function BehaviorTree:_onEventReceived(event, ...)
    for key, value in pairs(self._emitter._listeners) do
        if key == event and type(value) == "table" then
            for _, func in ipairs(value) do
                if type(func) == "function" then
                    func(...);
                end
            end
            break;
        end
    end
end

return BehaviorTree;