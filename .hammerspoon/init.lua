local doubletap = require('double-tap')
doubletap.key = 'alt'

doubletap.action = function()
   local appName = 'WezTerm'
      local app = hs.application.get(appName)
   if app == nil or not app:isFrontmost() then
      hs.application.launchOrFocus(appName)
   elseif app:isFrontmost() then
      local wins = app:allWindows()
      if #wins > 0 then wins[#wins]:focus() end
   end
end

local lang = {
   ["en"] = 0x66,
   ["ja"] = 0x68,
}

local apps = {
   ["Alacritty"] = "en",
   ["WezTerm"] = "en",
   ["Slack"] = "ja",
}

local function setim(name, type_, obj)
   if apps[name] ~= nil and
      (type_ == hs.application.watcher.activated or
       type_ == hs.application.watcher.launched) then
      hs.eventtap.keyStroke({}, lang[apps[name]], 0)
   else
      print(name, type_, obj)
   end
 end

local appwatcher = hs.application.watcher.new(setim)
appwatcher:start()

hs.hotkey.bind({"cmd"}, "h", function() end)
