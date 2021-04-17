require 'rest-client'
require_relative "./utils.rb"

class StatEthwallet
  
  @@lasttime = Time.now.to_i

  def self.get wallet
    address  = wallet["address"]
    name     = wallet["name"]

    headers  = {}
    url      = "https://api.ethplorer.io/getAddressInfo/#{address}?apiKey=freekey"
    response = if ENV["CRYPTOSTAT_TEST"] == "true" then
      Utils.info "Analysing eth wallet #{name} (#{address}) (testmode)..."
      File.read("examples/api.ethplorer.io.txt")
    else
      while Time.now.to_i < @@lasttime + 2 do
        sleep 1                                     # Avoid 429 Too Many Requests
      end
      @@lasttime = Time.now.to_i
      Utils.info "Analysing eth wallet #{name} (#{address.split(//).take(10).join("")}...)..."
      RestClient.get(url, headers)
    end
    json     = JSON.parse(response)

        #  "ETH": {
        #    "balance": 0.003250355663643179,
        #    ...
        #  }

    tokens   = { "ETH.#{name}-#{address.split(//).take(7).join("")}" => json["ETH"]["balance"] }

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
      address  = token["tokenInfo"]["address"]
      balance  = token["balance"]
      decimals = token["tokenInfo"]["decimals"]
      decimals.to_i.times do |i|
        balance = balance.to_f / 10.0
      end
      tokens[ "#{symbol}(#{address}).#{name}-#{address.split(//).take(7).join("")}" ] = balance
    end

    tokens    
  end

end
