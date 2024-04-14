class AddressesController < ApplicationController
  require "faraday"
  require 'uri'
  before_action :set_address, only: %i[ show edit update destroy forecast]

  # GET /addresses or /addresses.json
  def index
    @addresses = Address.all
  end

  # GET /addresses/1 or /addresses/1.json
  def show
    @location = fetch_location(@address)
  end

  # GET /addresses/new
  def new
    @address = Address.new
  end

  # GET /addresses/1/edit
  def edit
  end

  # GET /addresses/1/forecast
  def forecast
    @location = fetch_location(@address)
    @forecast = fetch_forcast(@location)
  end
  
  # POST /addresses or /addresses.json
  def create
    @address = Address.new(address_params)
    @location = fetch_location(@address)
    # binding.break
    respond_to do |format|
      if @location && @address.save
        format.html { redirect_to address_url(@address), notice: "Address was successfully created." }
        format.json { render :show, status: :created, location: @address }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /addresses/1 or /addresses/1.json
  def update
    respond_to do |format|
      if @address.update(address_params)
        format.html { redirect_to address_url(@address), notice: "Address was successfully updated." }
        format.json { render :show, status: :ok, location: @address }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /addresses/1 or /addresses/1.json
  def destroy
    @address.destroy!

    respond_to do |format|
      format.html { redirect_to addresses_url, notice: "Address was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_address
      @address = Address.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def address_params
      params.require(:address).permit(:street, :city, :state, :zip)
    end

    def get_with_cache(path, params: {}, expires_in: 5.minutes)
  # Compute a cache key that is unique for the API, path, and query params
  request_fingerprint = Digest::SHA256.hexdigest({ path:, params: }.inspect)
  key = "ExampleApi/get/#{request_fingerprint}"

  Rails.cache.fetch(key, expires_in:) do
    faraday.get(path, params).body
  end
end

    def fetch_location(address, expires_in: 30.minute)
      geolocation_url = "https://geocoding.geo.census.gov/geocoder/locations/address" # ?street=#{street}&city=#{city}&state=#{address.state}&zip=#{address.zip}&benchmark=Public_AR_Current&format=json"
      params =  {street: URI.encode_uri_component(address.street), 
        city: URI.encode_uri_component(address.city), 
        state:URI.encode_uri_component(address.state), 
        zip: URI.encode_uri_component(address.zip),
        benchmark: "Public_AR_Current",
        format: "json"
      }
      response = faraday_conn.get(geolocation_url, params)
      if response.status == 200 
        match = response.body["result"]["addressMatches"].first
        lat = match["coordinates"]["x"]
        long = match["coordinates"]["y"]
        mached_addr = match["matchedAddress"]
        location = {lat: lat, long: long, mached_addr: mached_addr}
      # binding.break
      else
        location = nil
      # binding.break
      end
      # binding.break
      location
    end

    def fetch_forcast(location)
      lat = sprintf("%0.04f", location[:lat])
      long = sprintf("%0.04f", location[:long])
      weather_url = "https://api.weather.gov/points/#{long},#{lat}" 
      response = faraday_conn.get(weather_url)
      # binding.break

      if response.status == 200 
        forcast_url = response.body["properties"]["forecast"]
        hourly_forcast_url = response.body["properties"]["forecastHourly"]
      else
        "Error fectching Forcast"
      end

      response = faraday_conn.get(forcast_url)
      # binding.break
      response.body["properties"]["periods"]
    end

    def faraday_conn() 
      @faraday ||= begin
        options = {
          request: {
            open_timeout: 1,
            read_timeout: 1,
            write_timeout: 1
          }
        }
        conn = Faraday.new(**options) do |config|
          config.response :json
          config.response :raise_error
          config.response :logger, Rails.logger, headers: true, bodies: true, log_level: :debug 
          config.adapter :net_http
        end
      end
  
    end

end
