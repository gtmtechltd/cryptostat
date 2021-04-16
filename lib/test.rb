#!/usr/bin/env ruby

require "json"

arg = ARGV[0]

require_relative "./stat_#{arg}.rb"
require_relative "./config.rb"

config = Config.get

c = Kernel.const_get("Stat#{arg.capitalize}")
puts c.send( :get, config["#{arg}"] )
