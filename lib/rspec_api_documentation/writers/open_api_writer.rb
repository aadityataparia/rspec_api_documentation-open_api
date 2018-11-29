require 'json'
require 'yaml'
require 'cgi'
require 'rspec_api_documentation/writers/json_writer'

module RspecApiDocumentation
  module Writers
    class OpenApiWriter < Writer
      FILENAME = 'open_api'.freeze
      attr_writer :types, :swagger

      def write
        File.open(configuration.docs_dir.join("#{FILENAME}.json"), 'w') do |f|
          f.write JSON.pretty_generate(as_json)
        end
      end

      def as_json
        index.examples.each do |rspec_example|
          api = JSONExample.new(rspec_example, configuration).as_json.deep_stringify_keys
          description = api['description']
          route = api['route'].gsub(%r{\:version\/}, '')
          route = route.gsub(%r{\:([^\/]+)}, '{\1}')
          params = route.scan(%r{\{([^\/]+)\}}).map { |param| { 'name' => param[0], 'in' => 'path', 'required' => true, 'schema' => { 'type' => 'string' } } }
          swagger['paths'][route] = swagger['paths'][route] || {}
          responses = {}
          req = api['requests'][0]
          method = req['request_method'].downcase
          result = JSON.parse(req['response_body']) if req['response_body']
          properties = {}
          result&.each { |k, v| properties[k] = get_properties(v) }

          responses[req['response_status']] = {
            'description' => req['response_status_text'],
            'headers' => req['response_headers'].map { |name, _v| [name, { 'schema' => { 'type' => 'string' } }] }.to_h,
            'content' => {
              'application/json' => {
                'schema' => {
                  'type' => 'object',
                  'properties' => properties
                }
              }
            }
          }
          api['parameters']&.each do |param|
            params.push('name' => param['name'],
                        'in' => 'query',
                        'schema' => {
                          'type' => 'string'
                        },
                        'description' => param['description'],
                        'required' => param['required'] || false)
          end

          req['request_query_parameters']&.each do |name, value|
            params.push('name' => name,
                        'in' => 'query',
                        'schema' => {
                          'type' => 'string'
                        },
                        'example' => value)
          end
          if req['request_content_type'] == 'application/x-www-form-urlencoded' && api['requests'][0]['request_body']
            req['request_body'].scan(/([^\&\=]*)=([^\&]*)/).map do |body|
              params.push('name' => body[0],
                          'in' => 'query',
                          'schema' => {
                            'type' => 'string'
                          },
                          'example' => CGI.unescape(body[1]))
            end
          end
          swagger['paths'][route][method] = swagger['paths'][route][method] || {}
          swagger['paths'][route][method]['parameters'] = swagger['paths'][route][method]['parameters'] || []

          req['request_headers']&.each do |name, value|
            if name == 'Authorization'
              swagger['paths'][route][method]['security'] = if /Bearer (.*)/.match?(value)
                                                              unless responses[401] && responses['401']
                                                                responses[401] = {
                                                                  'description' => 'Unauthorized Access',
                                                                  'content' => {
                                                                    'application/json' => {
                                                                      'schema' => {
                                                                        '$ref' => '#/components/schemas/unauthorized'
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              end
                                                              [{ 'bearerAuth' => [] }]
                                                            else
                                                              [{ 'basicAuth' => [] }]
                                                            end
            else
              params.unshift('name' => name,
                             'in' => 'header',
                             'schema' => {
                               'type' => 'string'
                             },
                             'example' => value,
                             'required' => true)
            end
          end
          params.each do |param|
            has = false
            swagger['paths'][route][method]['parameters'].each_with_index do |p, i|
              if p['name'] == param['name']
                swagger['paths'][route][method]['parameters'][i]['example'] = swagger['paths'][route][method]['parameters'][i]['example'] || param['example']
                has = true
              end
            end
            swagger['paths'][route][method]['parameters'].push(param) unless has
          end
          desc = swagger['paths'][route][method]['description'] || ''
          swagger['paths'][route][method]['description'] = desc + "- #{description}"
          swagger['paths'][route][method]['description'] += if params.empty?
                                                              "\n"
                                                            else
                                                              ", <strong>Needed Parameters:</strong>\n  - #{params.map{ |p| p['name'] }.join("\n  - ")} \n"
                                                            end
          swagger['paths'][route][method]['responses'] = responses
        end
        swagger['components']['schemas'] = types

        swagger
      end

      def get_properties(v)
        case v.class.name
        when 'Hash'
          props = v.map { |key, value| [key, get_properties(value)] }.to_h
          x = {
            'type' => 'object',
            'properties' => props
          }
          if v['type']
            type = v['type'].tr('\/', '_')
            types[type] = x unless types.key?(type)
            if types.key?(type)
              types[type]['properties'] = hash_deep_assign(types[type]['properties'], x['properties'])
            else
              types[type] = x
            end
            return { '$ref' => "#/components/schemas/#{type}" }
          end
          x
        when 'Array'
          {
            'type' => 'array',
            'items' => get_properties(v[0])
          }
        when 'TrueClass', 'FalseClass'
          {
            'type' => 'boolean',
            'example' => v
          }
        when 'NilClass'
          {
            'type' => 'integer',
            'nullable' => true
          }
        when 'Integer', 'Float'
          {
            'type' => 'number',
            'example' => v
          }
        else
          {
            'type' => v.class.name.downcase,
            'example' => v
          }
        end
      end

      def hash_deep_assign(target, other)
        return target unless target && other
        other.each do |key, value|
          target[key] = if target.key?(key) && other[key].is_a?(Hash)
                          hash_deep_assign(target[key], other[key])
                        elsif target.key?(key) && target[key].is_a?(Array) && other[key].is_a?(Array)
                          target[key].push(*other[key]).uniq
                        elsif key == '$ref'
                          if other['$ref'] && target['$ref'] && target['$ref'] != other['$ref']
                            target = {
                              'oneOf' => [
                                { '$ref' => target['$ref'] },
                                { '$ref' => other['$ref'] }
                              ]
                            }
                          elsif target.key?('oneOf')
                            target['oneOf'].push('$ref' => other['$ref']).uniq
                          else
                            target['$ref'] || other['$ref']
                          end
                        elsif target.key?(key)
                          target[key] || other[key]
                        else
                          value
                        end
        end
        target = { 'oneOf' => target['oneOf'] } if target.key?('oneOf')
        target = { '$ref' => target['$ref'] } if target.key?('$ref')
        target = get_properties(target['example']) if target['example'] && target.key?('nullable')
        target
      end

      def types
        @types ||= {
          'unauthorized' => {
            'properties' => {
              'code' => {
                'type' => 'string',
                'example' => 'invalid_client_credentials'
              },
              'message' => {
                'type' => 'string',
                'example' => 'Not found or invalid client credentials'
              }
            }
          }
        }
      end

      def swagger
        @swagger ||= {
          'openapi' => '3.0.0',
          'info' => info,
          'servers' => servers,
          'paths' => {},
          'components' => {
            'securitySchemes' => {
              'bearerAuth' => {
                'type' => 'http',
                'scheme' => 'bearer'
              },
              'basicAuth' => {
                'type' => 'http',
                'scheme' => 'basic'
              }
            },
            'schemas' => {}
          }
        }
      end

      def info
        configs['info']
      end

      def servers
        configs['servers']
      end

      def configs
        (defined_configs || default_configs).deep_stringify_keys
      end

      def defined_configs
        configuration.open_api
      end

      def default_configs
        {
          info: {
            version: '1.0.0',
            title: 'Open API',
            description: 'Open API',
            contact: {
              name: 'OpenAPI'
            }
          },
          servers: [
            {
              url: 'http://localhost:{port}',
              description: 'Development server',
              variables: {
                port: {
                  default: '3000'
                }
              }
            }
          ]
        }
      end
    end
  end
end
