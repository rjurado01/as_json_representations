module AsJsonRepresentations
  module ClassMethods
    def representation(name, options={}, &block)
      @representations ||= {}
      @representations[name] = options.merge(name: name, block: block)
    end

    def representations
      @representations
    end

    def find_representation(name)
      representations[name] || @parent&.find_representation(name) if name
    end

    def render_representation(object, options)
      representation_name = options.delete(:representation)&.to_sym
      return {} unless (representation = find_representation(representation_name))

      data = {}
      loop do
        data = object.instance_exec(
          options,
          &representation[:block]
        ).merge(data)

        representation = [representation[:name], true].include?(representation[:extend]) ?
          @parent.find_representation(representation[:name]) :
          find_representation(representation[:extend])

        return data unless representation
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods

    base.class_eval do
      eval %{
        def as_json(options={})
          if !options[:representation] && defined?(super)
            super(options)
          else
            #{base}.render_representation(self, options)
          end
        end
      }

      def representation(name, options={})
        as_json(options.merge(representation: name))
      end

      def self.included(base)
        return unless base.class == Module
        AsJsonRepresentations.send(:included, base)
        base.instance_variable_set :@parent, self
      end
    end
  end
end
