require 'spec_helper'
require 'date'

module DhlExpressGlobal
  describe Shipment do
    let (:dhl) { Shipment.new(dhl_credentials) }
    context '#delete' do
      context 'delete shipment with dispatch confirmation number', :vcr do
        let (:tomorrow) { DateTime.now.next_day.to_date.to_s }
        let(:options) do
          { :pickup_date => tomorrow, :pickup_country => "IT", 
            :dispatch_confirmation_number => "FLR-804",  :requestor_name => "Requestor", :reason_code => "001" }
        end

        it 'deletes a shipment' do
          expect{ dhl.delete(options) }.to_not raise_error
        end
      end
      context 'context raise an error when the pickup date is invalid', :vcr do
        let(:options) do
          { :pickup_date => "2014-07-21", :pickup_country => "IT", 
            :dispatch_confirmation_number => "FLR-804",  :requestor_name => "Requestor", :reason_code => "001" }
        end

        it 'raises an error' do
          expect { dhl.delete(options) }.to raise_error(DhlExpressGlobal::RateError, "Cancellation of booking was not successful. Requested Pickup was not found.")
        end
      end
    end
  end
end