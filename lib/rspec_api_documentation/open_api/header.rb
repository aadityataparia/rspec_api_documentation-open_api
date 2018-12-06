module RspecApiDocumentation
  module OpenApi
    class Header < Node
      attr_accessor :value

      add_setting :description
      add_setting :required, :default => false
      add_setting :deprecated
      add_setting :allowEmptyValue
      add_setting :style
      add_setting :explode
      add_setting :allowReserved
      add_setting :schema, :schema => Schema
      add_setting :example, :default => example
      add_setting :examples, :schema => { '' => Example }
      add_setting :content, :schema => { '' => Media }

      def example
        value if value
      end
    end
  end
end
