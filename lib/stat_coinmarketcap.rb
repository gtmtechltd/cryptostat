require 'rest-client'
require_relative "./utils.rb"

class StatCoinmarketcap
  def self.get config
    url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=5000"
    headers = {
      "X-CMC_PRO_API_KEY" => config["api_key"]
    }
    response = if ENV['CRYPTOSTAT_TEST'] == "true" then
      Utils.info "Analysing coinmarketcap (testmode)..."
      File.read("examples/pro-api.coinmarketcap.com.txt")
    else
      Utils.info "Analysing coinmarketcap..."
      RestClient.get(url, headers)
    end 
    json     = JSON.parse(response)
    prices   = {}
    json["data"].each do |item|
      prices[ item["symbol"] ] = item["quote"]["USD"]["price"]
    end
    prices[ "USD" ] = "1.0"
    prices
  end

end
