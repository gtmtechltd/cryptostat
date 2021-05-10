require 'rest-client'
require_relative "./utils.rb"

class StatCoinmarketcap
  def self.get config
    url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=5000"
    headers = {
      "X-CMC_PRO_API_KEY" => config["api_key"]
    }
    cache = true
  
    response = if Utils.cacheok?( "coinmarketcap" ) and ENV['CRYPTOSTAT_NOCACHE'] != "true" then
      cache = false
      Utils.info "Analysing coinmarketcap (**from cache**)..."
      Utils.set :used_cached_prices, true
      Utils.read_cache( "coinmarketcap" ).to_json
    elsif ENV['CRYPTOSTAT_TEST'] == "true" then
      cache = false
      Utils.info "Analysing coinmarketcap (testmode)..."
      File.read("examples/pro-api.coinmarketcap.com.txt")
    else
      Utils.info "Analysing coinmarketcap..."
      Utils.prepare_result( "coinmarketcap", RestClient.get(url, headers) )
    end 
    json     = JSON.parse(response)
    cachejson = { "time" => Time.now.to_i, "result" => json }
    Utils.write_cache "coinmarketcap", cachejson if cache

    prices   = {}
    json["data"].each do |item|
      prices[ item["symbol"] ] = item["quote"]["USD"]["price"]

      # We also store a key in the form COIN(token-address) because some tokens on wallets have the same name, but different contract addresses.
      if item.key? "platform" and item["platform"].class.to_s == "Hash" then
        if item["platform"].key? "token_address" then
          key           = "#{item["symbol"]}(#{item["platform"]["token_address"]})"
          value         = item["quote"]["USD"]["price"] 
          prices[ key ] = value
        end
      end
    end
    prices[ "USD" ] = "1.0"
    prices
  end

end
