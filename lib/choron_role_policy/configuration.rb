module ChoronRolePolicy
  class Configuration
    VALID_CONFIG_KEYS = {
      policy_file: "config/choron_role_policy/policy.yml",
      role_root: "config/choron_role_policy/",
    }.freeze
    class << self
      attr_accessor *VALID_CONFIG_KEYS.keys

      def configure
        yield self
      end

      VALID_CONFIG_KEYS.each do |key, value|
        define_method key do
          instance_variable_get("@#{key}") || VALID_CONFIG_KEYS[key]
        end
      end
    end
  end
end