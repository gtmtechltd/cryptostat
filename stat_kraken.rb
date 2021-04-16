require "kraken_ruby_client"

class StatKraken
  def self.get config
    client = Kraken::Client.new(api_key: config["api_key"], api_secret: config["api_secret"])

    response = if ENV['CRYPTOSTAT_TEST'] == true then
      STDERR.puts "Analysing kraken..."
      client.balance["result"]
    else
      STDERR.puts "Analysing kraken (testmode)..."
      JSON.parse( File.read( "examples/api.kraken.com.txt" ) )
    end

    translate_currencies = {
      "ZUSD" => "USD",
      "ZEUR" => "EUR",
      "ZGBP" => "GBP",
      "XXBT" => "BTC",
      "XXRP" => "XRP",
      "XLTC" => "LTC",
      "XXDG" => "XDG",
      "XETH" => "ETH",
      "XETC" => "ETC"
    }

    result = {}
    response.each do |currency, amount|
      translated_currency = currency
      translated_currency = translate_currencies[ currency] if translate_currencies.key? currency
      result[ "#{translated_currency}.kraken" ] = amount unless amount.tr("0.", "").empty?
    end

    result

  end
end
