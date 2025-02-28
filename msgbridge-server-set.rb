#!/bin/ruby
require 'yaml'
require 'fileutils'

host = ARGV.shift
type = ARGV.shift
msg = ARGV.join(" ")

if !host || !type
  abort "Invalid message"
end

hosts = host == "all" ? Dir.children(File.join((ENV["XDG_DATA_HOME"] || [ENV["HOME"], ".local", "share"]), "msgbridge", "msgs")) : [host]
state_base = ENV["XDG_DATA_HOME"] ? [ENV["XDG_DATA_HOME"]] : [ENV["HOME"], ".local", "share"]

hosts.each do |h|
  filename = [Time.now.to_i, ".", $$, ".yaml"].join("")
  state_file = File.join(*state_base, "msgbridge", "msgs", h, filename)

  state_dir = File.dirname state_file
  if !File.exist? state_dir
    FileUtils.mkdir_p state_dir
  end

  File.open(state_file, "w") do |f|
    YAML.dump({
      "type" => type,
      "message" => msg
    }, f)
  end
end