#!/usr/bin/env ruby

require "json"
require_relative "./stat_binance.rb"
require_relative "./stat_kraken.rb"
require_relative "./stat_kucoin.rb"
require_relative "./stat_manual.rb"
require_relative "./stat_coinmarketcap.rb"

file = File.read("./config.json")
config = JSON.parse(file)

price_overrides = if File.exists?("./prices.json") then
  prices_file = File.read("./prices.json")
  JSON.parse(prices_file)
else
  {}
end

portfolios = if File.exists?("./portfolios.json") then
  portfolios_file = File.read("./portfolios.json")
  JSON.parse(portfolios_file)
else
  { "me": "1.0" }
end

all = []
all << StatKraken.get(  config["kraken"] )  if config.key? "kraken"
all << StatBinance.get( config["binance"] ) if config.key? "binance"
all << StatKucoin.get(  config["kucoin"] )  if config.key? "kucoin"
all << StatManual.get(  config["manual"] )  if config.key? "manual"
prices = StatCoinmarketcap.get( config["coinmarketcap"] )

coins = {}
exchange_coins = {}
all.each do |exchange|
  exchange.each do |currency, value|
    coin = currency.split(".").first
    coins[ coin ] ||= []
    coins[ coin ] << value
    exchange_coins[ coin ] ||= []
    exchange_coins[ coin ] << currency.split(".").delete_if.with_index {|x, i| i==0 }.join(".")
  end
end

puts "            COIN        SUPPLY            EXCHANGES                       PRICE           USD-AMOUNT"
puts "=========================================================================================================="
outputs = []
total_usd = 0.0
coins.keys.sort.each do |coin|
  text    = ""
  amounts = coins[ coin ]
  total   = amounts.inject(0.0){|sum,x| sum + x.to_f }
  price   = "0.0"
  price   = prices[ coin ] if prices.key? coin 
  price   = price_overrides[ coin ] if price_overrides.key? coin
  price   = price.to_f
  usd     = total * price 
  text += "#{sprintf('%16s', coin)} "
  text += "#{" " * (8 - total.to_i.to_s.length)}#{sprintf('%5.8f', total)} "

  if amounts.length == 1 then
    text += sprintf("%16s", exchange_coins[ coin ].first)
    text += "#{" " * 16}"
  else
    text += sprintf("%16s", exchange_coins[ coin ].first)
    text += "="
    text += "#{" " * (5 - amounts.first.to_i.to_s.length)}#{sprintf('%5.8f', amounts.first)} "
  end

  text += "#{" " * (8 - price.to_i.to_s.length)}$ #{sprintf("%5.8f", price )}"
  text += "#{" " * (8 - usd.to_i.to_s.length)}$ #{sprintf('%5.2f', usd)}\n"

  if amounts.length > 1 then
    amounts.each.with_index do |a, i|
      next if i==0
      text += "                                   "
      text += sprintf("%16s", exchange_coins[ coin ][ i ])
      text += "="
      text += "#{" " * (5 - amounts[ i ].to_i.to_s.length)}#{sprintf('%5.8f', amounts[ i ])}\n"
    end
  end

  outputs << {:usd => usd, :text => text } if usd > 1.0
  total_usd += usd

end

outputs.sort_by! { |k| k[:usd] }
outputs.reverse.each do |output|
  puts output[:text]
end
puts "==============================================================================================="
puts " TOTAL                                                                    $ #{total_usd}"
puts ""
puts "Portfolios"
puts "================================="
portfolios.each do | entity, percentage |
  amount = total_usd.to_f * percentage.to_f / 100.0
  print sprintf("%16s", entity)
  print "  "
  print "#{" " * (8 - amount.to_i.to_s.length)}$ #{sprintf("%5.2f", amount)}\n"
end

