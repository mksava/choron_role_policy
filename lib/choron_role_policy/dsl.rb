module ChoronRolePolicy
  module DSL
    extend ActiveSupport::Concern

    included do
      # 認可の責務を持つロールオブジェクトを返すメソッドを定義します
      # @param [Symbol] type ロール名。この名前がデフォルトでオブジェクトを返すメソッド名になります
      # @param [Hash] enum ロールが格納されているDBのカラムの値と、ロールの設定ファイルの関係を記載したHashを渡します
      # @param [Symbol] role_method ロールの値を取得できるメソッド名を渡してください。デフォルトはtypeに _role をつけた値です(staff, なら staff_role)
      # @param [Symbol] method_name type とは別でオブジェクトを返すメソッド名を定義したいときに渡してください
      # @param [Symbol] all_allow どのようなときでも常にtrueになる条件判定ができるメソッド名を渡してください。
      # @example
      #   # app/models/user.rb
      #   # operate_role :integer, default: 0
      #   class User < ApplicationRecord
      #     enum :operate_role, [:staff, :general, :admin]
      #     set_role :operate, enum: { staff: :staff, general: :general, admin: :admin }, role_method: :operate_role, method_name: :operate
      #     # ↓ 省略形
      #     set_role :operate
      #   end
      #   user = User.new(operate_role: :staff)
      #   user.operate.comments? # => true/false
      #   user.operate.comments?(:full) # => true/false
      #   user.operate.comments?(:create) # => true/false
      def self.set_role(type, enum: nil, all_allow: nil, role_method: nil, method_name: nil)
        method_name = method_name || type
        role_method = role_method || "#{type}_role"

        define_method method_name do
          ::ChoronRolePolicy::Role.new(self, type, enum, role_method, all_allow)
        end
      end
    end
  end
end