module SimpleForm
  module Helpers
    module Validators
      private

      def has_validators?
        attribute_name && object.class.respond_to?(:validators_on)
      end

      def attribute_validators
        object.class.validators_on(attribute_name)
      end

      def reflection_validators
        reflection ? object.class.validators_on(reflection.name) : []
      end

      def valid_validator?(validator)
        !conditional_validators?(validator) && action_validator_match?(validator)
      end

      def conditional_validators?(validator)
        validator.options.include?(:if) || validator.options.include?(:unless)
      end

      def action_validator_match?(validator)
        return true if !validator.options.include?(:on)

        case validator.options[:on]
        when :save
          true
        when :create
          !object.persisted?
        when :update
          object.persisted?
        end
      end

      def find_validator(validator)
        attribute_validators.find { |v| validator === v }
      end
    end
  end
end
