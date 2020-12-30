local class = require "src.utils.middleclass"

--- Handle logging in the framework, can be customized.
---@class Logger
local Logger = class('Logger');

Logger.errorFunc = error;
Logger.debugFunc = print;

--- Show an error message
---@param message string The message to display.
function Logger.error(message)
    Logger.errorFunc(message);
end

--- Show a debug/info message
---@param message string The message to display.
function Logger.debug(message)
    Logger.debugFunc(message);
end

return Logger;