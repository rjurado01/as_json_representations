module AsJsonRepresentations
  module Collection
    def as_json(options={})
      map do |item|
        item.respond_to?(:as_json) ? item.as_json(options) : item
      end
    end

    def representation(name, options={})
      as_json(options.merge(representation: name))
    end
  end
end
