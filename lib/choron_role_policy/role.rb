module ChoronRolePolicy
  class Role
    ACCESS_KEYS = {
      full: "full",
    }.freeze

    # 読み込まれたタイミングでメソッドを定義する
    YAML.load_file(ChoronRolePolicy::Configuration.policy_file).each do |policy_name, _|
      define_method "#{policy_name}?" do |*policy_types|
        fetch_attachment(policy_name, *policy_types)
      end
    end

    def initialize(model, type, enum, column, all_allow)
      @model = model
      @type = type
      @enum = enum
      @column = column
      @all_allow = all_allow
    end

    def method_missing(method_name, *args)
      super unless method_name.to_s.end_with?("?")

      raise NoMethodError, "[Important!] The methods of this object are defined by #{ChoronRolePolicy::Configuration.policy_file}. Check the configuration file to see if #{method_name.to_s.gsub("?", "")} is set."
    end

    private

    attr_reader :model, :type, :enum, :column, :all_allow

    def fetch_attachment(policy_name, *policy_types)
      # もし全許可の設定があればその結果でtrue/falseを返す
      if all_allow && model.send(all_allow)
        return true
      end

      # 役割の設定自体が見つからなければfalse
      return false if role_settings.nil?

      target_policies = role_settings[policy_name.to_s]
      # 対象のポリシーの設定がなければfalse
      return false if target_policies.nil? || target_policies.empty?

      # 処理しやすいように全部配列にする
      unless target_policies.is_a?(Array)
        target_policies = [target_policies]
      end

      # fullがあれば常にtrue
      if target_policies.include?(ACCESS_KEYS[:full])
        return true
      end

      # 何もポリシータイプが指定されていなければフルアクセスで確認
      if policy_types.empty?
        return target_policies.include?(ACCESS_KEYS[:full])
      end

      policy_types.all? do |policy_type|
        if valid_policy_type?(policy_name, policy_type)
          target_policies.include?(policy_type.to_s)
        else
          raise ArgumentError, "Policy type not found in [#{policy_name}]. policy_type: #{policy_type}"
        end
      end
    end

    def role_settings
      @role_settings ||= get_role_settings
    end

    def get_role_settings
      role_root = ::ChoronRolePolicy::Configuration.role_root
      file_path = File.join(role_root, "#{type}.yml")

      begin
        YAML.load_file(file_path)[build_root_name]
      rescue Errno::ENOENT
        raise ArgumentError, "role file not found. file: #{file_path}"
      end
    end

    def build_root_name
      val = model.send(column)
      if enum.nil? || enum.empty?
        return val
      end

      file_enum_val = enum[val.to_sym] || enum[val.to_s]
      if file_enum_val.nil?
        raise ArgumentError, "enum value not found. enum #{enum}, search key: #{val}"
      end

      file_enum_val
    end

    # 設定ファイルに定義されているポリシータイプかどうかを確認した結果を返します
    # @note 理由
    #   例えばユーザデータには「create」「update」しかポリシーがないのに対して、destroyの操作権限を聞いている場合に不正と判定するようにしています
    #   これはポリシーファイルを見たときに、認可が必要な操作が全て書き出されていることを担保する仕組みです
    def valid_policy_type?(policy_name, policy_type)
      policy_settings[policy_name.to_s].to_a.include?(policy_type.to_s)
    end

    def policy_settings
      @policy_settings ||= YAML.load_file(ChoronRolePolicy::Configuration.policy_file)
    end
  end
end