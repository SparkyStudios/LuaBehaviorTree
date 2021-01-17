# LuaBehaviorTree

A strong implementation of a BehaviorTree system in pure Lua, useful for implementing Artificial Intelligence in many domains (robotic, games, etc...), and with support of XML language.

## Installation

You just need to clone or download this project as zip to get the source files. Once you have these sources somewhere in your project, import the `/LuaBehaviorTree/src/BehaviorTree.lua` file, or just the `/LuaBehaviorTree/src` directory (only if you have `?/init.lua` in your search path.) where you want to use the library.

```lua
local BehaviorTree = require "LuaBehaviorTree.src.BehaviorTree";
```

## Getting Started

> TODO

## API

This BehaviorTree implementation comes with a predefined set of nodes, which are largely sufficient to build any custom nodes.

### Abstract Nodes

- `Node`: The base implementation of every nodes.
- `Action`: The base implementation of every leaf nodes (actions).
- `BranchNode`: The base implementation of every branch nodes.
- `DecoratorNode`: The base implementation of every decorator nodes.

### Leaf Nodes

- `EmitEvent`: A node used to emit a specific event giving its name. Returns `success` when the event is emitted, and `failure` otherwise.
- `Return`: A node used to return a value (`success`, `failure`, or `running`) directly in the behavior tree.

### Branch Nodes

- `Fallback`: A node which executes sequentially all of its children until one of then return a `success` state. Returns `success` if one of its children returns `success`, returns `failure` if all children has returned `failure`, returns `running` if the current executing child returns `running`.
- `Random`: A node which pick randomly only one of its children and execute it. Returns the same result as the executing child.
- `ReactiveFallback`: A node which executes each child nodes sequentially until one node returns `success`, then, itself returns `success`. If every child nodes returns `failure`, the `ReactiveFallback` node returns `failure`. If a node returns `running`, the whole sequence is restarted to the first child.
- `ReactiveSequence`: A node which executes each child nodes sequentially until one node returns `failure`, or all nodes returns `success`. If every child nodes returns `success`, the `ReactiveSequence` node returns `success` too, otherwise `failure`. If a node returns `running`, the whole sequence is restarted to the first child.
- `Sequence`: A node which executes each child nodes sequentially until one node returns `failure`, or all nodes returns `success`. If every child nodes returns `success`, the `Sequence` node returns `success` too, otherwise returns `failure`.
- `SequenceStar`: A `Sequence` node used when you don't want to tick children again that already returned `success`.

### Decorator Nodes

- `ForceFailureNode`: A node which will always return `failure` whatever its child node returns.
- `ForceSuccessNode`: A node which will always return `success` whatever its child node returns.
- `InvertorNode`: A node which will return `success` when its child returns `failure`, and `failure` when its child return `success`. This node will return `running` if its child returns `running`.
- `RepeatNode`: A node which will repeat the execution of its child for a given number of times. Returns `success` when it reach the given amount of iterations, and `running` if its child returns `running` during an iteration.
- `RepeatUntilFailureNode`: A node which will repeat for a maximum number of times the execution of its child until this last one returns `failure`. If the child node return `failure` before the maximum iteration count is reached, the `RepeatUntilFailureNode` returns `success`, otherwise returns `failure`.
- `RepeatUntilSuccessNode`: A node which will repeat for a maximum number of times the execution of its child until this last one returns `success`. If the child node return `success` before the maximum iteration count is reached, the `RepeatUntilSuccessNode` returns `success`, otherwise returns `failure`.

### StateMachine Nodes

- `StateMachine`: The `StateMachine` node is a composite node allowed to have one or more children. The children of a `StateMachine` node must all be `State` nodes. Only one `State` node is allowed to run at a time and the first one defined (the first child node) is the first one to run. The current status of a `StateMachine` node is the same as the child that is currently selected to run.
- `State`: The `State` node is the basic block of a `StateMachine` node. Each `State` node must have a `BehaviorTree` node and may also have a `Transitions` block. A `State` node runs the content of its `BehaviorTree` node and can _transit_ to another state (or itself) as specified in the `Transitions` block. If a `State` node transits into itself while running, it will first be terminated, re-initialized, and then updated again.
- `Transition`: The `Transition` node is used in the `State` node to define the set of transitions from/to other states in the same parent `StateMachine` node.

### BehaviorTree Nodes

- `BehaviorTree`: The topmost node of each behavior tree created using this library. Can only have one root node, and may content a set of **properties**, **events**, and **subtrees**.
- `Events` (**XML only**): A node having a set of `Event` nodes.
- `Event` (**XML only**): A node used to create a behavior tree event.
- `Properties` (**XML only**): A node having a set of `Property` nodes.
- `Property` (**XML only**): A node used to create a behavior tree property.
- `Root` (**XML only**): A node used to define the root node of the behavior tree. Can only have one child.
- `SubTrees` (**XML only**): A node having a set of `SubTree` nodes.
- `SubTree`: A node used to create a behavior tree subtree. Since this node can be used outside of an XML context, it's mostly useful (and also makes sense) in XML to create a composite node using other nodes.
