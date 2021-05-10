require "kucoin/api"
require_relative "./utils.rb"

class StatKucoin
  def self.get config
    name   = config["name"]
    client = Kucoin::Api::REST.new \
      api_key:        config["api_key"],
      api_secret:     config["api_secret"],
      api_passphrase: config["api_passphrase"]

    response = if ENV['CRYPTOSTAT_TEST'] == "true" then
      Utils.info "Analysing kucoin (testmode)..."
      JSON.parse( File.read( "examples/api.kucoin.com.txt" ) )
    else
      Utils.info "Analysing kucoin..."
      Utils.prepare_result( name, client.user.accounts.list )
    end

    result = {}
    response.each do | balance |
      result[ "#{balance[ "currency" ]}.#{name}.#{balance[ "type" ]}" ] = balance["balance"] unless balance["balance"].tr("0.", "").empty?
    end

    result

  end
end
