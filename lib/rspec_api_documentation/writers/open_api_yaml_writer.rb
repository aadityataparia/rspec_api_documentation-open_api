module RspecApiDocumentation
  module Writers
    class OpenApiYamlWriter < OpenApiWriter
      def write
        File.open(configuration.docs_dir.join('open_api.yaml'), 'w') do |f|
          f.write get_hash.to_yaml
        end
      end
    end
  end
end
