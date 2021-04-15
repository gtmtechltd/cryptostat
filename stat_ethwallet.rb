require 'rest-client'

class StatEthwallet
  def self.get wallet
    address  = wallet["address"]
    name     = wallet["name"]
    STDERR.puts "Analysing eth wallet #{name} (#{address})..."

    headers  = {}
    url      = "https://api.ethplorer.io/getAddressInfo/#{address}?apiKey=freekey"
    response = if ENV["CRYPTOSTAT_TEST"] == "true" then
      File.read("examples/api.ethplorer.io.txt")
    else
      RestClient.get(url, headers)
    end
    json     = JSON.parse(response)

#  "ETH": {
#    "balance": 0.003250355663643179,
#    ...
#  }

    tokens   = { "ETH.#{name}-#{address.split(//).take(7).join("")}" => json["ETH"]["balance"] }
#    STDERR.puts "-> ETH = #{json["ETH"]["balance"]}"

#  "tokens": [
#    {
#      "tokenInfo": {
#        "decimals": "18",
#        "symbol": "MTLX",
#        ...
#        "price": {
#          "rate": 11.69359525972548,
#          "currency": "USD"
#          ...
#        }
#      },
#      "balance": 21607867444870800000,
#      ...
#    }

    json["tokens"].each do |token|
      symbol   = token["tokenInfo"]["symbol"]
      balance  = token["balance"]
      decimals = token["tokenInfo"]["decimals"]
#      price    = token["tokenInfo"]["price"]["rate"]
      decimals.to_i.times do |i|
        balance = balance.to_f / 10.0
      end
      tokens[ "#{symbol.to_s}.#{name}-#{address.split(//).take(7).join("")}" ] = balance
#      STDERR.puts "-> #{tokens[ symbol ]} = #{balance}"
    end

    tokens    
  end

end