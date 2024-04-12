# Weather app README

Retrieve forecast data for the given address. This includes, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)

## Use [Geocoding Services](https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html) for lat/long determination.

Example location lookup

        https://geocoding.geo.census.gov/geocoder/locations/address?street=4128+Grandview+Dr&city=Gibsonia&state=PA&zip=15044&benchmark=Public_AR_Current&format=json

## Use [National Weather Service public data API](https://weather-gov.github.io/api/) for Forcast data.

Example Weather lookup

        https://api.weather.gov/points/40.6407,-79.9348

followed by;

        https://api.weather.gov/gridpoints/PBZ/79,76/forecast


## This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version - ruby-3.2.2

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
