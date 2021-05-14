#!/usr/bin/env ruby

require "json"

arg = ARGV[0]

require_relative "./stat_#{arg}.rb"
require_relative "./config.rb"

config = Config.get

c = Kernel.const_get("Stat#{arg.capitalize}")
r = c.send( :get, config["exchanges"]["#{arg}"] )

puts "#{r.class} = #{r}"
