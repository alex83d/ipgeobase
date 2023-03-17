# frozen_string_literal: true

require_relative 'test_helper'

class TestIpgeobase < Minitest::Test
  # const url and query
  API_URL = 'http://ip-api.com/xml'
  QUERY_PARAMS = 'fields=city,country,countryCode,lat,lon'
  def setup
    # create instance class
    @ip_meta = Ipgeobase.new
  end

  def test_that_it_has_a_version_number
    refute_nil ::Ipgeobase::VERSION
  end

  def test_raises_exception_for_invalid_response
    # response invalid XML
    xml = '<invalid></response>'

    # HTTP request
    stub_request(:get, "#{API_URL}/127.0.0.1?#{QUERY_PARAMS}")
      .to_return(status: 200, body: xml, headers: {})

    # check invalid XML
    assert_raises(Nokogiri::XML::SyntaxError) { @ip_meta.lookup('127.0.0.1') }
  end

  def test_returns_metadata_for_given_ip_address
    # HTTP response
    stub_request(:get, "#{API_URL}/8.8.8.8?#{QUERY_PARAMS}")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host' => 'ip-api.com',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?>
      <query>
        <country>United States</country>
        <countryCode>US</countryCode>
        <city>Ashburn</city>
        <lat>39.03</lat>
        <lon>-77.5</lon>
      </query>', headers: {})

    # call the lookup method
    @ip_meta.lookup('8.8.8.8')

    # assert correct data
    assert_equal('Ashburn', @ip_meta.city)
    assert_equal('United States', @ip_meta.country)
    assert_equal('US', @ip_meta.countryCode)
    assert_equal('39.03', @ip_meta.lat)
    assert_equal('-77.5', @ip_meta.lon)
  end
end
