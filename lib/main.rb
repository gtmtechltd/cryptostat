#!/usr/bin/env ruby

require "json"
require_relative "./stat_binance.rb"
require_relative "./stat_kraken.rb"
require_relative "./stat_kucoin.rb"
require_relative "./stat_manual.rb"
require_relative "./stat_coinmarketcap.rb"
require_relative "./stat_fixer.rb"
require_relative "./stat_ethwallet.rb"

def sig(f)
  value = sprintf("%8.8f", f)
  while value.length < 17 do
    value = " " + value
  end
  value
end

file = File.read("config/config.json")
config = JSON.parse(file)

price_overrides = if File.exists?("config/prices.json") then
  prices_file = File.read("config/prices.json")
  JSON.parse(prices_file)
else
  {}
end

# Remove any %age signs from the price_overrides
price_overrides.each do |k, v|
  price_overrides[ k ] = v.split("%").first
end

portfolios = if File.exists?("config/portfolios.json") then
  portfolios_file = File.read("config/portfolios.json")
  JSON.parse(portfolios_file)
else
  { "me": "1.0" }
end

def dump coins
  coins.each do |k, v|
    Utils.debug "-> #{k.split(".").first} = #{v}"
  end
end

all = []
coins = StatKraken.get(  config["kraken"] )  if config.key? "kraken"
dump coins
all << coins
coins = StatBinance.get( config["binance"] ) if config.key? "binance"
dump coins
all << coins
coins = StatKucoin.get(  config["kucoin"] )  if config.key? "kucoin"
dump coins
all << coins
coins = StatManual.get(  config["manual"] )  if config.key? "manual"
dump coins
all << coins
config["ethwallets"].each do |wallet|
  coins = StatEthwallet.get( wallet )
  dump coins
  all << coins
  sleep 5 unless ENV["CRYPTOSTAT_TEST"] == "true"    # To avoid Too Many Requests API rate limiting for multiple eth wallets
end
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

puts ""
if currency == "USD" then
  puts "- coin -| -- holdings --- | ---- price USD ---- | ---- total USD ---- | EXCHANGES"
else
  puts "- coin -| -- holdings --- | ---- price USD ---- | ---- price #{currency} ---- | ---- total #{currency} ---- | EXCHANGES"
end
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
  if currency != "USD" then
    text += sig(price * xrate) + " #{currency} "  # price-currency
  end
  text += sig(usd * xrate) + " #{currency}  "    # total-currency

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
