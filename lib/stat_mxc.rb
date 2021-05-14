require 'rest-client'
require 'base64'
require_relative "./utils.rb"

class StatMxc
  def self.sign method, path, config
    params = {
        "api_key"  => config["api_key"],
        "req_time" => Time.now.to_i.to_s
    }
    params_str       = params.keys.sort.collect {|k| "#{k}=#{params[k]}" }.join("&")
    payload          = [ method, path, params_str ].join("\n")
    params[ "sign" ] = OpenSSL::HMAC.hexdigest("SHA256", config["api_secret"], payload)
    params
  end

  def self.get config
    name     = config["name"]
    response = if ENV['CRYPTOSTAT_TEST'].include? "fromcache" then
      Utils.info "Analysing mxc (testmode)..."
      File.read("examples/www.mxc.com.txt")
    else
      Utils.info "Analysing mxc..."

      headers = {
        "Content-Type" => "application/json"
      }
      host = "https://www.mxc.ceo"
      path = "/open/api/v2/account/info"
      params = self.sign "GET", path, config
      Utils.debug "Headers:\n#{headers}\n"
      Utils.debug "Params:\n#{params}\n"
      Utils.debug "GET #{host}#{path}"
      Utils.prepare_result( name, RestClient.get("#{host}#{path}", {headers: headers, params: params}) )
    end 

    #
    # {
    #   "data": {
    #     "BTC": {
    #       "frozen": "0",
    #       "available": "140"
    #     },
    #     ...
    #   }
    # }

    json     = JSON.parse(response)
    result = {}
    json["data"].each do |currency, data|
      result[ "#{currency}.mxc.frozen" ] = data["frozen"]
      result[ "#{currency}.mxc.free" ]   = data["available"]
    end
    result
  end

end
