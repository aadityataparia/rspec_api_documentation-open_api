# RspecApiDocumentation::OpenApi

Adds `open_api_json` and `open_api_yaml` output format to `rspec_api_documentation`.
This gem is developed to be used at [Cookpad](https://github.com/cookpad/) to create openAPI spec using [`rspec_api_documentation`](https://github.com/zipmark/rspec_api_documentation) gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec_api_documentation-open_api', '~>0.2.2'
```

And then execute:

    $ bundle

Or install it yourself by:

    $ gem install rspec_api_documentation-open_api

## Usage

in *spec/spec_helper.rb* add
```rb
RspecApiDocumentation.configure do |config|
  config.format = :open_api_json # for json file
end
```
or
```rb
RspecApiDocumentation.configure do |config|
  config.format = :open_api_yaml # for yaml file
end
```

You can change other default configuration using
```rb
RspecApiDocumentation.configure do |config| # These are defaults
  config.open_api = {
    "info": {
      "version" => "1.0.0",
      "title" => "Open API",
      "description" => "Open API",
      "contact" => {
        "name" => "OpenAPI"
      }
    },
    "servers": [
      {
        "url" => "http://localhost:{port}",
        "description" => "Development server",
        "variables" => {
          "port" => {
            "default" => "3000"
          }
        }
      }
    ]
  }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aadityataparia/rspec_api_documentation-open_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RspecApiDocumentation::OpenApi project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/aadityataparia/rspec_api_documentation-open_api/blob/master/CODE_OF_CONDUCT.md).
