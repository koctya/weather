class AddressesController < ApplicationController
  require "faraday"
  require 'uri'
  before_action :set_address, only: %i[ show edit update destroy weather]

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

  # GET /addresses/1/weather
  def weather
    @location = fetch_location(@address)
    # @weather = fetch_forcast(@location)
  end
  
  # POST /addresses or /addresses.json
  def create
    @address = Address.new(address_params)
    @location = fetch_location(@address)

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

    def fetch_location(address)
      @faraday ||= begin
      options = {
        request: {
          open_timeout: 1,
          read_timeout: 1,
          write_timeout: 1
        }
      }
      street = URI.encode_uri_component(address.street)
      city=URI.encode_uri_component(address.city)
      geolocation_url = "https://geocoding.geo.census.gov/geocoder/locations/address" # ?street=#{street}&city=#{city}&state=#{address.state}&zip=#{address.zip}&benchmark=Public_AR_Current&format=json"
      # binding.break
      conn = Faraday.new(url: geolocation_url, 
        params: {street: street, 
          city: city, 
          state: address.state, 
          zip: address.zip,
          benchmark: "Public_AR_Current",
          format: "json"
        }, **options) do |config|
      
        config.response :json
        config.response :raise_error
        config.response :logger, Rails.logger, headers: true, bodies: true, log_level: :debug 
        end
        config.adapter :net_http
      end
      # binding.break
      response = conn.get()
      if response.status == 200 
        match = response.body["result"]["addressMatches"].first
        lat = match["coordinates"]["x"]
        long = match["coordinates"]["y"]
        mached_addr = match["addressComponents"]["matchedAddress"]
        location = {lat: lat, long: long, mached_addr: mached_addr}
      else
        location = nil
      end
      # binding.break
      location
    end

end
