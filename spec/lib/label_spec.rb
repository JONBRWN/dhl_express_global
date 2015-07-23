require 'spec_helper'
require 'tmpdir'

module DhlExpressGlobal
  describe Label do
    describe 'ship service for label' do
      let(:dhl) { Shipment.new(dhl_credentials) }
      let(:shipper) do 
        { :name => "Sender", :company => "Company", :phone_number => "555-555-5555", :address => "35 Great Jones St", :city => "New York", :state => "NY", :postal_code => "10012", :country_code => "US" }
      end
      let(:recipient) do
        { :name => "Recipient", :company => "Company", :phone_number => "555-555-5555", :address => "Bruehlstrasse, 10", :city => "Ettingen", :state => "CH", :postal_code => "4107", :country_code => "CH" }
      end
      let(:packages) do
        [
          {
            :weight => { :units => "KG", :value => 2.86 },
            :dimensions => { :length => 40, :width => 30, :height => 20, units: "CM" }
          }
        ]
      end
      let(:commodities) do
        { :number_of_pieces => 1, :description => "Clothing", :customs_value => 300.00 }
      end
      let(:international_detail) do
        { :commodities => commodities, :content => "NON_DOCUMENTS" }
      end
      let(:filename) {
        require 'tmpdir'
        File.join(Dir.tmpdir, "label#{rand(15000)}.pdf")
      }
      let(:shipping_options) do
        { :currency => "EUR", :unit_of_measurement => "SI" }
      end
      let(:options) do
        { 
          :shipper => shipper, 
          :recipient => recipient, 
          :packages => packages, 
          :payment_info => "DDP", 
          :international_detail => international_detail, 
          :shipping_options => shipping_options,
          :service_type => "P",
          :filename => filename 
        }
      end

      describe 'label', :vcr do
        before do
          @label = dhl.label(options)
        end

        it 'should create a label' do
          expect(File).to exist(filename)
        end

        it 'should return a tracking number' do
          expect(@label).to respond_to('tracking_number')
        end

        it 'should expose complete response' do
          expect(@label).to respond_to('response_details')
        end

        it 'should expose the file_name' do
          expect(@label).to respond_to('file_name')
        end

        after do
          require 'fileutils'
          FileUtils.rm_r(filename) if File.exists?(filename)
        end

      end 
    end
  end
end