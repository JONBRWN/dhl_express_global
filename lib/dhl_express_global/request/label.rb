require 'dhl_express_global/label'
require 'dhl_express_global/request/base'
require 'dhl_express_global/request/shipment'
require 'fileutils'

module DhlExpressGlobal
  module Request
    class Label < Shipment

      def initialize(credentials, options = {})
        super(credentials, options)
        @filename = options[:filename]
      end

      private

      def success_response(response)
        super

        label_details = response.merge!({
            :format => @label_specification[:image_type],
            :file_name => @filename
          })

        DhlExpressGlobal::Label.new label_details
      end

    end
  end
end
