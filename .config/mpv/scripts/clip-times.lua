-- Clip time recording script for mpv
-- Press 'c' three times to record start and end times to a file

local start_time = nil
local end_time = nil
local state = 0  -- 0: no time, 1: start recorded, 2: start+end recorded

function format_time(seconds)
   return string.format("%.3f", seconds)
end

function filepath()
   local realpath_cmd = string.format("realpath '%s'", mp.get_property("path"))
   local handle = io.popen(realpath_cmd)
   local result = handle:read("*a")
   handle:close()
   return result:match(".*")
end

function get_output_filename()
   local video_path = filepath()
   if not video_path then
      return nil
   end

   -- Remove extension and add -times.txt
   local base_name = video_path:match("(.+)%..+$") or video_path
   return base_name .. "-times.txt"
end

function record_clip_time()
   local current_time = mp.get_property_number("time-pos")

   if not current_time then
      mp.osd_message("Error: Cannot get playback time", 2)
      return
   end

   if state == 0 then
      -- Record start time
      start_time = current_time
      state = 1
      mp.osd_message(string.format("Clip start time: %s", format_time(start_time)), 2)

   elseif state == 1 then
      -- Record end time
      end_time = current_time
      state = 2
      mp.osd_message(string.format("Clip end time: %s\nPress 'c' again to save", format_time(end_time)), 3)

   elseif state == 2 then
      -- Save to file and reset
      local output_file = get_output_filename()

      if not output_file then
         mp.osd_message("Error: Cannot get filename", 2)
         state = 0
         start_time = nil
         end_time = nil
         return
      end

      local file = io.open(output_file, "a")
      if not file then
         mp.osd_message(string.format("Error: Cannot open file: %s", output_file), 3)
         state = 0
         start_time = nil
         end_time = nil
         return
      end

      file:write(format_time(start_time) .. "," .. format_time(end_time) .. "\n")
      file:close()

      mp.osd_message(string.format("Saved: %s,%s → %s",
                                   format_time(start_time),
                                   format_time(end_time),
                                   output_file), 3)

      -- Reset state
      state = 0
      start_time = nil
      end_time = nil
   end
end

function undo_clip_time()
   if state == 1 then
      -- Clear start time
      start_time = nil
      state = 0
      mp.osd_message("Cleared start time", 2)

   elseif state == 2 then
      -- Clear end time, keep start time
      end_time = nil
      state = 1
      mp.osd_message(string.format("Cleared end time (start: %s)", format_time(start_time)), 2)

   else
      -- state == 0, nothing to undo
      mp.osd_message("Nothing to undo", 1)
   end
end

-- Bind 'c' key to record function
mp.add_key_binding("c", "record-clip-time", record_clip_time)

-- Bind 'Shift+c' key to undo function
mp.add_key_binding("Shift+c", "undo-clip-time", undo_clip_time)
