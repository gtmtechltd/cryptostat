require 'rest-client'

class StatFixer
  def self.get config
    STDERR.puts "Analysing fixer.io..."
    api_key  = config["api_key"]
    currency = config["currency"]
    url      = "http://data.fixer.io/api/latest?access_key=#{api_key}&symbols=USD,#{currency}&format=1"
    headers  = {}
    response = RestClient.get(url, headers)
    json     = JSON.parse(response)
    xrate    = json["rates"][currency].to_f / json["rates"]["USD"].to_f
    STDERR.puts "-> 1 USD = #{xrate} #{currency}"
    xrate
  end
end
