require "kucoin/api"

class StatKucoin
  def self.get config
    STDERR.puts "Analysing kucoin..."

    client = Kucoin::Api::REST.new \
      api_key:        config["api_key"],
      api_secret:     config["api_secret"],
      api_passphrase: config["api_passphrase"]

    query = client.user.accounts.list

    result = {}
    query.each do | balance |
      result[ "#{balance[ "currency" ]}.kucoin.#{balance[ "type" ]}" ] = balance["balance"] unless balance["balance"].tr("0.", "").empty?
    end

    result

  end
end
