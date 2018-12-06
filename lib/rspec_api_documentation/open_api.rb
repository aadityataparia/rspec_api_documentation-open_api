require 'rspec_api_documentation'
require 'rspec_api_documentation/open_api/version'

module RspecApiDocumentation
  module Writers
    extend ActiveSupport::Autoload

    autoload :OpenApiWriter
  end

  module OpenApi
    extend ActiveSupport::Autoload

    autoload :Index
    autoload :RspecExample
    autoload :Components
    autoload :Encoding
    autoload :ExternalDocs
    autoload :Flow
    autoload :RequestBody
    autoload :SecurityScheme
    autoload :Server
    autoload :Variable
  end
end
