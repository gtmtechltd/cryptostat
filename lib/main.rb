#!/usr/bin/env ruby

require "json"
require_relative "./stat_binance.rb"
require_relative "./stat_kraken.rb"
require_relative "./stat_kucoin.rb"
require_relative "./stat_manual.rb"
require_relative "./stat_mxc.rb"
require_relative "./stat_probit.rb"

require_relative "./stat_coinmarketcap.rb"
require_relative "./stat_fixer.rb"

require_relative "./stat_ethwallet.rb"
require_relative "./stat_bscwallet.rb"
require_relative "./config.rb"

ENV["CRYPTOSTAT_TEST"] = "" unless ENV["CRYPTOSTAT_TEST"]

def sig(f)
  value = sprintf("%8.8f", f)
  while value.length < 17 do
    value = " " + value
  end
  value
end

def usage
  STDERR.puts <<-EOF
$0 [arguments]

-h   --help      Usage instructions
     --no-cache  Do not use cached api calls
-d   --debug     Output debug info
-t   --trace     Output higher level debug
EOF
  exit 0
end

for arg in ARGV
  case arg
    when '-h','--help'      then usage
    when '--no-cache'       then ENV['CRYPTOSTAT_NOCACHE'] = "true"
    when '-d','--debug'     then ENV['CRYPTOSTAT_DEBUG'] = "true"
    when '-t','--trace'     then ENV['CRYPTOSTAT_TRACE'] = "true"
  end
end

config = Config.get
$INVOCATION_DATE=Time.now.to_s.split(" +").first.tr ": ", "-"
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

# EXCHANGES

config["exchanges"].keys.each do |e|
  data          = config["exchanges"][ e ]
  exchange_name = data["exchange"] || e
  data["name"]  = e
  puts "#{exchange_name.capitalize}"
   
  coins = begin 
    exchange = Kernel.const_get("Stat#{exchange_name.capitalize}")
    exchange.send( :get, data )
  rescue NameError
    Utils.info "- #{exchange_name.capitalize} exchange has not been implemented yet - ignoring"
    {}
  end
  dump coins
  all << coins

end

# WALLETS

config["wallets"].keys.each do |wallet_name|    # eth, bsc, btc
  data     = config["wallets"][ wallet_name ]
  api_keys = config["wallet_api_keys"][ wallet_name ] ||= {}
  data.each do |wallet_data|
    coins = begin
      wallet = Kernel.const_get("Stat#{wallet_name.capitalize}wallet")
      wallet.send( :get, wallet_data, api_keys )
    rescue NameError
      Utils.info "- #{wallet_name.capitalize} wallet has not been implemented yet - ignoring"
      {}
    end
    dump coins
    all << coins
  end
end

# PRICES

xrate    = 1.0
xrate    = StatFixer.get( config["prices"]["fixer.io"] ) if config["prices"].key? "fixer.io"
currency = "USD"
currency = config["prices"]["fixer.io"]["currency"] if config["prices"].key? "fixer.io"
prices   = StatCoinmarketcap.get( config["prices"]["coinmarketcap"] )
prices[ currency ] = (1.0 / xrate).to_s

# CALCULATIONS

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
to_screen = ""
if currency == "USD" then
  to_screen += "- coin -| -- holdings --- | ---- price USD ---- | ---- total USD ---- | EXCHANGES\n"
else
  to_screen += "- coin -| -- holdings --- | ---- price USD ---- | ---- price #{currency} ---- | ---- total #{currency} ---- | EXCHANGES\n"
end
to_screen += "==================================================================================================================================================\n"
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
  text += "#{sprintf('%-8s', coin.split("(").first)} "     # coin - up to ()
  text += sig(total)                                       # holdings
  text += sig(price) + " USD "                             # price-usd
  if currency != "USD" then
    text += sig(price * xrate) + " #{currency} "           # price-currency
  end
  text += sig(usd * xrate) + " #{currency}  "              # total-currency

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
    to_screen += line + "\n"
  end if usd > 1.0   # Don't print small amounts
end
to_screen += "==================================================================================================================================================\n"
to_screen += "TOTAL                                           #{sig(total_usd)} USD #{sig(total_usd * xrate)} #{currency}\n"
to_screen += "\n"
to_screen += "Portfolios\n"
to_screen += "=========================================================\n"
portfolios.each do | entity, percentage |
  amount = (total_usd.to_f * percentage.to_f / 100.0) * xrate
  to_screen += "#{sprintf("%-12s", entity)}  #{sig(amount)} #{currency} "
  if config.key? "extra" and config["extra"].key? entity then
    to_screen += "+ #{sig(config["extra"][entity].to_f)}  #{currency} "
    amount += config["extra"][entity].to_f
    to_screen += "= #{sig(amount)}  #{currency} "
  end
  to_screen += "\n"
end

if Utils.get :used_cached_prices then
  to_screen += "\n"
  to_screen += "******************************************************************************************************\n"
  to_screen += "** To save API requests, some prices were calculated from cached values (usually up to an hour old) **\n"
  to_screen += "** - For up-to-the-second results, please specify --no-cache                                        **\n"
  to_screen += "******************************************************************************************************\n"
else
  File.open("snapshots/#{Time.now.strftime("%Y-%m-%d.%H-%M-%S")}.txt", "w") { |f| f.write to_screen }
end
puts to_screen
