local Logger = require "src.Utils.Logger";
local class = require "src.Utils.MiddleClass";
local BranchNode = require "src.BranchNode";
local State = require "src.State";
local Transition = require "src.Transition"
local NodeRegistry = require "src.NodeRegistry"

--- The StateMachine is a composite node allowed to have one or more children. The children of a StateMachine node
--- must be of the type State.
--- Only one child at any given time is allowed to be run and the first one defined is the first one to be run.
--- The current status of a StateMachine node is the same as that of the child that is currently selected to be run.
---@class StateMachine: BranchNode
local StateMachine = class('StateMachine', BranchNode);

StateMachine.State = State;
StateMachine.Transition = Transition;

function StateMachine:initialize(config)
    BranchNode.initialize(self, config);

    self._actualTask = 1;
    self._states = {};
    self._needTransition = false;
    self._needSetupTransitions = true;

    for i, state in ipairs(self.children) do
        ---@type State
        state = NodeRegistry.getNode(state);
        if not state:isInstanceOf(State) then
            Logger.error('The StateMachine node can only have State nodes as children.');
        else
            self._states[state.name] = {node = state, index = i};
        end
    end
end

function StateMachine:start()
    BranchNode.start(self);
    if self._needSetupTransitions then
        for _, value in pairs(self._states) do
            for _, transition in ipairs(value.node.transitions) do
                self:_setupTransition(value.node, transition);
            end
        end
        self._needSetupTransitions = false;
    end
end

function StateMachine:success()
    if self._needTransition then
        self._needTransition = false;
        self._parent:running();
    else
        self._parent:success();
    end
end

function StateMachine:failure()
    if self._needTransition then
        self._needTransition = false;
        self._parent:running();
    else
        self._parent:failure();
    end
end

--- Setup a state transition.
---@param transition Transition The transition.
function StateMachine:_setupTransition(state, transition)
    if transition.onEvent ~= nil and transition.to ~= nil then
        local tree = self:getTopMostBehaviorTreeNode();
        tree:onEventEmitted(transition.onEvent, function ()
            local oldState = self.children[self._actualTask];
            if oldState.name == state.name then
                local newState = self._states[transition.to];
                -- oldState:finish();

                self._actualTask = newState.index;
                self._needTransition = true;

                self._running = false;
                -- newState.node:start();
                -- self:_tick();
            end
        end)
    else
        Logger.error('An error occured while parsing a Transition node of a StateMachine, some required fields are missing.');
    end
end

return StateMachine;