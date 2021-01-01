local class = require('src.Utils.MiddleClass');

local Sequence = require('src.Sequence');

--- Executes each child nodes sequentially until one node returns `fail()`,
--- or all nodes returns `success()`. If every child nodes returns `success()`,
--- the `ReactiveSequence` node returns `success()` too, otherwise returns `fail()`.
--- If a node returns `running()`, the `ReactiveSequence` node will restart the sequence.
---@class ReactiveSequence: Sequence
local ReactiveSequence = class('ReactiveSequence', Sequence);

function ReactiveSequence:running()
    self._running = true;
    self._actualTask = 1;
    self._parent:running();
end

return ReactiveSequence;