require_relative "./utils.rb"
require 'net/http'
require 'uri'
require 'json'

class StatBscwallet
  
  @@lasttime = Time.now.to_i

  def self.get_response api_key, wallet_address
    uri = URI.parse("https://graphql.bitquery.io/")
    header = {'Content-Type': 'application/json', 'X-API-KEY': api_key}

    query = "{
      ethereum(network: bsc) {
        address(address: {is: \"#{wallet_address}\" }) {
          balances {
            currency {
              address
              symbol
              tokenType
            }
            value
          }
        }
      }
    }"


    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = {query: query}.to_json

    response = http.request(request)
    json = JSON.parse(response.body)

    json["data"]["ethereum"]["address"].first.to_json
  end

  def self.get wallet, api_keys
    api_key  = api_keys["graphql.bitquery.io"]
    address  = wallet["address"]
    name     = wallet["name"]

    response = if ENV["CRYPTOSTAT_TEST"].include? "fromcache" then
      Utils.info "Analysing bsc wallet #{name} (#{address}) (testmode)..."
      File.read("examples/graphql.bitquery.io.bsc.txt")
    else
      while Time.now.to_i < @@lasttime + 2 do
        sleep 1                                     # Avoid 429 Too Many Requests
      end
      @@lasttime = Time.now.to_i
      Utils.info "Analysing bsc wallet #{name} (#{address.split(//).take(10).join("")}...)..."
      Utils.prepare_result( "bscwallet-#{address.split(//).take(7).join("")}", self.get_response( api_key, address ))
    end
    json     = JSON.parse(response)

    #     {
    #       "currency": {
    #         "address": "0xa527a61703d82139f8a06bc30097cc9caa2df5a6",
    #         "symbol": "Cake-LP",
    #         "tokenType": "ERC20"
    #       },
    #       "value": 0.0
    #     }

    tokens = {}

    json["balances"].each do |token|
      contract_address = token["currency"]["address"]
      symbol           = token["currency"]["symbol"]
      value            = token["value"].to_f
      if value != 0 and value != 0.0 then
        if contract_address != "-" and contract_address != "" then
          tokens[ "#{symbol}(#{contract_address}).#{name}-#{address.split(//).take(7).join("")}" ] = value
        else
          tokens[ "#{symbol}.#{name}-#{address.split(//).take(7).join("")}" ] = value
        end
      end
    end

    tokens
  end

end
