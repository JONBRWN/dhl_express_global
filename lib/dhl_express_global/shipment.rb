require 'dhl_express_global/credentials'
require 'dhl_express_global/request/shipment'
require 'dhl_express_global/request/label'
require 'dhl_express_global/request/delete'

module DhlExpressGlobal

  class Shipment

    def initialize(options = {})
      @credentials = Credentials.new(options)
    end

    def label(options = {})
      Request::Label.new(@credentials, options).process_request
    end

    def delete(options = {})
      Request::Delete.new(@credentials, options).process_request
    end

    def ship(options = {})
      Request::Shipment.new(@credentials, options).process_request
    end

  end
end