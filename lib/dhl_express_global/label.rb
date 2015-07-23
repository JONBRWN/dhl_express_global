require 'base64'
require 'pathname'

module DhlExpressGlobal
  class Label
    attr_accessor :options, :image, :response_details

    def initialize(label_details = {})
      @response_details = label_details[:envelope][:body][:shipment_response]
      @options = @response_details[:label_image]
      @options[:tracking_number] = @response_details[:packages_result][:package_result][:tracking_number] 
      @options[:file_name] = label_details[:file_name]
      @image = Base64.decode64(options[:graphic_image]) if has_image?

      if file_name = @options[:file_name]
        save(file_name, false)
      end
    end

    def name
      [tracking_number, format].join('.')
    end

    def format
      options[:label_image_format]
    end

    def file_name
      options[:file_name]
    end

    def tracking_number
      options[:tracking_number]
    end

    def save(path, append_name = true)
      return unless has_image?

      full_path = Pathname.new(path)
      full_path = full_path.join(name) if append_name
    
      File.open(full_path, 'wb') do |f|
        f.write(@image)
      end
    end

    def has_image?
      options.key?(:graphic_image)
    end

  end
end