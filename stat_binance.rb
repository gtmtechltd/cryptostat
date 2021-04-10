require "binance-ruby"

class StatBinance
  def self.get config
    ENV["BINANCE_API_KEY"]    = config["api_key"]
    ENV["BINANCE_SECRET_KEY"] = config["api_secret"]
    query                     = Binance::Api.info!
    result                    = {}

    query[ :balances ].each do | balance |
      result[ "#{balance[ :asset ]}.binance.free" ]   = balance[ :free ]   unless balance[ :free ].tr("0.", "").empty? 
      result[ "#{balance[ :asset ]}.binance.locked" ] = balance[ :locked ] unless balance[ :locked ].tr("0.", "").empty?
    end

    result

  end
end

