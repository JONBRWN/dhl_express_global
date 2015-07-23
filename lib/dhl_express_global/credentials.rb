require 'dhl_express_global/helpers'

module DhlExpressGlobal
  class Credentials
    include Helpers
    attr_reader :username, :password, :account_number, :mode

    def initialize(options = {})
      requires!(options, :username, :password, :account_number, :mode)
      @username = options[:username]
      @password = options[:password]
      @account_number = options[:account_number]
      @mode = options[:mode]
    end
  end
end