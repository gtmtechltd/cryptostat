#!/usr/bin/env ruby

require "json"
require_relative "./stat_binance.rb"
require_relative "./stat_kraken.rb"
require_relative "./stat_kucoin.rb"
require_relative "./stat_manual.rb"
require_relative "./stat_coinmarketcap.rb"
require_relative "./stat_fixer.rb"

def sig(f)
  value = sprintf("%8.8f", f)
  while value.length < 17 do
    value = " " + value
  end
  value
end

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
xrate    = 1.0
xrate    = StatFixer.get( config["fixer.io"] ) if config.key? "fixer.io"
currency = "USD"
currency = config["fixer.io"]["currency"] if config.key? "fixer.io"
prices   = StatCoinmarketcap.get( config["coinmarketcap"] )

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

puts "- coin -| -- holdings --- | ---- price USD ---- | ---- price #{currency} ---- | ---- total USD ---- | ---- total #{currency} ---- | EXCHANGES"
puts "=================================================================================================================================================="
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
  text += "#{sprintf('%-8s', coin)} "           # coin
  text += sig(total)                            # holdings
  text += sig(price) + " USD "                  # price-usd
  text += sig(price * xrate) + " #{currency} "  # price-currency
  text += sig(usd) + " USD "                    # total-usd
  text += sig(usd * xrate) + " #{currency} "    # total-currency

  lines = []
  amounts.each.with_index do |a, i|
    lines << text + sprintf("%16s", exchange_coins[ coin ][ i ]) + "=" + sig(amounts[i])
    text   = " " * text.length
  end
  outputs << { :usd => usd, :lines => lines }

  total_usd += usd
end

outputs.sort_by! { |k| k[:usd] }
outputs.reverse.each do |output|
  lines = output[:lines]
  usd   = output[:usd]
  lines.each do |line|
    puts line
  end if usd > 5.0   # Don't print small amounts
end
puts "=================================================================================================================================================="
puts "TOTAL                                                                 #{sig(total_usd)} USD #{sig(total_usd * xrate)} #{currency}"
puts ""
puts "Portfolios"
puts "========================================================="
portfolios.each do | entity, percentage |
  amount = total_usd.to_f * percentage.to_f / 100.0
  puts "#{sprintf("%-12s", entity)}  #{sig(amount)} USD    #{sig(amount * xrate)} #{currency}"
end
