local alert = require('hs.alert')
local timer = require('hs.timer')
local eventtap = require('hs.eventtap')
local events = eventtap.event.types

local module = {}

module.timeFrame = 0.5

module.key = 'ctrl'

local noflag = function(ev)
   for k, v in pairs(ev:getFlags()) do
      if v then return false end
   end
   return true
end

local tapKey = function(ev)
   for k, v in pairs(ev:getFlags()) do
      if k ~= module.key and v then return false end
   end
   return true
end

module.action = function()
   alert('You double tapped', module.key)
end

local tapStart, tap1, tap2 = 0, false, false

local reset = function()
   tapStart, tap1, tap2 = 0, false, false
end

module.eventWatcher = eventtap.new({events.flagsChanged, events.keyDown}, function(ev)
      if (timer.secondsSinceEpoch() - tapStart) > module.timeFrame then
         reset()
      end
      if ev:getType() == events.flagsChanged then
         if noflag(ev) and tap1 and tap2 then
            if module.action then module.action() end
            reset()
         elseif tapKey(ev) and not tap1 then
            tap1 = true
            tapStart = timer.secondsSinceEpoch()
         elseif tapKey(ev) and tap1 then
            tap2 = true
         elseif not noflag(ev) then
            reset()
         end
      else
         reset()
      end
      return false
end)

module.eventWatcher:start()

return module
