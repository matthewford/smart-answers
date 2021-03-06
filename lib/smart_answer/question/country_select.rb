module SmartAnswer
  module Question
    class CountrySelect < MultipleChoice
      def initialize(name, options = {}, &block)
        @include_uk = options.delete(:include_uk)
        options = country_list
        super(name, options, &block)
      end

      def options
        country_list
      end

      def country_list
        @countries ||= begin
          if @include_uk
            self.class.countries
          else
            self.class.countries.reject {|c| c[:slug] == 'united-kingdom' }
          end
        end
      end

      def valid_option?(option)
        options.map{|v| v[:slug]}.include? (option.to_s)
      end

      def to_response(input)
        country_list.find { |el| el[:slug] == input }
      end

      def self.countries
        @countries ||= YAML.load_file(Rails.root.join('lib', 'data', 'countries.yml'))
      end
    end
  end
end
