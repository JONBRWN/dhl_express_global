require 'spec_helper'
require 'dhl_express_global'

describe DhlExpressGlobal::Request::Shipment do
  describe 'ship service' do
    let(:dhl) { DhlExpressGlobal::Shipment.new(dhl_credentials) }
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

    context "international shipment", :vcr do
      let(:options) do
        { :shipper => shipper, :recipient => recipient, :packages => packages, :service_type => "P", :payment_info => "DDP", :international_detail => international_detail, :shipping_options => shipping_options }
      end

      it "succeeds" do
        expect {
          @shipment = dhl.ship(options)
        }.to_not raise_error

        expect(@shipment.class).to_not eq(DhlExpressGlobal::RateError)
      end

    end

    context "without service_type specified", :vcr do
      let(:options) do
        { :shipper => shipper, :recipient => recipient, :packages => packages, :payment_info => "DDP", :international_detail => international_detail, :shipping_options => shipping_options }
      end

      it 'raises error' do
        expect {
          @shipment = dhl.ship(options)
        }.to raise_error('Missing Required Parameter service_type')
      end
    end

  end
end