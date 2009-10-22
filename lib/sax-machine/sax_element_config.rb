module SAXMachine
  class SAXConfig
    
    class ElementConfig
      attr_reader :name, :setter, :data_class
      
      def initialize(name, options)
        @name = name.to_s
        
        if options.has_key?(:with)
          # for faster comparisons later
          @with = options[:with].inject({}) do |options, (key, value)|
            options[(key.to_s rescue key) || key] = value
            options
          end
        else
          @with = nil
        end
        
        if options.has_key?(:value)
          @value = options[:value].to_s
        else
          @value = nil
        end
        
        @as = options[:as]
        @collection = options[:collection]
        
        if @collection
          @setter = "add_#{options[:as]}"
        else
          @setter = "#{@as}="
        end
        @data_class = options[:class]
        @required = options[:required]
      end

      def column
        @as || @name.to_sym
      end

      def required?
        @required
      end

      def value_from_attrs(attrs)
        attrs.index(@value) ? attrs[attrs.index(@value) + 1] : nil
      end
      
      def attrs_match?(attrs)
        if @with
          attrs = Hash[*attrs]
          intersected = attrs.keys & @with.keys

          (intersected == @with.keys) && intersected.all? do |key|
            case matcher = @with[key]
              when Regexp
                attrs[key] =~ matcher
              when Proc
                matcher.call(attrs[key])
              else
                attrs[key] == matcher
            end
          end
        else
          true
        end
      end
      
      def has_value_and_attrs_match?(attrs)
        !@value.nil? && attrs_match?(attrs)
      end
      
      def collection?
        @collection
      end
    end
    
  end
end