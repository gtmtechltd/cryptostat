require 'rest-client'
require 'base64'
require_relative "./utils.rb"

class StatProbit
  def self.get config
    name     = config["name"]
    response = if ENV['CRYPTOSTAT_TEST'].include? "fromcache" then
      Utils.info "Analysing probit (testmode)..."
      File.read("examples/api.probit.com.txt")
    else
      Utils.info "Analysing probit..."
      # Authorization phase
      url = "https://accounts.probit.com/token"
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Basic " + Base64.encode64("#{config["api_client_id"]}:#{config["api_secret"]}").split("\n").join("")  # Remove newlines
      }
      payload       = '{ "grant_type": "client_credentials" }'
      response      = RestClient.post(url, payload, headers)
      json          = JSON.parse(response)
      authorization = "Bearer #{json["access_token"]}"

      # API phase
      url = "https://api.probit.com/api/exchange/v1/balance"
      headers = {
        "Authorization" => authorization
      }
      Utils.prepare_result( name, RestClient.get(url, headers))
    end 

#
#  { 
#    "data": [ 
#      {
#        "currency_id": "XRP",
#        "total": "100",
#        "available": "0",
#      },
#      ...
#    ]
#  }

    json     = JSON.parse(response)
    result = {}
    json["data"].each do |item|
      result[ "#{item["currency_id"]}.#{name}" ] = item["total"]
    end
    result
  end

end
