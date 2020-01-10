module AsJsonRepresentations
  module Collection
    def representation(name, options={})
      as_json(options.merge(representation: name))
    end

    def self.included(base)
      base.class_eval do
        def as_json(options={})
          subject = self

          if respond_to?(:klass) && klass.respond_to?(:representations)
            # call supported methods of ActiveRecord::QueryMethods
            %i[includes eager_load].each do |method|
              next unless respond_to? method

              args = klass.representations.dig(options[:representation], method)

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
