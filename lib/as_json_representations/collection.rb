module AsJsonRepresentations
  module Collection
    def representation(name, options={})
      as_json(options.merge(representation: name))
    end

    def self.included(base)
      base.class_eval do
        def as_json(options={})
          subject = self
          representation = options[:representation]&.to_sym

          if representation && respond_to?(:klass) && klass.respond_to?(:representations)
            # call supported methods of ActiveRecord::QueryMethods
            QUERY_METHODS.each do |method|
              next unless respond_to? method

              args = klass.representations.dig(representation, method)

              # we need to reassign because ActiveRecord returns new object
              subject = subject.public_send(method, args) if args
            end
          end

          return super if respond_to? :super

          subject.map do |item|
            item.respond_to?(:as_json) ? item.as_json(options) : item
          end
        end
      end
    end
  end
end
