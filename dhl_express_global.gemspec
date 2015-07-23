# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dhl_express_global/version'

Gem::Specification.new do |spec|
  spec.name          = "dhl_express_global"
  spec.version       = DhlExpressGlobal::VERSION
  spec.authors       = ["JONBRWN"]
  spec.email         = ["jonathanbrown.a@gmail.com"]
  spec.summary       = %q{Ruby wrapper for the DHL Express Global API}
  spec.description   = %q{Ruby wrapper for the DHL Express Global API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty', '>= 0.8.3'
  spec.add_dependency 'nokogiri', '>= 1.5.6'
  spec.add_dependency 'builder'
  spec.add_dependency 'xml-simple'
  spec.add_dependency 'activesupport'


  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'vcr', '~> 2.00'
  spec.add_development_dependency 'webmock', '~> 1.8.0'
  spec.add_development_dependency 'pry'
end
