module RspecApiDocumentation
  module OpenApi
    class Components < Node
      add_setting :schemas, :schema => { '' => Schema }
      add_setting :responses, :schema => { '' => Response }
      add_setting :parameters, :schema => { '' => Parameter }
      add_setting :examples, :schema => { '' => Example }
      add_setting :requestBodies, :schema => { '' => RequestBody }
      add_setting :headers, :schema => { '' => Header }
      add_setting :securitySchemes, :schema => { '' => SecurityScheme }
      add_setting :links
      add_setting :callbacks
    end
  end
end
