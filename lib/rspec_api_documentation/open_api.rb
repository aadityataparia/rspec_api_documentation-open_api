require "rspec_api_documentation/open_api/version"

module RspecApiDocumentation
  module Writers
    extend ActiveSupport::Autoload

    autoload :OpenApiWriter
    autoload :OpenApiJsonWriter
    autoload :OpenApiYamlWriter
  end
end
