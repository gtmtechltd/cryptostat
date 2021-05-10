require "binance-ruby"
require_relative "./utils.rb"

class StatBinance
  def self.symbolize obj
    result = {}
    new_obj = case obj.class.to_s
    when "Array"
      obj.collect {|i| self.symbolize i}
    when "Hash"
      r = {}
      obj.each do |k, v|
        r[ k.to_sym ] = self.symbolize( v )
      end
      r
    else
      obj
    end
    new_obj
  end

  def self.get config
    name                      = config["name"]
    ENV["BINANCE_API_KEY"]    = config["api_key"]
    ENV["BINANCE_SECRET_KEY"] = config["api_secret"]
    response = if ENV['CRYPTOSTAT_TEST'] == "true" then
      Utils.info "Analysing binance (testmode)..."
      self.symbolize( JSON.parse( File.read( "examples/api.binance.com.txt" ) ) )
    else
      Utils.info "Analysing binance..."
      Utils.prepare_result( name, Binance::Api.info! )
    end

    result                    = {}
    Utils.debug response

    response[ :balances ].each do | balance |
      result[ "#{balance[ :asset ]}.#{name}.free" ]   = balance[ :free ]   unless balance[ :free ].tr("0.", "").empty? 
      result[ "#{balance[ :asset ]}.#{name}.locked" ] = balance[ :locked ] unless balance[ :locked ].tr("0.", "").empty?
    end

    result

  end
end

