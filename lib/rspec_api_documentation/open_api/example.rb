module RspecApiDocumentation
  module OpenApi
    class Example < Node
      add_setting :summary
      add_setting :description
      add_setting :value
      add_setting :externalValue
    end
  end
end
