require "rspec_api_documentation"
require "rspec_api_documentation/open_api/version"

module RspecApiDocumentation
  module Writers
    extend ActiveSupport::Autoload
    RspecApiDocumentation::Configuration.add_setting :open_api, default: nil

    autoload :OpenApiWriter
    autoload :OpenApiJsonWriter
    autoload :OpenApiYamlWriter
  end
end
