require 'net/http'
require 'uri'
require 'cgi'
require 'openssl'
require 'base64'

class ProductsController < ApplicationController
  def index
    @check = true
    @q = Product.ransack(params[:q])
    @products = []
    if params[:q]
    @products = params[:q][:name_cont].blank? ? [] : @q.result.paginate(page: params[:page])
    end
    @check = params[:q] && params[:q][:name_cont].blank?
  end

  def price_condition
    @product = Product.find(params[:id])
  end

  def information_form
    @product = Product.find(params[:id])
    @response = fetch_prices("set",@product.set_num)
    if(@response[:code] == 404)
      flash[:notice] = "Product not found"
      redirect_to "/product_condition/#{@product.id}"
    else
      data = JSON.parse(@response[:data])
      logger.debug "Result #{data}"
      if data["data"]
      @price = data["data"]["avg_price"].to_f.round(2)
        if @price == 0.0
          flash[:notice] = "your product is not accepted"
          redirect_to "/product_condition/#{@product.id}"
        else
          condition = params[:condition]
          if params[:condition] == "Good"
            @price = (@price * 0.48).round(2)
          elsif params[:condition] == "Mint"
            @price = (@price * 0.38).round(2)
          else
            flash[:notice] = "We do not purchase damage prodcuts  "
            redirect_to "/product_condition/#{@product.id}"
          end
        end
      end
    end
  end

  def fetch_prices(type, no)

    parameters = {
      oauth_consumer_key: "8903791B4A194504912E042779B62EBB",
      oauth_token: "2A16C878341743888F3114FFCEF67198",
      oauth_nonce: SecureRandom.hex,
      oauth_timestamp: Time.now.to_i.to_s,
      oauth_signature_method: "HMAC-SHA1",
      oauth_version: "1.0",
    }
    consumer_secret = "E706C414905248B5A08291C8C6474183"
    token_secret = "10811F32F0A6493CB7A30CEA45592C89"

    base_url = "https://api.bricklink.com/api/store/v1/items/#{type}/#{no}/price"
    param_string = parameters.sort.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join('&')

    signature_base_string = "GET&" + CGI::escape(base_url) + "&" + CGI::escape(param_string)
    signing_key = CGI::escape(consumer_secret) + "&" + CGI::escape(token_secret)

    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.digest(digest, signing_key, signature_base_string)

    signature = Base64.strict_encode64(hmac)

    parameters[:oauth_signature] = signature

    oauth_header = parameters.map {|k, v| %{#{k}="#{v}"} }.join(', ')

    uri = URI.parse(base_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri, { 'Authorization' => "OAuth #{oauth_header}" })
    response = http.request(request)
    if response.code == '200'
      if (JSON.parse(response.body)["meta"]["code"] == 401)
        return {error: "Product not found", code: 404, body: {}}
      end
      return {code: 200, data: response.body}
    else
      return {error: "Product not found", code: 404, body: {}}
    end
  end


end
