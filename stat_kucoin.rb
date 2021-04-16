require "kucoin/api"

class StatKucoin
  def self.get config
    client = Kucoin::Api::REST.new \
      api_key:        config["api_key"],
      api_secret:     config["api_secret"],
      api_passphrase: config["api_passphrase"]

    response = if ENV['CRYPTOSTAT_TEST'] == true then
      STDERR.puts "Analysing kucoin..."
      client.user.accounts.list
    else
      STDERR.puts "Analysing kucoin (testmode)..."
      JSON.parse( File.read( "examples/api.kucoin.com.txt" ) )
    end

    result = {}
    response.each do | balance |
      result[ "#{balance[ "currency" ]}.kucoin.#{balance[ "type" ]}" ] = balance["balance"] unless balance["balance"].tr("0.", "").empty?
    end

    result

  end
end
