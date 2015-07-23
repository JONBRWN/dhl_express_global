def dhl_credentials
  @dhl_credentials ||= credentials["development"]
end

def dhl_production_credentials
  @dhl_production_credentials ||= credentials["production"]
end

private

def credentials
  @credentials ||= begin
    YAML.load_file("#{File.dirname(__FILE__)}/../config/dhl_credentials.yml")
  end
end