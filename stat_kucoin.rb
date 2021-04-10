require "kucoin/api"

class StatKucoin
  def self.get _config

    client = Kucoin::Api::REST.new \
      api_key:        _config["api_key"],
      api_secret:     _config["api_secret"],
      api_passphrase: _config["api_passphrase"]

    query = client.user.accounts.list

    result = {}
    query.each do | balance |
      result[ "#{balance[ "currency" ]}.kucoin.#{balance[ "type" ]}" ] = balance["balance"] unless balance["balance"].tr("0.", "").empty?
    end

    result

  end
end
