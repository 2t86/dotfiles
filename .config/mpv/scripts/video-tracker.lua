local utils = require 'mp.utils'

local function load_config()
   local config = {
      db_path = os.getenv("HOME") .. "/.video-tracker/tracker.sqlite",
      mark_threshold = 80
   }

   local config_file = os.getenv("HOME") .. "/.video-tracker/config"
   local f = io.open(config_file, "r")
   if f then
      for line in f:lines() do
         if not line:match("^%s*#") and not line:match("^%s*$") then
            local key, value = line:match("^([%w_]+)%s*=%s*(.+)$")
            if key and value then
               value = value:gsub("%$HOME", os.getenv("HOME"))
               value = value:gsub('"', ''):gsub("'", '')

               if key == "DB_PATH" then
                  config.db_path = value
               elseif key == "MARK_THRESHOLD" then
                  config.mark_threshold = tonumber(value) or 80
               end
            end
         end
      end
      f:close()
   end

   return config
end

local config = load_config()
local db_path = config.db_path
local mark_threshold = config.mark_threshold

function filepath()
   local realpath_cmd = string.format("realpath '%s'", mp.get_property("path"))
   local handle = io.popen(realpath_cmd)
   local result = handle:read("*a")
   handle:close()
   return result:match(".*")
end

function mark_video(status, progress)
   local path = filepath()
   if not path or path:match("^http") then return end

   if not path:match("^/") then
      path = utils.join_path(mp.get_property("working-directory"), path)
   end

   local cmd = string.format(
      "sqlite3 '%s' \"INSERT OR REPLACE INTO videos (path, status, progress, updated_at) VALUES ('%s', '%s', %f, datetime('now'));\"",
      db_path, path:gsub("'", "''"), status, progress
   )
   os.execute(cmd)
   mp.osd_message(string.format("set %s at %s", status, path), 0)
end

function set_watched(_, pos)
   if pos and pos >= mark_threshold then
      mark_video("watched", pos)
   end
end

function set_unwatched()
   local path = filepath()
   if path and not path:match("^http") then
      if not path:match("^/") then
         path = utils.join_path(mp.get_property("working-directory"), path)
      end
      local check_cmd = string.format(
         "sqlite3 '%s' \"SELECT COUNT(*) FROM videos WHERE path='%s';\"",
         db_path, path:gsub("'", "''")
      )
      local handle = io.popen(check_cmd)
      local result = handle:read("*a")
      handle:close()

      if result:match("^0") then
         mark_video("unwatched", 0)
      end
   end
end

mp.observe_property("percent-pos", "number", set_watched)
mp.register_event("file-loaded", set_unwatched)
mp.msg.info("Video tracker loaded: DB=" .. db_path .. ", Threshold=" .. mark_threshold .. "%")
