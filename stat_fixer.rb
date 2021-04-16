require 'rest-client'

class StatFixer
  def self.get config
    api_key  = config["api_key"]
    currency = config["currency"]
    url      = "http://data.fixer.io/api/latest?access_key=#{api_key}&symbols=USD,#{currency}&format=1"
    headers  = {}

    response = if ENV['CRYPTOSTAT_TEST'] == true then
      STDERR.puts "Analysing fixer.io..."
      RestClient.get(url, headers)
    else
      STDERR.puts "Analysing fixer.io (testmode)..."
      JSON.parse( File.read( "examples/data.fixer.io.txt" ) )
    end
    json     = JSON.parse(response)
    xrate    = json["rates"][currency].to_f / json["rates"]["USD"].to_f
    STDERR.puts "-> 1 USD = #{xrate} #{currency}"
    xrate
  end
end
