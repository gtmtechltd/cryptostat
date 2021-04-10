require 'rest-client'

class StatCoinmarketcap
  def self.get config
    url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"
    headers = {
      "X-CMC_PRO_API_KEY" => config["api_key"]
    }
    response = RestClient.get(url, headers)
    json     = JSON.parse(response)
    prices   = {}
    json["data"].each do |item|
      prices[ item["symbol"] ] = item["quote"]["USD"]["price"]
    end
    prices
  end
end
