module RspecApiDocumentation
  module Writers
    class OpenApiJsonWriter < OpenApiWriter
      def write
        File.open(configuration.docs_dir.join('open_api.json'), 'w') do |f|
          f.write JSON.pretty_generate(get_hash)
        end
      end
    end
  end
end
