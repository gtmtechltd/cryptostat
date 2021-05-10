require 'rest-client'
require_relative "./utils.rb"

class StatFixer
  def self.get config
    api_key  = config["api_key"]
    currency = config["currency"]
    url      = "http://data.fixer.io/api/latest?access_key=#{api_key}&symbols=USD,#{currency}&format=1"
    headers  = {}
    cache    = true

    response = if Utils.cacheok?( "fixer.io" ) and ENV['CRYPTOSTAT_NOCACHE'] != "true" then
      Utils.info "Analysing fixer.io (**from cache**)..."
      cache = false
      Utils.set :used_cached_prices, true
      Utils.read_cache( "fixer.io" ).to_json
    elsif ENV['CRYPTOSTAT_TEST'] == "true" then
      cache = false
      Utils.info "Analysing fixer.io (testmode)..."
      File.read( "examples/data.fixer.io.txt" )
    else
      Utils.info "Analysing fixer.io..."
      Utils.prepare_result( "fixer", RestClient.get(url, headers) )
    end
    json      = JSON.parse(response)
    cachejson = { "time" => Time.now.to_i, "result" => json }
    Utils.write_cache "fixer.io", cachejson if cache
    xrate     = json["rates"][currency].to_f / json["rates"]["USD"].to_f
    Utils.debug "-> 1 USD = #{xrate} #{currency}"
    xrate
  end
end
