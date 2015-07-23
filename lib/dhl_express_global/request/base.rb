require 'httparty'
require 'nokogiri'
require 'active_support/core_ext/hash'
require 'dhl_express_global/helpers'

module DhlExpressGlobal
  module Request
    class Base
      include Helpers
      include HTTParty
      format :xml

      attr_accessor :debug

      default_options.update(verify: false)

      # DHL Express Global Test URL
      TEST_URL = 'https://wsb.dhl.com:443/sndpt/expressRateBook?WSDL'

      # DHL Express Global Production URL
      PRODUCTION_URL = ''

      # SERVICE_CODES = []
      
      # List of Payment Info codes
      PAYMENT_INFO_CODES = ["CFR", "CIF", "CIP", "CPT", "DAF", "DDP", "DDU", "DAP", "DEQ", "DES", "EXW", "FAS", "FCA", "FOB"]


      def initialize(credentials, options = {})
        requires!(options, :shipper, :recipient, :packages)
        @credentials = credentials
        @shipper, @recipient, @packages, @service_type, @debug = options[:shipper], options[:recipient], options[:packages], options[:service_type], options[:debug]
        @debug = ENV['DEBUG'] == 'true'
        @shipping_options = options[:shipping_options] ||= {}
        @payment_options = options[:payment_options] ||= {}
      end

      def process_request
        raise NotImplementedError, 'Override #process_request in subclass'
      end

      def api_url
        @credentials.mode == 'production' ? PRODUCTION_URL : TEST_URL
      end

      def build_xml
        raise NotImplementedError, 'Override #build_xml in subclass'
      end

      def parse_response(response)
        response = Hash.from_xml( response.parsed_response.gsub("\n", "") ) if response.parsed_response.is_a? String
        response = sanitize_response_keys(response)
      end

      def sanitize_response_keys(response)
        if response.is_a? Hash
          response.inject({}) { |result, (key, value)| result[underscorize(key).to_sym] = sanitize_response_keys(value); result }
        elsif response.is_a? Array
          response.collect { |result| sanitize_response_keys(result) }
        else
          response
        end
      end

      def add_ws_authentication_header(xml)
        xml[:soapenv].Header {
          xml[:wsse].Security('soapenv:mustUnderstand' => "1"  , 
                              'xmlns:wsse' => 'http://schemas.xmlsoap.org/ws/2003/06/secext', 
                              'xmlns:wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd') {
            xml[:wsse].UsernameToken('wsu:Id' => 'UsernameToken') {
              xml[:wsse].Username @credentials.username
              xml[:wsse].Password(@credentials.password, 'Type' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText')
            }
          }
        }
      end

      def add_shipper(xml)
        xml.Shipper {
          xml.Contact {
            xml.PersonName @shipper[:name]
            xml.CompanyName @shipper[:company]
            xml.PhoneNumber @shipper[:phone_number]
          }
          xml.Address {
            add_address_street_lines(xml, @shipper[:address])
            xml.City @shipper[:city]
            xml.PostalCode @shipper[:postal_code]
            xml.StateOrProvinceCode @shipper[:state] if @shipper[:state]
            xml.CountryCode @shipper[:country_code]
          }
        }
      end

      def add_recipient(xml)
        xml.Recipient {
          xml.Contact {
            xml.PersonName @recipient[:name]
            xml.CompanyName @recipient[:company]
            xml.PhoneNumber @recipient[:phone_number]
          }
          xml.Address {
            add_address_street_lines(xml, @recipient[:address])
            xml.City @recipient[:city]
            xml.PostalCode @recipient[:postal_code]
            xml.StateOrProvinceCode @recipient[:state] if @recipient[:state]
            xml.CountryCode @recipient[:country_code]
          }
        }
      end

      def add_address_street_lines(xml, address)
        Array(address).take(3).each_with_index do |address_line, i|
          case i
          when 0
            xml.StreetLines address_line
          when 1
            xml.StreetLines2 address_line
          when 2
            xml.streetLines3 address_line
          end
        end
      end

      def add_requested_packages(xml)
        @packages.each_with_index do |package, i|
          xml.RequestedPackages('number' => i + 1) {
            xml.Weight package[:weight][:value]
            xml.Dimensions {
              xml.Length package[:dimensions][:length]
              xml.Width package[:dimensions][:width]
              xml.Height package[:dimensions][:height]
            }
          }
        end
        xml.ShipTimestamp (Time.now + 10*60).strftime("%Y-%m-%dT%H:%M:%SGMT%:z")
        xml.UnitOfMeasurement @packages.first[:weight][:units] == 'KG' ? 'SI' : 'SU'
        xml.Content @shipping_options[:package_contents] ||= "NON_DOCUMENTS"
      end

      # Add information for shipments
      def add_shipment_info(xml)
        xml.ShipmentInfo {
          xml.DropOffType @shipping_options[:drop_off_type] ||= "REGULAR_PICKUP"
          xml.ServiceType @shipping_options[:service_type]
          xml.RequestValueAddedServices @shipping_options[:request_value_added_services] ||= "N"
          xml.NextBusinessDay @shipping_options[:next_business_day] ||= "N"
        }
      end

      def headers
        {"Content-Type"=>"text/xml; charset=utf-8"}
      end      

    end
  end
end