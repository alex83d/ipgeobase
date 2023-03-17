# frozen_string_literal: true

require_relative 'ipgeobase/version'
require 'addressable/uri'
require 'happymapper'
require 'net/http'
# class Ipgeobase return metadata from ip-api
class Ipgeobase
  include HappyMapper
  attr_reader :country, :city, :country_code, :lat, :lon

  # sheme for happymapper
  tag 'query'
  element :city, String, tag: 'city'
  element :country, String, tag: 'country'
  element :countryCode, String, tag: 'countryCode'
  element :lat, String, tag: 'lat'
  element :lon, String, tag: 'lon'

  def lookup(ip_address)
    # Check ip address
    unless ip_address =~ Resolv::IPv4::Regex || ip_address =~ Resolv::IPv6::Regex
      raise ArgumentError, "not a valid IP address: #{ip_address}"
    end

    uri = Addressable::URI.parse('http://ip-api.com')
    uri.path = "/xml/#{ip_address}?fields=city,country,countryCode,lat,lon"

    # create HTTP request and send
    response = Net::HTTP.get_response(URI(uri.to_s))

    # parse XML response using Happymapper
    xml = response.body
    parse(xml)
  end
end

# ip_meta = Ipgeobase.new
# p ip_meta.lookup('0.0.0.0')
# p ip_meta.city
