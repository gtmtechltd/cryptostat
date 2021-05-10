require "kraken_ruby_client"
require_relative "./utils.rb"

class StatKraken
  def self.get config
    name   = config["name"]
    client = Kraken::Client.new(api_key: config["api_key"], api_secret: config["api_secret"])

    response = if ENV['CRYPTOSTAT_TEST'] == "true" then
      Utils.info "Analysing kraken (testmode)..."
      JSON.parse( File.read( "examples/api.kraken.com.txt" ) )
    else
      Utils.info "Analysing kraken..."
      Utils.prepare_result( name, client.balance["result"] )
    end

    translate_currencies = {
      "ZUSD" => "USD",
      "ZEUR" => "EUR",
      "ZGBP" => "GBP",
      "XXBT" => "BTC",
      "XXRP" => "XRP",
      "XLTC" => "LTC",
      "XXDG" => "DOGE",
      "XETH" => "ETH",
      "XETC" => "ETC"
    }

    result = {}
    response.each do |currency, amount|
      translated_currency = currency
      translated_currency = translate_currencies[ currency] if translate_currencies.key? currency
      result[ "#{translated_currency}.#{name}" ] = amount unless amount.tr("0.", "").empty?
    end

    result

  end
end
