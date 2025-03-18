#!/bin/ruby
require 'yaml'
require 'fileutils'

msgs = ARGF.read.split(/^---$/)

sound_library_dir = File.join((ENV["XDG_DATA_HOME"] || [ENV["HOME"], ".local", "share"]), "msgbridge", "sound")

config = {
  "sound_player" => ["mpv", "--force-window","--audio-client-name=msgbridge"],
  "sound_player_loop" => ["mpv", "--force-window", "--loop-file=inf","--audio-client-name=msgbridge"],
  "dialog" => ["zenity", "--title", "msgbridge", "--info", "--text"],
  "command" => {}
}
if File.exist?(File.join((ENV["XDG_DATA_HOME"] || [ENV["HOME"], ".config"]), "msgbridge", "msgbridge.yaml"))
  config = config.merge YAML.load File.read(File.join((ENV["XDG_DATA_HOME"] || [ENV["HOME"], ".config"]), "msgbridge", "msgbridge.yaml"))
end

unless File.exist? sound_library_dir
  FileUtils.mkdir_p sound_library_dir
end

sound_library = {}
Dir.children(sound_library_dir).each do |i|
  sound_library[File.basename(i, ".*")] = i
end

msgs.each do |i|
  data = YAML.load(i) or next

  case data["type"]
  when "notify"
    if sound_library["notify"]
      fork { exec(*config["sound_player"], File.join(sound_library_dir, sound_library["notify"])) }
    end
    system("notify-send", "-t", "10000", "-a", "msgbridge", data["message"])
  when "dialog"
    if sound_library["dialog"]
      fork { exec(*config["sound_player"], File.join(sound_library_dir, sound_library["dialog"])) }
    end
    system(*config["dialog"], data["message"])
  when "sound"
    if sound_library[data["message"]]    
      system(*config["sound_player"], File.join(sound_library_dir, sound_library[data["message"]]))
    end
  when "sound-repeat"
    if sound_library[data["message"]]    
      system(*config["sound_player_loop"], File.join(sound_library_dir, sound_library[data["message"]]))
    end
  when "command"
    if config["command"] && config["command"][data["message"]]
      system(*config["command"][data["message"]])
    end
  when "poweroff"
    system("poweroff")
  end
end

Process.waitall