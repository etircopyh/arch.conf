local msg = require "mp.msg"
local utils = require "mp.utils"
local options = require "mp.options"

local is_windows = package.config:sub(1, 1) == "\\"

-- Global variables
local win_userprofile = os.getenv("USERPROFILE")


local o = {
  paths = {
      ffmpeg_path = "ffmpeg",
      win_target_dir = string.format("%s\\Videos\\", win_userprofile),
      unix_target_dir = "~/Videos/",
  },
  encoding = {
      vcodec = "h264",
      vbitrate = "3000k",
      acodec = "aac",
      abitrate = "256k",
      copy_audio = true,
      embed_subs = true,
      fps = "30",
      ffmt = "mp4",
      cut_pos = nil,
  },
  youtube = {
      max_quality = "1080",
      dlp_args = {},
  },
  flags = {
      overwrite = false,
      copy_override = false,
      debug = true,
  }
}

-- Set target directory based on OS
o.target_dir = is_windows and o.paths.win_target_dir or o.paths.unix_target_dir
options.read_options(o)

-- Command object for running subprocesses
local Command = {}
Command.__index = Command

function Command:new(name)
  local o = { name = name or "", args = { name or "" } }
  setmetatable(o, self)
  return o
end

function Command:arg(...)
  for _, v in ipairs({ ... }) do
    table.insert(self.args, v)
  end
  return self
end

function Command:validate()
  if not self.name or #self.args < 1 then
      return false, "Invalid command configuration"
  end
  return true
end

function Command:run()
  local valid, err = self:validate()
  if not valid then
    msg.error(err)
    return { success = false, error = err }
  end
  if o.flags.debug then
    local cmd_line = table.concat(self.args, " ")
    msg.info("Executing command: " .. cmd_line)
  end

  local res = mp.command_native({
    name = "subprocess",
    args = self.args,
    capture_stdout = true,
    capture_stderr = true,
  })
  return {
    success = res and res.status == 0,
    output = res and res.stdout or "",
    error = res and res.stderr or "",
    status = res and res.status or -1,
  }
end

-- Utility functions
local function sanitize_filename(name)
  -- Replace invalid characters for Windows
  local sanitized = name:gsub("[<>:\"/\\|?*]", "_")
  -- Replace multiple spaces or underscores with a single underscore
  :gsub("[%s_]+", "_")
  -- Remove leading and trailing underscores or dots
  :gsub("^[_%.]+", ""):gsub("[_%.]+$", "")
  -- Trim the length to 255 characters
  :sub(1, 255)
  return sanitized
end

local function get_property(prop, default)
  return mp.get_property(prop, default or "")
end

local function get_property_number(prop, default)
  return mp.get_property_number(prop, default or 0)
end

local function osd(str)
  mp.osd_message(str, 3)
end

local function info(msg_str)
  msg.info(msg_str)
  osd(msg_str)
end

local function timestamp(duration)
  local hours = math.floor(duration / 3600)
  local minutes = math.floor((duration % 3600) / 60)
  local seconds = duration % 60
  return string.format("%02d:%02d:%06.3f", hours, minutes, seconds)
end

local function is_remote()
  return get_property("path"):match("://") ~= nil
end

local function get_outname(shift, endpos)
    local name = get_property("filename/no-ext")
    if is_remote() then
      name = get_property("media-title") or name
    end
    local outname = string.format("%s_%s-%s.%s", name, timestamp(shift), timestamp(endpos), o.encoding.ffmt)

    -- Use the sanitize_filename function
    local sanitized_outname = utils.join_path(o.target_dir, sanitize_filename(outname))

    local resolved_outpath = mp.command_native({ "expand-path", sanitized_outname })

    if o.flags.debug then
      msg.info("Resolved output path: " .. resolved_outpath)
    end

    return resolved_outpath
end

-- Subtitles
local embed_subs = o.encoding.embed_subs
        and get_property("sub-visibility") == "yes"
        and get_property_number("sub") > 0

local function sub_location()
  if embed_subs then
      local sub_file = mp.get_property_native("current-tracks/sub/external-filename")
      if not sub_file then
          sub_file = get_property("stream-open-filename")
      end
      -- Escape or quote the path for FFmpeg
      return string.format("subtitles='%s'", sub_file:gsub("'", "\\'"))
  end
  return nil
end

local function enable_subs(shift)
    if embed_subs then
        if is_remote() then
            return { "--write-sub", "--write-auto-sub", "--sub-lang", "en", "--embed-subs" }
        else
            local sub_file = sub_location()
            if sub_file then return { "-copyts", "-ss", tostring(shift), "-vf", sub_file } end
        end
    end
    return nil -- No valid subtitles to process
end

local function get_source_fps(inpath)
  local command = Command:new("ffprobe")
      :arg("-v", "error")
      :arg("-select_streams", "v")
      :arg("-show_entries", "stream=r_frame_rate")
      :arg("-of", "default=noprint_wrappers=1:nokey=1")
      :arg(inpath)

  local res = command:run()
  if res.success and res.output then
      local num, den = res.output:match("([%d.]+)/([%d]+)")
      if num and den then
          return tonumber(num) / tonumber(den)
      end
  end
  return nil
end

local function process_youtube(shift, endpos, outpath, inpath, enable_subs)
    local duration = endpos - shift
    if duration <= 0 then
        msg.error("Invalid duration for YouTube cut")
        return
    end

    local command = Command:new("yt-dlp")
        :arg("-f", string.format("bestvideo[height<=?%s][ext=%s]+bestaudio[ext=m4a]", o.youtube.max_yt_quality, o.encoding.ffmt))
        :arg("--downloader", "ffmpeg")
        :arg("--downloader-args", string.format("ffmpeg_i:-ss %s -t %s", shift, duration))
        :arg("-S", "proto:https")
        :arg(inpath)
        if enable_subs then
            for _, arg in ipairs(enable_subs) do
                command:arg(arg)
            end
        end
    command:arg("--output", outpath)

    for _, arg in ipairs(o.youtube.yt_dlp_args) do
        command:arg(arg)
    end

    local res = command:run()
    if res.success then
        info("YouTube video processing complete: " .. outpath)
    else
        msg.error("yt-dlp failed: " .. res.error)
    end
end

local function process_local(shift, endpos, outpath, inpath, enable_subs)
    local vid = get_property_number('video', 1)
    local aid = get_property_number('audio', nil)
    local sid = get_property_number('sub')
    local duration = endpos - shift
    if duration <= 0 then
        msg.error("Invalid duration for local cut")
        return
    end

    local command = Command:new(o.paths.ffmpeg_path)
        :arg("-v", "warning")
        :arg(o.flags.overwrite and "-y" or "-n")
        :arg("-stats")
        :arg("-ss", tostring(shift))
        :arg("-hide_banner")
        :arg("-accurate_seek")
        :arg("-avoid_negative_ts", "make_zero")
        :arg("-async", "1")
        :arg("-flags", "+cgop")
        :arg(not o.encoding.copy_audio and "-an" or nil)
        :arg("-ac", "2")
        :arg("-i", inpath)
        :arg("-t", tostring(duration))
        :arg("-map", "0:v:" .. vid - 1 .. "?")
        :arg("-map", "a:" .. (aid and aid - 1 or 0) .. "?")
        :arg("-b:v", o.encoding.vbitrate)
        :arg("-b:a", o.encoding.abitrate)
        if o.flags.copy_override then
            command:arg("-c", "copy")
        else
            command:arg("-c:v", o.encoding.vcodec)
                   :arg("-c:a", o.encoding.acodec)
                   :arg("-c:s", "copy")
            if enable_subs then
                for _, arg in ipairs(enable_subs) do
                    command:arg(arg)
                end
            end
        end
        command:arg("-movflags", "+faststart")
        command:arg(outpath)

        local res = command:run()
        if res.success then
            info("Trim file successfully created: " .. outpath)
        else
            msg.error("FFmpeg failed: " .. res.error)
        end
end

local function cut_video(shift, endpos)
    local inpath = get_property("path")
    local outpath = get_outname(shift, endpos)
    local subtitles_enabled = enable_subs(shift)

    if is_remote() then
        process_youtube(shift, endpos, outpath, inpath, subtitles_enabled)
    else
        process_local(shift, endpos, outpath, inpath, subtitles_enabled)
    end
end

local function toggle_mark()
    local pos = get_property_number("time-pos")
    if not pos then
        osd("Failed to get timestamp")
        return
    end

    if o.encoding.cut_pos then
        local shift, endpos = o.encoding.cut_pos, pos
        if shift > endpos then
            shift, endpos = endpos, shift
        elseif shift == endpos then
            osd("Cut fragment is empty")
            return
        end
        info(string.format("Cut fragment: %s-%s", timestamp(shift), timestamp(endpos)))
        o.encoding.cut_pos = nil
        cut_video(shift, endpos)
    else
        o.encoding.cut_pos = pos
        osd("Start cut position: " .. timestamp(pos))
    end
end

local function toggle_audio()
    o.encoding.copy_audio = not o.encoding.copy_audio
    osd("Audio capturing is " .. (o.encoding.copy_audio and "enabled" or "disabled"))
end

local function clear_toggle_mark()
    o.encoding.cut_pos = nil
    osd("Marked positions cleared")
end

local function toggle_subs()
    o.encoding.embed_subs = not o.encoding.embed_subs
    osd("Subtitles embedding is " .. (o.encoding.embed_subs and "enabled" or "disabled"))
end

-- Key bindings
mp.add_key_binding("c", "toggle_mark", toggle_mark)
mp.add_key_binding("a", "toggle_audio", toggle_audio)
mp.add_key_binding("C", "clear_toggle_mark", clear_toggle_mark)
mp.add_key_binding("s", "toggle_subs", toggle_subs)

-- Ensure target directory exists
o.target_dir = mp.command_native({ "expand-path", o.target_dir })
if not utils.file_info(o.target_dir) then
    local args = is_windows and { "powershell", "-NoProfile", "-Command", "mkdir", o.target_dir } or { "mkdir", "-p", o.target_dir }
    Command:new():arg(unpack(args)):run()
end

if o.flags.debug then
    msg.info("Options:", utils.to_string(o))
end
