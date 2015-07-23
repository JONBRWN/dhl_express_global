require 'dhl_express_global/request/base'

module DhlExpressGlobal
  module Request
    class Delete < Base
      
      attr_reader :pickup_date, :pickup_country, :dispatch_confirmation_number, :requestor_name, :reason_code

      def initialize(credentials, options = {})
        requires!(options, :pickup_date, :pickup_country, :dispatch_confirmation_number, :requestor_name)
        @credentials = credentials
        @pickup_date, @pickup_country, @dispatch_confirmation_number, @requestor_name = options[:pickup_date], options[:pickup_country], options[:dispatch_confirmation_number], options[:requestor_name]
        @reason_code = options[:reason_code] || "001"
      end

      def process_request
        api_response = self.class.post api_url, :body => build_xml, :headers => headers
        puts api_response if @debug
        response = parse_response(api_response)
        unless success?(response)
          failure_response(response)
        end
      end

      private

      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml[:soapenv].Envelope( 'xmlns:soapenv' => "http://schemas.xmlsoap.org/soap/envelope/", 
                                  'xmlns:del' => "http://scxgxtt.phx-dc.dhl.com/euExpressRateBook/ShipmentMsgRequest") {
            add_ws_authentication_header(xml)
            xml[:soapenv].Body {
              xml[:del].DeleteRequest {
                xml.PickupDate {
                  xml.parent.namespace = nil
                  xml.text pickup_date
                }
                xml.PickupCountry {
                  xml.parent.namespace = nil
                  xml.text pickup_country
                }
                xml.DispatchConfirmationNumber {
                  xml.parent.namespace = nil
                  xml.text dispatch_confirmation_number
                }
                xml.RequestorName {
                  xml.parent.namespace = nil
                  xml.text requestor_name
                }
                xml.Reason {
                  xml.parent.namespace = nil
                  xml.text reason_code
                }
              }
            }
          }
        end
        builder.doc.root.to_xml
      end

      def failure_response(response)
        error_message = response[:envelope][:body][:delete_response][:notification][:message]
        raise RateError, error_message
      end


      def success?(response)
        response[:envelope][:body][:delete_response] && ( response[:envelope][:body][:delete_response][:notification][:code] == "0" )
      end

      def headers
        super.merge!('SOAPAction' => 'euExpressRateBook_providerServices_ShipmentHandlingServices_Binder_deleteShipmentRequest')
      end

    end
  end
end