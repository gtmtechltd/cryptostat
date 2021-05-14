#!/usr/bin/env ruby

require "json"

arg = ARGV[0]

require_relative "./stat_#{arg}wallet.rb"
require_relative "./config.rb"

config = Config.get

c = Kernel.const_get("Stat#{arg.capitalize}wallet")
api_keys = config["wallet_api_keys"][ arg ]

config["wallets"][arg].each do |wallet_config|
  r = c.send( :get, wallet_config, api_keys )
  puts "#{r.class} = #{r}"
end
