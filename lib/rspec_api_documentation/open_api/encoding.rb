module RspecApiDocumentation
  module OpenApi
    class Encoding < Node
      add_setting :contentType
      add_setting :headers, :schema => { '' => Header }
      add_setting :style
      add_setting :explode
      add_setting :allowReserved
    end
  end
end
