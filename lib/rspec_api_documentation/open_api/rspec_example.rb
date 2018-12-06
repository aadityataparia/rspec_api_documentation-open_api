module RspecApiDocumentation
  module OpenApi
    class RspecExample
      def initialize(example)
        @example = example
      end

      def method_missing(method, *args, &block)
        @example.send(method, *args, &block)
      end

      def respond_to?(method, include_private = false)
        super || @example.respond_to?(method, include_private)
      end

      def http_method
        metadata[:method]
      end

      def requests
        super.select { |request| request[:request_method].to_s.casecmp(http_method.to_s).zero? }
      end

      def route
        super.gsub(%r{:(?<parameter>[^\/]+)}, '{\k<parameter>}')
      end
    end
  end
end