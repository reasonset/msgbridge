#!/bin/ruby
require 'yaml'
require 'fileutils'

msgs = ARGF.read.split(/^---$/)

sound_library_dir = File.join((ENV["XDG_DATA_HOME"] || [ENV["HOME"], ".local", "share"]), "msgbridge", "sound")

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
      fork { exec("mpv", "--really-quiet", "--audio-client-name=msgbridge", File.join(sound_library_dir, sound_library["notify"])) }
    end
    system("notify-send", "-t", "10000", "-a", "msgbridge", data["message"])
  when "dialog"
    if sound_library["dialog"]
      fork { exec("mpv", "--really-quiet", "--audio-client-name=msgbridge", File.join(sound_library_dir, sound_library["dialog"])) }
    end
    system("zenity", "--title", "msgbridge", "--info", "--text", data["message"])
  when "sound"
    if sound_library[data["message"]]    
      system("mpv", "--really-quiet", "--audio-client-name=msgbridge", File.join(sound_library_dir, sound_library[data["message"]]))
    end
  when "sound-repeat"
    if sound_library[data["message"]]    
      system("mpv", "--force-window", "--loop-file=inf","--audio-client-name=msgbridge", File.join(sound_library_dir, sound_library[data["message"]]))
    end
  when "poweroff"
    system("poweroff")
  end
end

Process.waitall