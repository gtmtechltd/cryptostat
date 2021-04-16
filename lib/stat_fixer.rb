require 'rest-client'
require_relative "./utils.rb"

class StatFixer
  def self.get config
    api_key  = config["api_key"]
    currency = config["currency"]
    url      = "http://data.fixer.io/api/latest?access_key=#{api_key}&symbols=USD,#{currency}&format=1"
    headers  = {}

    response = if ENV['CRYPTOSTAT_TEST'] == true then
      Utils.info "Analysing fixer.io..."
      RestClient.get(url, headers)
    else
      Utils.info "Analysing fixer.io (testmode)..."
      File.read( "examples/data.fixer.io.txt" )
    end
    json     = JSON.parse(response)
    xrate    = json["rates"][currency].to_f / json["rates"]["USD"].to_f
    Utils.debug "-> 1 USD = #{xrate} #{currency}"
    xrate
  end
end
