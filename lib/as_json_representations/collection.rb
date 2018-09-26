module AsJsonRepresentations
  module Collection
    def representation(name, options={})
      as_json(options.merge(representation: name))
    end

    def self.included(base)
      return if base.respond_to? :as_json

      base.class_eval do
        def as_json(options={})
          map do |item|
            item.respond_to?(:as_json) ? item.as_json(options) : item
          end
        end
      end
    end
  end
end
