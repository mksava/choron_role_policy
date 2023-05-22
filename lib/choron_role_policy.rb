# frozen_string_literal: true


module ChoronRolePolicy
  def load(&block)
    # 読み込み順が各ファイルで密結合です。読み込み順を変更するとエラーになる可能性があります。
    require "active_support/all"
    require_relative "choron_role_policy/version"
    require_relative "choron_role_policy/helper"
    require_relative "choron_role_policy/configuration"

    Configuration.configure(&block)

    # 読み込み時にメソッドが定義されるため設定後に読み込みを行っています
    require_relative "choron_role_policy/role"
    require_relative "choron_role_policy/dsl"
  end
  module_function :load
end
