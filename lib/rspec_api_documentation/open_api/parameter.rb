module RspecApiDocumentation
  module OpenApi
    class Parameter < Header
      add_setting :name, :required => true
      add_setting :in, :required => true
      add_setting :required, :default => lambda { |parameter| parameter.in.to_s == 'path' }
    end
  end
end
